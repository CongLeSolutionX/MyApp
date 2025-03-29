//
//  SwiftUI_Core_Concepts_and_Structure_View.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI
import Combine // Needed for ObservableObject examples and potentially others

// MARK: - Core Protocols & Examples

// --- 1. View Protocol ---
// All UI elements in SwiftUI conform to the View protocol.
// P_View(View) -- implements --> CustomView(Your Custom View)
// P_View -- "body: some View" --> P_View
struct CustomView: View {
    var body: some View {
        // The body property defines the view's content and layout.
        // It returns 'some View', meaning any concrete type conforming to View.
        Text("This is a Custom View")
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

// --- 2. ViewModifier Protocol ---
// Used to create reusable modifiers.
// P_ViewModifier(ViewModifier) -- "body(content: Content)" --> P_View
struct CustomModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding(10)
            .background(.orange)
            .clipShape(Capsule())
            .shadow(radius: 5)
    }
}

// Extension to make the modifier easier to apply
extension View {
    func customStyled() -> some View {
        modifier(CustomModifier())
    }
}

// --- 3. Shape Protocol ---
// Defines a 2D shape. Shapes conform to View.
// P_Shape(Shape) -- extends --> P_View
// P_Shape -- "path(in: CGRect)" --> Path(Path)
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// --- 4. InsettableShape Protocol ---
// A shape that can be inset.
// P_InsettableShape(InsettableShape) -- extends --> P_Shape
// P_InsettableShape -- "inset(by: CGFloat)" --> P_InsettableShape
struct InsettableTriangle: InsettableShape {
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        // Simple (approximate) inset for demonstration
        var path = Path()
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        if insetRect.width > 0 && insetRect.height > 0 {
             path.move(to: CGPoint(x: insetRect.midX, y: insetRect.minY))
             path.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.maxY))
             path.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.maxY))
             path.closeSubpath()
        }
        return path
    }

    func inset(by amount: CGFloat) -> InsettableTriangle {
        var triangle = self
        triangle.insetAmount += amount
        return triangle
    }
}

// --- 5. ShapeStyle Protocol ---
// Describes how to color or pattern a shape. Color and Gradient conform to this.
// P_ShapeStyle(ShapeStyle)
// (Demonstrated by using Color, LinearGradient etc. below)

// Example Custom ShapeStyle (simple color interpolation)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) // resolve requires newer OS
struct CustomShapeStyle: ShapeStyle {
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        // Example: Return different colors based on color scheme
        if environment.colorScheme == .dark {
            return Color.yellow
        } else {
            return Color.purple
        }
    }
}


// --- 6. Layout Protocol ---
// For creating custom layout containers.
// P_Layout(Layout) -- extends --> P_Animatable(Animatable)
struct SimpleHStackLayout: Layout {
    var spacing: CGFloat = 8

    // Reports the container size
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let idealViewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let totalWidth = idealViewSizes.reduce(0) { $0 + $1.width } + CGFloat(subviews.count - 1) * spacing
        let maxHeight = idealViewSizes.reduce(0) { max($0, $1.height) }
        // Handle case where there are no subviews causing negative spacing calculation
        let cappedSpacing = CGFloat(max(0, subviews.count - 1)) * spacing
        let finalWidth = idealViewSizes.reduce(0) { $0 + $1.width } + cappedSpacing

        return CGSize(width: finalWidth, height: maxHeight)
    }

    // Places the subviews
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }
        var currentX = bounds.minX
        for subview in subviews {
            let idealSize = subview.sizeThatFits(.unspecified)
             // Place each subview vertically centered within the bounds
            let yPos = bounds.midY - idealSize.height / 2
            subview.place(at: CGPoint(x: currentX, y: yPos),
                          anchor: .topLeading, // Use topLeading anchor with calculated position
                          proposal: ProposedViewSize(idealSize)) // Use ideal size for placing
            currentX += idealSize.width + spacing
        }
    }

    // Conformance to Animatable (often EmptyAnimatableData if no properties animate)
    var animatableData: EmptyAnimatableData {
        get { EmptyAnimatableData() }
        set { /* Do nothing */ }
    }
}


// --- 7. Gesture Protocol ---
// For creating custom gestures or using built-in ones.
// P_Gesture(Gesture)
// (Demonstrated by using TapGesture below)

// --- 8. Transition Protocol ---
// Defines how views are inserted or removed.
// P_Transition(Transition)
// (Demonstrated by using .slide transition below)

// --- 9. Animatable Protocol ---
// Allows properties of a type to be animated.
// P_Animatable(Animatable) -- "animatableData: AnimatableData" --> P_VectorArithmetic(VectorArithmetic)
struct AnimatableRectangle: View, Animatable {
    var cornerRadius: CGFloat = 0

    var animatableData: CGFloat {
        get { cornerRadius }
        set { cornerRadius = newValue }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.green)
            .frame(width: 100, height: 100)
    }
}

// --- 10. VectorArithmetic Protocol ---
// Required for animatableData types. CGFloat, Double, CGPoint, CGSize conform.
// P_VectorArithmetic(VectorArithmetic)
// (Implicitly used by CGFloat in AnimatableRectangle)

// --- 11. DynamicProperty Protocol ---
// Base protocol for @State, @Binding, @EnvironmentObject, etc.
// P_DynamicProperty(DynamicProperty) -- "update()" --> P_DynamicProperty
@propertyWrapper
struct CustomDynamicProperty: DynamicProperty {
    @State private var internalCounter = 0 // Initial value is set here

    var wrappedValue: Int {
        get { internalCounter }
        nonmutating set { internalCounter = newValue }
    }

    // update() is called by SwiftUI before body is evaluated
    func update() {
        print("CustomDynamicProperty updated. Counter: \(internalCounter)")
    }
}


// MARK: - Common Views (Examples)

struct CommonViewsExample: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Common Views").font(.title2).bold()
            // --- Text ---
            // V_Text(Text) -- extends --> P_View
            Text("Basic Text View")

            // --- Image ---
            // V_Image(Image) -- extends --> P_View
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)

            // --- Spacer ---
            // V_Spacer(Spacer) -- extends --> P_View
            HStack { Text("Left"); Spacer(); Text("Right") }.padding(.horizontal)

            // --- Group ---
            // V_Group(Group) -- extends --> P_View
            Group {
                Text("Grouped Text 1")
                Text("Grouped Text 2")
            }
            .font(.caption)

            // --- Canvas ---
            // V_Canvas(Canvas) -- extends --> P_View
            Canvas { context, size in
                 let rect = CGRect(origin: .zero, size: size)
                 context.stroke(Path(ellipseIn: rect), with: .color(.red), lineWidth: 2)
            }
            .frame(width: 50, height: 30)
            .border(Color.gray)

            // --- TupleView --- Implicitly created by ViewBuilder
            // V_TupleView(TupleView) -- extends --> P_View
            HStack { // Example containing multiple views (implicitly a TupleView internally)
                 Text("Part of")
                 Text("a TupleView")
            }


            // --- AnyView --- Type erasure
            // V_AnyView(AnyView) -- extends --> P_View
             VStack {
                 Text("AnyView Example:")
                 let condition = Bool.random()
                 AnyView(condition ? Text("True").foregroundColor(.green) : Text("False").italic().foregroundColor(.red))
             }


            // --- EmptyView ---
            // V_EmptyView(EmptyView) -- extends --> P_View
            if Bool.random() {
                 Text("Sometimes Hidden")
                     .padding(.bottom, 5)
            } else {
                 EmptyView() // Represents absence of a view, takes up no space
            }
        }.padding().background(Color.secondary.opacity(0.1)).cornerRadius(10)
    }
}

// MARK: - Layout Containers (Examples)

struct LayoutContainersExample: View {
    @State private var showDetails = false
    let data = ["Apple", "Banana", "Cherry"]

    var body: some View {
        VStack(spacing: 20) {
            Text("Layout Containers").font(.title2).bold()
            // --- HStack ---
            // LC_HStack(HStack) -- extends --> P_View
            HStack {
                Text("HStack Item 1")
                Image(systemName: "circle.fill")
                Text("HStack Item 2")
            }
            .padding()
            .background(Color.blue.opacity(0.2))

            // --- VStack --- (Used as the root here)
            // LC_VStack(VStack) -- extends --> P_View
            VStack(alignment: .leading) {
                Text("VStack Item 1 (Leading Aligned)")
                Text("VStack Item 2")
            }
            .padding()
            .background(Color.green.opacity(0.2))


            // --- ZStack ---
            // LC_ZStack(ZStack) -- extends --> P_View
            ZStack(alignment: .topTrailing) {
                Rectangle().fill(.mint).frame(width: 120, height: 60)
                Text("ZStack Layered")
                    .padding(5)
                    .background(.white.opacity(0.7))
            }

            // --- ForEach ---
            // LC_ForEach(ForEach) -- extends --> P_View
            VStack(alignment: .leading){
                Text("ForEach Example:")
                ForEach(data, id: \.self) { fruit in
                    HStack {
                        Image(systemName: "leaf.fill")
                        Text(fruit)
                    }
                }
            }.padding().background(Color.yellow.opacity(0.2))


            // --- GeometryReader ---
            // LC_GeometryReader(GeometryReader) -- "provides" --> GeometryProxy(GeometryProxy)
            GeometryReader { geometry in
                Text("GeometryReader Width: \(geometry.size.width, specifier: "%.1f")")
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Use proxy info
            }
            .frame(height: 40) // Give GR some space
            .background(Color.orange.opacity(0.3))

        }.padding().background(Color.secondary.opacity(0.1)).cornerRadius(10)
    }
}

// MARK: - Putting It All Together (Demonstration View)

struct DiagramConceptsDemoView: View {
    @State private var isAnimating = false
    @State private var tapped = false

    // Define the tap gesture
    var tapGesture: some Gesture {
        TapGesture()
            .onEnded { _ in
                print("Tap Gesture Ended!")
                tapped.toggle()
            }
    }

    var body: some View {
        NavigationView { // Added for context
            ScrollView { // Make it scrollable
                VStack(alignment: .leading, spacing: 30) { // Add alignment and more spacing
                    Divider() // Add dividers for sections

                    // 1. Custom View Conforming to View
                    Section("Custom View (View Protocol)") {
                         CustomView()
                            .frame(maxWidth: .infinity, alignment: .center) // Center it
                    }

                    Divider()

                    // 2. Applying a Custom Modifier
                    Section("Custom Modifier (ViewModifier)") {
                         Text("Text with Custom Modifier")
                              .frame(maxWidth: .infinity, alignment: .center)
                              .customStyled()
                    }


                    Divider()

                    // 3. Using Shapes (Built-in and Custom)
                    Section("Shapes (Shape, InsettableShape, ShapeStyle)") {
                         HStack(spacing: 15) { // Add spacing
                              Spacer()// Center the shapes
                              Triangle()
                                  .fill(.red)
                                  .frame(width: 50, height: 50)
                              Circle()
                                  .fill(.blue)
                                  .frame(width: 50, height: 50)
                              // ShapeStyle usage
                              Rectangle()
                                  .fill(LinearGradient(colors: [.green, .yellow], startPoint: .top, endPoint: .bottom))
                                  .frame(width: 50, height: 50)

                             // Insettable Shape
                              InsettableTriangle()
                                  .strokeBorder(.purple, lineWidth: 4) // Use strokeBorder for insettables
                                  .frame(width: 60, height: 60)
                             Spacer() // Center the shapes
                         }.frame(maxWidth: .infinity) // Make HStack take full width
                    }

                    Divider()

                    // 4. Layout Containers Examples
                    Section("Layout Containers Examples") {
                         LayoutContainersExample()
                    }


                    Divider()

                    // 5. Animation and Animatable
                    Section("Animation (Animatable, VectorArithmetic)") {
                        VStack { // Add VStack for better layout
                             AnimatableRectangle(cornerRadius: isAnimating ? 25 : 0)
                                 .onTapGesture {
                                     withAnimation(.easeInOut(duration: 1.0)) {
                                         isAnimating.toggle()
                                     }
                                 }
                             Text("Tap green square to animate corner radius")
                                 .font(.caption)
                                 .foregroundColor(.secondary)
                         }
                         .frame(maxWidth: .infinity, alignment: .center)
                    }


                    Divider()

                    // 6. Gestures
                    Section("Gestures") {
                         Text("Double Tap Me!")
                             .padding()
                             .background(tapped ? Color.yellow : Color.gray.opacity(0.3))
                             .clipShape(Capsule()) // Nice shape for tapping
                             .gesture(
                                 TapGesture(count: 2) // CHANGE: Using double tap
                                     .onEnded { _ in
                                         print("Double Tap Gesture Ended!")
                                         tapped.toggle()
                                     }
                             )
                             .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Divider()

                    // 7. Transitions
                    Section("Transitions") {
                         VStack { // Add VStack for better layout
                              Button("Toggle Details") {
                                   withAnimation(.spring()) { // Use a spring animation
                                        showDetails.toggle()
                                   }
                              }
                              if showDetails {
                                   Text("Details are now visible with a custom transition.")
                                       .padding()
                                       .background(.cyan.opacity(0.3))
                                       .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .move(edge: .bottom))) // Custom transition
                              }
                          }
                          .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Divider()

                    // 8. Custom Layout
                    Section("Custom Layout (Layout Protocol)") {
                        VStack(alignment: .leading) { // Add VStack for label
                             Text("Using SimpleHStackLayout:")
                             SimpleHStackLayout(spacing: 15) {
                                 Text("First").padding(5).background(.red)
                                 Text("Second").padding(5).background(.green)
                                 Text("Third").padding(5).background(.blue)
                             }.foregroundColor(.white)
                         }
                    }

                    Divider()

                    // 9. Dynamic Property (Simple access - update prints to console)
                    Section("Dynamic Property") {
                         SimpleDynamicPropertyView()
                              .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Divider()

                    // 10. Common Views Example Section
                    Section("Common Views Examples") {
                         CommonViewsExample()
                    }


                }
                .padding() // Padding for the whole VStack content
            } // End ScrollView
            .navigationTitle("SwiftUI Concepts Demo") // Set title
            .navigationBarTitleDisplayMode(.inline) // Adjust title display
        } // End NavigationView
    } // End body

    @State private var showDetails = false
}

struct SimpleDynamicPropertyView: View {
    // CORRECTED: Remove initial value here
    @CustomDynamicProperty private var counter

    var body: some View {
         VStack {
              Text("DynamicProp Counter: \(counter)")
              Button("Increment DynamicProp") {
                   counter += 1 // This now correctly modifies the state within the wrapper
              }
         }
    }
}


// MARK: - Preview Provider
struct DiagramConceptsDemoView_Previews: PreviewProvider {
    static var previews: some View {
        DiagramConceptsDemoView()
    }
}
