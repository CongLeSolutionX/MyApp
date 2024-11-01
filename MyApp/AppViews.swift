//
//  AppViews.swift
//  MyApp
//
//  Created by Cong Le on 10/31/24.
//

import SwiftUI

// MARK: - MainView
struct MainSwiftUIView: View {
    @State private var showDetail = false
    @State private var refreshCount = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Main View")
                    .font(.largeTitle)
                    .onAppear {
                        print("MainView.onAppear()")
                    }
                    .onDisappear {
                        print("MainView.onDisappear()")
                    }
                Button(action: {
                    showDetail.toggle()
                }) {
                    Text("Navigate to Detail View")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    refreshBody()
                }) {
                    Text("Refresh Body")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Text("Refresh Count: \(refreshCount)")
                    .padding()
            }
            .navigationTitle("Main")
            .background(Color.yellow.opacity(0.3))
            .sheet(isPresented: $showDetail) {
                DetailView()
            }
        }
        .onAppear {
            print("MainView.onAppear()")
        }
        .onDisappear {
            print("MainView.onDisappear()")
        }
    }
    
    func refreshBody() {
        print("MainView.body recomputes")
        refreshCount += 1
    }
}

// MARK: - DetailView
struct DetailView: View {
    @State private var refreshCount = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Detail View")
                .font(.largeTitle)
                .onAppear {
                    print("DetailView.onAppear()")
                }
                .onDisappear {
                    print("DetailView.onDisappear()")
                }
            Button(action: {
                refreshBody()
            }) {
                Text("Refresh Body")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Text("Refresh Count: \(refreshCount)")
                .padding()
        }
        .navigationTitle("Detail")
        .background(Color.purple.opacity(0.3))
        .onAppear {
            print("DetailView.onAppear()")
        }
        .onDisappear {
            print("DetailView.onDisappear()")
        }
    }
    
    func refreshBody() {
        print("DetailView.body recomputes")
        refreshCount += 1
    }
}

struct MainSwiftUIViewWithObjCInstance: View {
    // Create an instance of the Objective-C class
    let objcFunctions = ObjectiveCFunctions()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to LifecycleDemoApp")
                .font(.largeTitle)
                .padding()
                .onAppear {
                    // Call Objective-C function when the view appears
                    objcFunctions.showAlert(withTitle: "Hello", message: "MainView has appeared!")
                }
            
            Button(action: {
                // Call Objective-C function when button is tapped
                objcFunctions.showAlert(withTitle: "Button Tapped", message: "You tapped the button!")
            }) {
                Text("Show Alert")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainSwiftUIViewWithObjCInstance()
    }
}

// MARK: - Preview

#Preview {
    MainSwiftUIView()
}
