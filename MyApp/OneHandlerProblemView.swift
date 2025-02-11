//
//  OneHandlerProblemView.swift
//  MyApp
//
//  Created by Cong Le on 2/11/25.
//

import SwiftUI

// MARK: - 3. The "One Handler Per Type" Problem

struct OneHandlerProblemView: View {
    enum NavigationValue: Hashable {
        case detailA
        case detailB
    }

    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("Go to Detail A", value: NavigationValue.detailA)
                NavigationLink("Go to Detail B", value: NavigationValue.detailB)
            }
            .navigationTitle("Single Handler Issue")
            // First navigationDestination for NavigationValue.self - This one works
            .navigationDestination(for: NavigationValue.self) { value in
                switch value {
                case .detailA:
                    Text("Detail View A - Handler 1 Active")
                case .detailB:
                    Text("Detail View B - Handler 1 Active")
                }
            }
            // Second navigationDestination for NavigationValue.self - This is *ignored* by SwiftUI, *no warning at runtime currently*
            .navigationDestination(for: NavigationValue.self) { value in
                switch value {
                case .detailA:
                    Text("Detail View A - Handler 2 (Ignored)") // This handler will NOT be called for detailA
                case .detailB:
                    Text("Detail View B - Handler 2 (Ignored)") // This handler will NOT be called for detailB
                }
            }
        }
    }
}

// MARK: - Preview
struct OneHandlerProblem_Previews: PreviewProvider {
    static var previews: some View {
        OneHandlerProblemView()
    }
}
