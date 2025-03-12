////
////  ManualEntryModeView.swift
////  MyApp
////
////  Created by Cong Le on 3/11/25.
////
//
//import SwiftUI
//
//// Simple data model for an inventory item
//struct InventoryItem2: Identifiable {
//    let id = UUID()
//    var barcode: String
//    var name: String
//    var quantity: Int
//    var details: String
//}
//
//// ViewModel to manage inventory data
//class InventoryViewModel: ObservableObject {
//    @Published var items: [InventoryItem2] = []
//    
//    // Simulated asynchronous add operation
//    func addItem(_ item: InventoryItem2) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.items.append(item)
//        }
//    }
//}
//
//// Home screen with a list of items and Manual Entry navigation
//struct HomeView2: View {
//    @StateObject private var viewModel = InventoryViewModel()
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                // List showing the current inventory items
//                List(viewModel.items) { item in
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(item.name)
//                            .font(.headline)
//                        Text("Barcode: \(item.barcode)")
//                        Text("Quantity: \(item.quantity)")
//                        if !item.details.isEmpty {
//                            Text("Details: \(item.details)")
//                                .font(.subheadline)
//                        }
//                    }
//                    .padding(5)
//                }
//                
//                // Navigation button to the Manual Entry mode
//                NavigationLink(destination: ManualEntryView(viewModel: viewModel)) {
//                    Text("Manual Entry")
//                        .fontWeight(.semibold)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                }
//                .padding(.bottom)
//            }
//            .navigationTitle("Inventory")
//        }
//    }
//}
//
//// Manual Entry screen allowing the user to add new items manually
//struct ManualEntryView: View {
//    @ObservedObject var viewModel: InventoryViewModel
//    
//    // State variables for the input fields
//    @State private var barcode: String = ""
//    @State private var name: String = ""
//    @State private var quantity: String = "1"
//    @State private var details: String = ""
//    @State private var errorMessage: String?
//    @Environment(\.presentationMode) private var presentationMode
//    
//    var body: some View {
//        Form {
//            Section(header: Text("Item Details")) {
//                TextField("Barcode", text: $barcode)
//                    .autocapitalization(.none)
//                    .disableAutocorrection(true)
//                TextField("Name", text: $name)
//                TextField("Quantity", text: $quantity)
//                    .keyboardType(.numberPad)
//                TextField("Other Details (optional)", text: $details)
//            }
//            
//            // Display error message if any input is invalid
//            if let errorMessage = errorMessage {
//                Section {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                }
//            }
//            
//            Section {
//                Button(action: saveItem) {
//                    Text("Save Item")
//                        .frame(maxWidth: .infinity, alignment: .center)
//                }
//            }
//        }
//        .navigationTitle("Manual Entry")
//    }
//    
//    // Validates the input data and adds the item if valid
//    private func saveItem() {
//        guard !barcode.isEmpty, !name.isEmpty,
//              let qty = Int(quantity), qty > 0
//        else {
//            errorMessage = "Please fill in all fields and ensure quantity is a valid number."
//            return
//        }
//        
//        // Create a new inventory item and add it using the ViewModel
//        let newItem = InventoryItem2(barcode: barcode, name: name, quantity: qty, details: details)
//        viewModel.addItem(newItem)
//        
//        // Dismiss the Manual Entry view and return to the home screen
//        presentationMode.wrappedValue.dismiss()
//    }
//}
//
//// SwiftUI preview for design-time rendering
//struct HomeView2_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView2()
//    }
//}
