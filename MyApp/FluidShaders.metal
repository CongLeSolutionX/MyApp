//
//  FluidShaders.metal
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

#include <metal_stdlib>
using namespace metal;

// MARK: Structures --------------

// Data passed from CPU about interaction (matches Swift struct)
struct InteractionUniforms {
    float2 interactionPoint; // Normalized position [0, 1]
    float2 interactionVelocity; // Force vector
    float4 interactionColor; // Color (density) to add
    float interactionRadius; // Radius of influence (in normalized texture coords)
    float timestep;         // dt
    float viscosity;        // Diffusion rate
    bool addDensity;       // Flag: add density this frame?
    bool addVelocity;      // Flag: add velocity this frame?
};

// Simple Vertex output (position + texcoord) for screen quad
struct RasterizerData {
    float4 position [[position]];
    float2 texCoord;
};

// MARK: Vertex Shader (Screen Quad) --------------

vertex RasterizerData fluid_vertex(uint vid [[vertex_id]]) {
    RasterizerData out;
    // Simple vertices for a full-screen triangle pair (quad)
    float4 positions[6] = {
        float4(-1, -1, 0, 1), float4( 1, -1, 0, 1), float4(-1,  1, 0, 1),
        float4(-1,  1, 0, 1), float4( 1, -1, 0, 1), float4( 1,  1, 0, 1)
    };
    // Corresponding texture coordinates
    float2 texCoords[6] = {
        float2(0, 1), float2(1, 1), float2(0, 0),
        float2(0, 0), float2(1, 1), float2(1, 0)
    };

    out.position = positions[vid];
    out.texCoord = texCoords[vid];
    return out;
}

// MARK: Fragment Shader (Visualize Density) --------------

fragment float4 fluid_fragment(RasterizerData in [[stage_in]],
                                texture2d<float, access::sample> densityTexture [[texture(0)]]) {
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    float4 densityColor = densityTexture.sample(s, in.texCoord);
    // Simple visualization: use density directly as color
    return densityColor;
}

// MARK: Compute Shaders: Fluid Simulation Steps --------------

// --- Helper: Bilinear Interpolation ---
// Reads texture using normalized coordinates with linear filtering
float4 sample_bilinear(texture2d<float, access::sample> tex, float2 uv) {
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    return tex.sample(s, uv);
}

// --- 1. Advection ---
kernel void advect(texture2d<float, access::read> velocityIn [[texture(0)]],
                    texture2d<float, access::sample> quantityIn [[texture(1)]],
                    texture2d<float, access::write> quantityOut [[texture(2)]],
                    constant float &dt [[buffer(0)]],          // Use a separate simple buffer for dt
                    uint2 gid [[thread_position_in_grid]])
{
    float texelSizeX = 1.0 / float(velocityIn.get_width());
    float texelSizeY = 1.0 / float(velocityIn.get_height());
    float2 uv = (float2(gid) + 0.5) * float2(texelSizeX, texelSizeY); // Center of pixel

    // Read velocity at current grid point (using read for potentially better cache?)
    float2 vel = velocityIn.read(gid).xy; // Assuming velocity is stored in xy

    // Trace backward in time using velocity field
    float2 prevUV = uv - vel * dt * float2(texelSizeX, texelSizeY); // Scale velocity by dt and texel size

    // Sample the quantity at the previous position using bilinear interpolation
    float4 advectedQuantity = sample_bilinear(quantityIn, prevUV);

    quantityOut.write(advectedQuantity, gid);
}

// --- 2. Add External Forces/Density ---
kernel void add_source(texture2d<float, access::read_write> field [[texture(0)]],
                       constant InteractionUniforms &uniforms [[buffer(0)]],
                       uint2 gid [[thread_position_in_grid]])
{
    // Check which source type is active
    bool shouldAddDensity = uniforms.addDensity && field.get_pixel_format() == pixel_format::rgba8unorm;
    bool shouldAddVelocity = uniforms.addVelocity && field.get_pixel_format() == pixel_format::rg16float;

    if (!shouldAddDensity && !shouldAddVelocity) return;

    float texelSizeX = 1.0 / float(field.get_width());
    float texelSizeY = 1.0 / float(field.get_height());
    float2 uv = (float2(gid) + 0.5) * float2(texelSizeX, texelSizeY); // Center of pixel

    // Calculate distance squared in normalized coordinates
    float dx = uv.x - uniforms.interactionPoint.x;
    float dy = uv.y - uniforms.interactionPoint.y;
    float distSq = dx * dx + dy * dy;
    float radiusSq = uniforms.interactionRadius * uniforms.interactionRadius;

    // Add force/density within the interaction radius using a smooth falloff
    if (distSq < radiusSq) {
        float falloff = 1.0 - smoothstep(0.0f, radiusSq, distSq); // Smoother radial falloff
        float4 valueToAdd;
        if (shouldAddDensity) {
             // Scale density addition by timestep for consistency
             valueToAdd = uniforms.interactionColor * falloff * uniforms.timestep;
        } else { // shouldAddVelocity
             // Scale velocity addition by timestep
             valueToAdd = float4(uniforms.interactionVelocity, 0.0, 0.0) * falloff * uniforms.timestep;
        }

        float4 currentValue = field.read(gid);
        field.write(currentValue + valueToAdd, gid);
    }
}

// --- 3. Diffusion (Implicit method using Jacobi iterations for stability) ---
kernel void diffuse_jacobi(texture2d<float, access::sample> quantity_b [[texture(0)]], // Input quantity (right hand side b)
                           texture2d<float, access::sample> quantity_x_prev [[texture(1)]], // Quantity from previous Jacobi iteration (x_k)
                           texture2d<float, access::write> quantity_x_next [[texture(2)]],  // Output for this iteration (x_{k+1})
                           constant float &alpha [[buffer(0)]], // Precomputed alpha = dx^2 / (nu * dt)
                           constant float &beta_recip [[buffer(1)]], // Precomputed 1.0 / beta = 1.0 / (4 + alpha)
                           uint2 gid [[thread_position_in_grid]])
{
    float4 b_i = quantity_b.read(gid);           // b term at current grid cell
    float4 x_k_i = quantity_x_prev.read(gid);    // x from previous iteration at current cell

    // Sample neighbors from previous iteration's result (x_k)
    int width = quantity_x_prev.get_width();
    int height = quantity_x_prev.get_height();
    int x = gid.x;
    int y = gid.y;

    // Read neighbors directly (clamp to edge implicitly via texture address mode)
    float4 x_k_left   = quantity_x_prev.read(uint2(max(0, x - 1), y));
    float4 x_k_right  = quantity_x_prev.read(uint2(min(width - 1, x + 1), y));
    float4 x_k_bottom = quantity_x_prev.read(uint2(x, max(0, y - 1))); // Metal texture origin is top-left
    float4 x_k_top    = quantity_x_prev.read(uint2(x, min(height - 1, y + 1)));

    // Jacobi iteration: x_{k+1}_i = (alpha * b_i + sum(neighbors of x_k)) / beta
    // Using precomputed reciprocal of beta for multiplication
    float4 result = (b_i * alpha + x_k_left + x_k_right + x_k_bottom + x_k_top) * beta_recip;

    quantity_x_next.write(result, gid);
}

// --- 4. Divergence Calculation ---
kernel void calculate_divergence(texture2d<float, access::read> velocityField [[texture(0)]],
                                 texture2d<float, access::write> divergenceField [[texture(1)]],
                                 constant float2 &halfTexelSize [[buffer(0)]],// 0.5 / texWidth, 0.5 / texHeight
                                 uint2 gid [[thread_position_in_grid]])
{
    // Sample neighboring velocities (central differencing)
    int width = velocityField.get_width();
    int height = velocityField.get_height();
    int x = gid.x;
    int y = gid.y;

    float velL = velocityField.read(uint2(max(0, x - 1), y)).x;
    float velR = velocityField.read(uint2(min(width - 1, x + 1), y)).x;
    float velB = velocityField.read(uint2(x, max(0, y - 1))).y; // Metal y is down
    float velT = velocityField.read(uint2(x, min(height - 1, y + 1))).y;

    // Central difference for divergence: 0.5 * ( (velR - velL)/dx + (velT - velB)/dy )
    // Assuming dx=dy=1 grid spacing for scaling, use halfTexelSize for normalization? Check Stam's paper.
    // Scaling here assumes pixel difference corresponds to world unit difference.
    // Result here is technically divergence * (grid spacing)
     float divergence = (velR - velL) * halfTexelSize.x + (velT - velB) * halfTexelSize.y;

    divergenceField.write(float4(divergence, 0, 0, 0), gid);
}

// --- 5. Pressure Solve (Jacobi iterations for Poisson equation: Laplacian(pressure) = divergence) ---
kernel void pressure_jacobi(texture2d<float, access::sample> divergenceField [[texture(0)]], // Right hand side (b)
                            texture2d<float, access::sample> pressurePrevIter [[texture(1)]], // Pressure from previous Jacobi iteration (p_k)
                            texture2d<float, access::write> pressureOut [[texture(2)]],   // Output pressure for this iteration (p_{k+1})
                            uint2 gid [[thread_position_in_grid]])
{
    float divergence = divergenceField.read(gid).x; // b in Laplacian(p) = div

    // Sample neighboring pressures from previous iteration
    int width = pressurePrevIter.get_width();
    int height = pressurePrevIter.get_height();
    int x = gid.x;
    int y = gid.y;

    float p_k_left   = pressurePrevIter.read(uint2(max(0, x - 1), y)).x;
    float p_k_right  = pressurePrevIter.read(uint2(min(width - 1, x + 1), y)).x;
    float p_k_bottom = pressurePrevIter.read(uint2(x, max(0, y - 1))).x;
    float p_k_top    = pressurePrevIter.read(uint2(x, min(height - 1, y + 1))).x;

    // Jacobi iteration for Poisson equation: p_{k+1}_i = (sum(neighbors of p_k) - divergence * dx^2) / 4
    // Assume dx=1 here for simplicity -> alpha = -dx^2 = -1
    // beta = 4.0
    float result = (p_k_left + p_k_right + p_k_bottom + p_k_top - divergence) * 0.25; // 1/beta = 0.25

    pressureOut.write(float4(result, 0, 0, 0), gid);
}

// --- 6. Subtract Pressure Gradient ---
kernel void subtract_gradient(texture2d<float, access::read_write> velocityField [[texture(0)]],
                              texture2d<float, access::sample> pressureField [[texture(1)]],
                              constant float2 &halfTexelSize [[buffer(0)]], // 0.5 / texWidth, 0.5 / texHeight
                              uint2 gid [[thread_position_in_grid]])
{
    // Sample neighboring pressures for gradient calculation
    int width = pressureField.get_width();
    int height = pressureField.get_height();
    int x = gid.x;
    int y = gid.y;

    float pressureL = pressureField.read(uint2(max(0, x - 1), y)).x;
    float pressureR = pressureField.read(uint2(min(width - 1, x + 1), y)).x;
    float pressureB = pressureField.read(uint2(x, max(0, y - 1))).x;
    float pressureT = pressureField.read(uint2(x, min(height - 1, y + 1))).x;

    // Calculate pressure gradient (central difference): gradP = (0.5*(pR-pL)/dx, 0.5*(pT-pB)/dy)
    // Assume dx=dy=1 grid scaling again. Use halfTexelSize for scaling?
    float gradX = (pressureR - pressureL) * halfTexelSize.x;
    float gradY = (pressureT - pressureB) * halfTexelSize.y;

    // Read current velocity and subtract the gradient
    float2 currentVel = velocityField.read(gid).xy;
    float2 newVel = currentVel - float2(gradX, gradY);

    velocityField.write(float4(newVel, 0, 0), gid); // Write back divergence-free velocity
}

// --- 7. Helper Kernel to Clear a Texture --- (Added for clearTexture function)
kernel void clear_texture_kernel(texture2d<float, access::write> outTexture [[texture(0)]],
                                 uint2 gid [[thread_position_in_grid]])
{
    // Write zero based on texture format - adjust if not float4
    // Example: write 0.0 for r16Float, float2(0.0) for rg16Float etc.
    // This works fine for rgba8unorm and rg16float implicitly.
    outTexture.write(float4(0.0), gid);
}
