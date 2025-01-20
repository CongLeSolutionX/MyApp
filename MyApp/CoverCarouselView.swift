//
//  CoverCarouselView.swift
//  MyApp
//
//  Created by Cong Le on 1/19/25.
//


import SwiftUI

enum CarouselType: String, CaseIterable {
    case type1 = "Complete"
    case type2 = "Opacity"
    case type3 = "Scale"
    case type4 = "Both"
}

struct CoverCarouselView: View {
    @State private var activeID: UUID?
    @State private var carouselType: CarouselType = .type4
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                CustomCarousel(
                    config: .init(
                        hasOpacity: carouselType == .type4 || carouselType == .type2,
                        hasScale: carouselType == .type4 || carouselType == .type3,
                        cardWidth: 200
                    ),
                    selection: $activeID,
                    data: images
                ) { image in
                    GeometryReader { _ in
                        Image(image.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .clipped()
                }
                .frame(height: 170)
                .animation(.snappy(duration: 0.3, extraBounce: 0), value: carouselType)
                .padding(.top, 35)
                
                VStack(spacing: 15) {
                    Text("Config")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker("", selection: $carouselType) {
                        ForEach(CarouselType.allCases, id: \.rawValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(15)
                .background(.gray.opacity(0.08), in: .rect(cornerRadius: 15))
                .padding(15)
                
                Spacer()
            }
            .navigationTitle("My Collection of Agents")
        }
    }
}
// MARK: - Preview
#Preview {
    CoverCarouselView()
}
