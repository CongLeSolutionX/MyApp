//
//  ScanView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//
import SwiftUI

struct ScanView: View {
    @State var selection = 0 // Changed initial selection to 0 (Home)
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                HomeView() // Encapsulated Home content in its own view
                    .navigationBarHidden(true)
            }
            .tabItem {
                VStack {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            }
            .tag(0)
            
            NavigationView{ // Added NavigationView for ScanOnlyView
                ScanOnlyView()
                    .navigationBarHidden(true)
            }
            .tabItem {
                VStack {
                    
                    Image(systemName: "qrcode.viewfinder")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 25, height: 25, alignment: .center)
                    
                    Text("Scan")
                }
            }
            .tag(1)
            
            Text("Order View") // Placeholder
                .tabItem {
                    VStack {
                        Image(systemName: "cup.and.saucer.fill")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 25, height: 25, alignment: .center)
                        Text("Order")
                    }
                }
                .tag(2)
            
            Text("Gift View")
                .tabItem {
                    VStack {
                        Image(systemName: "gift.fill")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 25, height: 25, alignment: .center)
                        
                        Text("Gift")
                    }
                }
                .tag(3)
            
            Text("Offers View")
                .tabItem {
                    VStack {
                        Image(systemName: "star.fill")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 25, height: 25, alignment: .center)
                        Text("Offers")
                    }
                }
                .tag(4)
        }
        .accentColor(.green) // Set the tab bar icon color
        .edgesIgnoringSafeArea(.all) // For full-screen background color if needed
    }
}

struct HomeView: View { // Separate HomeView
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("46")
                        .font(.title)
                        .fontWeight(.bold)
                    Image(systemName: "star.fill")
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Button(action: {
                        // Switch to the "Scan & pay" view (which is the first card in HomeView)
                        // No action needed here because this is already the Scan & Pay view
                    }) {
                        Text("Scan & pay")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    
                    Button(action: {
                        // Switch to ScanOnlyView using the TabView's selection
                        // Find the ContentView and change its selection
                        if let rootView = UIApplication.shared.windows.first?.rootViewController as? UIHostingController<ScanView> {
                            rootView.rootView.selection = 1 // Switch to ScanOnlyView (tag 1)
                        }                    }) {
                            Text("Scan only")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(20)
                        }
                    Spacer()
                }
                .padding(.horizontal)
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        CardView()
                            .padding(.leading)
                        // Add more cards if needed, mimicking the scrollable effect
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 300, height: 450)
                            .padding(.trailing)
                    }
                }
                
                Spacer() // Push content to the top
            }
        }
    }
}

struct CardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 5)
            
            VStack(alignment: .center) {
                Image("starbucks_card") // Replace with your card image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180) // Adjust as needed
                    .clipped()
                    .cornerRadius(10)
                
                Text("$15.11")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Earns 2★ per $1")
                    .font(.caption)
                    .padding(4)
                    .background(Color.yellow.opacity(0.8))
                    .cornerRadius(5)
                
                Image("barcode") // Replace with a real barcode image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                
                Text("6164 6541 3266 7668")
                    .font(.caption)
                
                HStack {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("Manage")
                        }
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                            Text("Add funds")
                        }
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                    }
                }
                
                
                // PageControl (Dots) - Custom implementation for simplicity
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in  // Assuming 5 pages
                        Circle()
                            .fill(index == 0 ? Color.gray : Color.gray.opacity(0.4))  // Highlight first dot
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom)
                
            }
            .padding()
            
            VStack(alignment: .trailing) { // Position the logo
                HStack {
                    Spacer()
                    Image("starbucks_logo") // Replace with your logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.top, 5)
                }
                Spacer()
            }
            
        }
        .frame(width: 300, height: 450) // Set the card size
    }
}

struct ScanOnlyView: View {
    var body: some View {
        
        ScrollView{
            VStack(alignment: .leading) {
                HStack {
                    Text("46")
                        .font(.title)
                        .fontWeight(.bold)
                    Image(systemName: "star.fill")
                        .foregroundColor(.green)
                    
                    Spacer()
                    Text("Cong L.")
                        .font(.title2)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Button(action: {
                        // Switch to the "Scan & pay" view (which is the first card in HomeView)
                        if let rootView = UIApplication.shared.windows.first?.rootViewController as? UIHostingController<ScanView> {
                            rootView.rootView.selection = 0 // Switch back to HomeView (tag 0)
                        }
                    }) {
                        Text("Scan & pay")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(20)
                    }
                    
                    Button(action: {
                        // Switch to ScanOnlyView using the TabView's selection
                        // No action needed, already on Scan Only View
                    }) {
                        Text("Scan only")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 5)
                    
                    VStack {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green.opacity(0.8))
                                .frame(height: 180)
                            
                            Image(systemName: "star.fill")
                                .resizable()
                                .foregroundColor(.yellow)
                                .frame(width: 60, height: 60)
                        }
                        
                        
                        
                        Text("Scan to earn Stars")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        Text("Earns 1★ per $1")
                            .font(.caption)
                            .padding(4)
                            .background(Color.yellow.opacity(0.8))
                            .cornerRadius(5)
                        
                        Image(systemName: "qrcode")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150) // Explicitly set width and height
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Make default")
                            }
                            .padding()
                            .foregroundColor(.black)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .padding()
                
                
                Spacer() // Push content to the top
                
            }
            
        }
        
        
    }
}

// Preview Provider (for Xcode Previews)
struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
