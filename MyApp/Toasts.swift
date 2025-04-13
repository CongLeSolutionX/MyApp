//
//  Toasts.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

/// USAGE:
/// 1. Drag & drop the Toasts.swift file into your app
/// 2. Wrap your app's main view (root view) with RootView {  } wrapper
/// 3. use @Envrionment(ToastsData.self) to add or remove toasts into the app's context
/// 4. If you want previews to be working, then make sure that you've added RootView {  } wrapper in every #Preview section

@Observable
class ToastsData {
    fileprivate var toasts: [Toast] = []
    
    /// Adds toast to the Context
    func add(_ toast: Toast) {
        withAnimation(.bouncy) {
            toasts.append(toast)
        }
    }
    
    /// Removes toast from the Context
    func delete(_ id: String) {
        @Bindable var bindable = self
        if let toast = $bindable.toasts.first(where: { $0.id == id }) {
            toast.wrappedValue.isDeleting.toggle()
        }
        
        withAnimation(.bouncy) {
            toasts.removeAll(where: { $0.id == id })
        }
    }
}

struct Toast: Identifiable {
    private(set) var id: String = UUID().uuidString
    var content: AnyView
    
    init(@ViewBuilder content: @escaping (String) -> some View) {
        self.content = .init(content(id))
    }
    
    /// View Properties
    var offsetX: CGFloat = 0
    var isDeleting: Bool = false
}

fileprivate struct ToastsView: View {
    @Environment(ToastsData.self) private var toastsData
    /// View Properties
    @State private var isExpanded: Bool = false
    @State private var height: CGFloat = .zero
    var body: some View {
        @Bindable var toastsBindable = toastsData
        
        ZStack(alignment: .bottom) {
            if isExpanded {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isExpanded = false
                    }
            }
            
            let layout = isExpanded ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(ZStackLayout())
            
            layout {
                ForEach($toastsBindable.toasts) { $toast in
                    let index = (toasts.count - 1) - (toasts.firstIndex(where: { $0.id == toast.id }) ?? 0)
                    
                    toast.content
                        .offset(x: toast.offsetX)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let xOffset = value.translation.width < 0 ? value.translation.width : 0
                                    toast.offsetX = xOffset
                                }.onEnded { value in
                                    let xOffset = value.translation.width + (value.velocity.width / 2)
                                    
                                    if -xOffset > 200 {
                                        /// Remove Toast
                                        toastsData.delete(toast.id)
                                    } else {
                                        /// Reset Toast to it's initial Position
                                        withAnimation(.bouncy) {
                                            toast.offsetX = 0
                                        }
                                    }
                                }
                        )
                        .visualEffect { [isExpanded] content, proxy in
                            content
                                .scaleEffect(isExpanded ? 1 : scale(index), anchor: .bottom)
                                .offset(y: isExpanded ? 0 : offsetY(index))
                        }
                        .zIndex(toast.isDeleting ? 1000 : 0)
                        .frame(maxWidth: .infinity)
                        .transition(
                            .asymmetric(
                                insertion: .offset(y: 100),
                                removal: .move(edge: .leading)
                            )
                        )
                }
            }
            .padding(.bottom, 15)
            .onTapGesture {
                isExpanded.toggle()
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .animation(.bouncy, value: isExpanded)
        .onChange(of: toasts.isEmpty) { oldValue, newValue in
            if newValue {
                isExpanded = false
            }
        }
    }
    
    nonisolated private func offsetY(_ index: Int) -> CGFloat {
        let offset = min(CGFloat(index) * 15, 30)
        
        return -offset
    }
    
    nonisolated private func scale(_ index: Int) -> CGFloat {
        let scale = min(CGFloat(index) * 0.1, 1)
        
        return 1 - scale
    }
    
    var toasts: [Toast] {
        toastsData.toasts
    }
}

/// Root View for Creating Overlay Window
/// Place this at the app's root view and also if you want previews to be working, then you must wrap every preview with this wrapper
struct RootView<Content: View>: View {
    var content: Content
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    /// View Properties
    @State private var overlayWindow: UIWindow?
    private var toastsData = ToastsData()
    var body: some View {
        content
            .environment(toastsData)
            .onAppear {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, overlayWindow == nil {
                    let window = PassthroughWindow(windowScene: windowScene)
                    window.backgroundColor = .clear
                    /// View Controller
                    let rootController = UIHostingController(rootView: ToastsView().environment(toastsData))
                    rootController.view.frame = windowScene.keyWindow?.frame ?? .zero
                    rootController.view.backgroundColor = .clear
                    window.rootViewController = rootController
                    window.isHidden = false
                    window.isUserInteractionEnabled = true
                    window.tag = 1009
                    
                    overlayWindow = window
                }
            }
    }
}

/// A Pass through UIWindow, which is placed above the Entire SwiftUI Window and works like a universal toasts
fileprivate class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event),
                let rootView = rootViewController?.view
        else { return nil }
        
        if #available(iOS 18, *) {
            for subview in rootView.subviews.reversed() {
                /// Finding if any of rootview's is receving hit test
                let pointInSubView = subview.convert(point, from: rootView)
                if subview.hitTest(pointInSubView, with: event) != nil {
                    return hitView
                }
            }
            
            return nil
        } else {
            return hitView == rootView ? nil : hitView
        }
    }
}

// MARK: - Preview
#Preview {
    RootView {
        Toast_ContentView()
    }
}
