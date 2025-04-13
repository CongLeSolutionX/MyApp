//
//  ColorAndShapeStyleView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//


import SwiftUI

// Main view showcasing Color and ShapeStyle concepts
struct ColorAndShapeStyleShowcase: View {
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                
                // --- Color Demonstrations ---
//                Group {
//                    Text("Color Demonstrations").font(.title).bold()
//                    
//                    // Using Color directly as a View
//                    Text("Color as View:").font(.headline)
//                    HStack(spacing: 10) {
//                        Color.red.frame(width: 50, height: 50)
//                        Color(red: 0.46, green: 0.84, blue: 1.0).frame(width: 50, height: 50) // skyBlue
//                        Color(hue: 0.16, saturation: 1, brightness: 1).frame(width: 50, height: 50) // lemonYellow
//                        Color(white: 0.47).frame(width: 50, height: 50) // steelGray
//                    }
//                    
//                    // Predefined Colors
//                    Text("Predefined Colors:").font(.headline)
//                    HStack(spacing: 10) {
//                        Color.blue.frame(width: 50, height: 50)
//                        Color.green.frame(width: 50, height: 50)
//                        Color.purple.frame(width: 50, height: 50)
//                        Color.pink.frame(width: 50, height: 50)
//                    }
//                    
//                    // Semantic Colors
//                    Text("Semantic Colors:").font(.headline)
//                    HStack(spacing: 10) {
//                        Color.primary.frame(width: 50, height: 50).border(Color.secondary)
//                        Color.secondary.frame(width: 50, height: 50).border(Color.primary)
//                        Color.accentColor.frame(width: 50, height: 50).border(Color.gray)
//                    }
//                    
//                    // Color with Opacity
//                    Text("Color with Opacity:").font(.headline)
//                    ZStack {
//                        Color.orange.frame(width: 100, height: 50)
//                        Color.teal.frame(width: 50, height: 100)
//                        Color.indigo.opacity(0.5).frame(width: 120, height: 60)
//                    }
//                    
//                    // Color Initialization with RGBColorSpace
//                    Text("Color from RGB components:").font(.headline)
//                    HStack {
//                        Color(.sRGB, red: 0.9, green: 0.2, blue: 0.2, opacity: 1.0)
//                            .frame(width: 50, height: 50)
//                        Color(.displayP3, red: 0.2, green: 0.9, blue: 0.2, opacity: 1.0)
//                            .frame(width: 50, height: 50)
//                        Color(.sRGBLinear, red: 0.2, green: 0.2, blue: 0.9, opacity: 1.0)
//                            .frame(width: 50, height: 50)
//                    }
//                    
//                    // Color from Resolved
//                    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
//                        Text("Color from Resolved:").font(.headline)
//                        let resolvedColor = Color.Resolved(linearRed: 0.1, linearGreen: 0.9, linearBlue: 0.5, opacity: 1.0)
//                        Color(resolvedColor).frame(width: 50, height: 50)
//                    }
//                }
//                
                Divider()
                
                // --- ShapeStyle Demonstrations ---
                Group {
                    Text("ShapeStyle Demonstrations").font(.title).bold()
                    
                    // Foreground Style
                    Text("Foreground Style:").font(.headline)
                    VStack(alignment: .leading) {
                        Text("Primary text")
                            .font(.title)
                            .foregroundStyle(.primary) // Uses HierarchicalShapeStyle.primary implicitly
                        Text("Secondary text")
                            .font(.body)
                            .foregroundStyle(.secondary) // Uses HierarchicalShapeStyle.secondary
                        Text("Tertiary text")
                            .font(.caption)
                            .foregroundStyle(.tertiary) // Uses HierarchicalShapeStyle.tertiary
                        Text("Quaternary text")
                            .font(.footnote)
                            .foregroundStyle(.quaternary) // Uses HierarchicalShapeStyle.quaternary
                        
                        if #available(iOS 16.0, macOS 13.0, tvOS 17.0, watchOS 10.0, *) {
                             Text("Quinary text (iOS 16+)")
                                .font(.caption2)
                                .foregroundStyle(.quinary) // Uses HierarchicalShapeStyle.quinary
                        }
                        
                        // Applying specific style using foregroundStyle
                         Text("Blue Foreground Style")
                               .foregroundStyle(.blue)
                        
                       // Applying multiple styles
                       if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                            Label("Palette Icon", systemImage: "square.stack.3d.up.fill")
                                .font(.title)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.blue, .green) // Primary and Secondary
                                .padding(.top)
                                
                            Label("Hierarchical Icon", systemImage: "person.3.sequence.fill")
                                .font(.title)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.purple) // Primary set to purple, others derived
                                .padding(.top)
                        }
                    }
                    
                    // Background Style
                    Text("Background Style:").font(.headline)
                    Text("Text on Default Background")
                        .padding()
                        .background(.background) // Uses BackgroundStyle implicitly
                        .border(Color.gray)
                        
                    // Tint Style
                     Text("Tint Style:").font(.headline)
                     Button("Tinted Button") { }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange) // Uses TintShapeStyle implicitly via .tint modifier
                        
                     if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                        Text("Text with Tint")
                             .foregroundStyle(.tint) // Explicitly use TintShapeStyle
                             .tint(.green)
                    }
                }
                
                Divider()
                
                // --- Gradient Demonstrations ---
//                Group {
//                    Text("Gradient Demonstrations").font(.title).bold()
//                    
//                    let gradient = Gradient(colors: [.blue, .purple])
//                    let stops = [Gradient.Stop(color: .yellow, location: 0.1), Gradient.Stop(color: .red, location: 0.9)]
//                    
//                    // Linear Gradient
//                    Text("Linear Gradient:").font(.headline)
//                    Rectangle()
//                        .fill(.linearGradient(gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
//                        .frame(height: 100)
//                    Rectangle()
//                        .fill(.linearGradient(stops: stops, startPoint: .leading, endPoint: .trailing))
//                        .frame(height: 100)
//                        
//                    // Radial Gradient
//                    Text("Radial Gradient:").font(.headline)
//                    Circle()
//                        .fill(.radialGradient(gradient, center: .center, startRadius: 10, endRadius: 80))
//                        .frame(height: 150)
//                        
//                     // Angular (Conic) Gradient
//                    Text("Angular (Conic) Gradient:").font(.headline)
//                    Rectangle()
//                        .fill(.angularGradient(gradient, center: .center, angle: .degrees(90)))
//                        .frame(height: 100)
//                        
//                    // Elliptical Gradient
//                    if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
//                        Text("Elliptical Gradient:").font(.headline)
//                        Rectangle()
//                            .fill(.ellipticalGradient(gradient, center: .center, startRadiusFraction: 0.1, endRadiusFraction: 0.5))
//                            .frame(height: 100)
//                    }
//                    
//                     // Mesh Gradient (iOS 18+)
//                    if #available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
//                        Text("Mesh Gradient (iOS 18+):").font(.headline)
//                        MeshGradient(width: 3, height: 3, points: [
//                             .init(0, 0), .init(0.5, 0), .init(1, 0),
//                             .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
//                             .init(0, 1), .init(0.5, 1), .init(1, 1)
//                         ], colors: [
//                             .red, .purple, .indigo,
//                             .orange, .white, .blue,
//                             .yellow, .green, .mint
//                         ])
//                         .frame(height: 150)
//                     }
//                }
//                
                Divider()
                
                // --- Material Demonstrations ---
                if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                    Group {
                        Text("Material Demonstrations").font(.title).bold()
                        
                        ZStack {
                            Image(systemName: "square.stack.3d.up.fill")
                                .resizable().scaledToFit()
                                .frame(width: 150)
                                .foregroundColor(.cyan)
                            
                            VStack {
                                Text("Ultra Thin Material").padding(5).background(.ultraThinMaterial, in: Capsule())
                                Text("Thin Material").padding(5).background(.thinMaterial, in: Capsule())
                                Text("Regular Material").padding(5).background(.regularMaterial, in: Capsule())
                                Text("Thick Material").padding(5).background(.thickMaterial, in: Capsule())
                                Text("Ultra Thick Material").padding(5).background(.ultraThickMaterial, in: Capsule())
                                if #available(macOS 12.0, *) { // .bar is not available on watchOS/tvOS
                                    Text("Bar Material (macOS/iOS)").padding(5).background(.bar, in: Capsule())
                                }
                            }
                            .padding(.top, 50)
                        }
                        .frame(height: 250)
                    }
                }
                
                 Divider()
                
                // // --- Shader Demonstration (placeholder) ---
                // if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
                //     Group {
                //         Text("Shader Demonstration").font(.title).bold()
                //         Text("Shaders require Metal Shading Language (MSL) code and cannot be fully demonstrated here without a Metal library.")
                //             .font(.caption)
                //     }
                // }
                
                 Divider()

                // --- ImagePaint Demonstration ---
                Group {
                    Text("ImagePaint Demonstration").font(.title).bold()
                    Capsule()
                        .fill(.image(Image(systemName: "leaf.fill"), scale: 0.2))
                        .frame(height: 100)
                }
                
                // --- AnyShapeStyle Demonstration ---
                if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                    Group {
                        Text("AnyShapeStyle Demonstration").font(.title).bold()
                        let dynamicStyle: AnyShapeStyle = Bool.random() ? AnyShapeStyle(.red) : AnyShapeStyle(.blue.gradient)
                        Rectangle()
                            .fill(dynamicStyle)
                            .frame(height: 50)
                    }
                }
                                
                // --- HierarchicalShapeStyle Demonstration ---
                if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                     Group {
                        Text("HierarchicalShapeStyle Demonstration").font(.title).bold()
                         VStack(alignment: .leading) {
                             Rectangle().fill(.primary).frame(height: 20)
                             Rectangle().fill(.secondary).frame(height: 20)
                             Rectangle().fill(.tertiary).frame(height: 20)
                             Rectangle().fill(.quaternary).frame(height: 20)
                             if #available(iOS 16.0, macOS 12.0, tvOS 17.0, watchOS 10.0, *) {
                                 Rectangle().fill(.quinary).frame(height: 20)
                             }
                         }
                         .padding()
                         .background(Color(white:0.9))
                         .foregroundStyle(.purple) // Set the base non-hierarchical style
                    }
                }
                
                // --- Separator Shape Style ---
                 if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                     Group {
                         Text("Separator Shape Style").font(.title).bold()
                         Rectangle()
                             .frame(height: 1)
                             .foregroundStyle(.separator)
                     }
                 }
                 
                 // -- ShadowStyle applied to ShapeStyle --
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                    Group {
                        Text("ShadowStyle applied to ShapeStyle").font(.title).bold()
                        HStack {
                            Circle().fill(.blue.shadow(.drop(color: .black.opacity(0.5), radius: 5, x: 5, y: 5)))
                                .frame(width: 80, height: 80)
                            Circle().fill(.green.shadow(.inner(color: .black.opacity(0.7), radius: 5, x: 3, y: 3)))
                                .frame(width: 80, height: 80)
                        }.frame(height: 100)

                    }
                }


            }
            .padding()
        }
        .navigationTitle("Color & ShapeStyle")
    }
}

// MARK: - Preview

struct ColorAndShapeStyleShowcase_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ColorAndShapeStyleShowcase()
        }
    }
}

