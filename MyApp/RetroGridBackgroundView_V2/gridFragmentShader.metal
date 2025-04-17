//
//  gridVertexShader.metal
//  MyApp
//
//  Created by Cong Le on 4/17/25.
//
//
//// Grid Fragment Shader (gridFragmentShader.metal pseudocode)
//fragment float4 gridFragmentShader(FragmentIn in [[stage_in]],
//                                   constant float &time [[buffer(0)]]) {
//    // Logic to compute blue neon grid with perspective scaling
//    return float4(0.0, 0.6, 1.0, 1.0); // Neon Blue color
//}
//
//// Stars Fragment Shader
//fragment float4 starsFragmentShader() {
//    // Twinkling effect
//    float brightness = rand(gl_FragCoord.xy + time);
//    return float4(vec3(brightness), 1.0);
//}
