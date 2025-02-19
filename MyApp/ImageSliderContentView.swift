//
//  ImageSliderContentView.swift
//  MyApp
//
//  Created by Cong Le on 2/18/25.
//


import SwiftUI

/// Image Model and Sample Data
struct ImageModel: Identifiable {
    var id: String = UUID().uuidString
    var altText: String
    /// Going to use Live URL Image via AsyncImage for this effect.
    var link: String
}

let sampleImages: [ImageModel] = [
    .init(
        altText: "Mo Eid",
        link: "https://images.pexels.com/photos/9002742/pexels-photo-9002742.jpeg?cs=srgb&dl=pexels-mo-eid-1268975-9002742.jpg&fm=jpg&w=640&h=405"
    ),
    .init(
        altText: "Codioful",
        link: "https://images.pexels.com/photos/7135121/pexels-photo-7135121.jpeg?cs=srgb&dl=pexels-codioful-7135121.jpg&fm=jpg&w=640&h=427"
    ),
    .init(
        altText: "Fanny Hagan",
        link: "https://images.pexels.com/photos/19896879/pexels-photo-19896879.jpeg?cs=srgb&dl=pexels-fanny-hagan-842972996-19896879.jpg&fm=jpg&w=640&h=550"
    ),
    .init(
        altText: "Han-Chieh Lee",
        link: "https://images.pexels.com/photos/22944463/pexels-photo-22944463.jpeg?cs=srgb&dl=pexels-han-chieh-lee-1234591373-22944463.jpg&fm=jpg&w=640&h=427"
    ),
    .init(
        altText: "Cottonbro",
        link: "https://images.pexels.com/photos/9669094/pexels-photo-9669094.jpeg?cs=srgb&dl=pexels-cottonbro-9669094.jpg&fm=jpg&w=640&h=960"
    ),
    .init(
        altText: "Gülşah Aydoğan",
        link: "https://images.pexels.com/photos/18873058/pexels-photo-18873058.jpeg?cs=srgb&dl=pexels-gulsahaydgn-18873058.jpg&fm=jpg&w=640&h=450"
    )
]

struct ImageSliderContentView: View {
    @State private var activeID: String?
    var body: some View {
        /// Navigation Stack is must as this uses the Zoom Transition API
        NavigationStack {
            VStack {
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(.fill)
                        .frame(width: 45, height: 45)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Rectangle()
                            .fill(.fill)
                            .frame(width: 50, height: 5)
                        
                        VStack(spacing: 5) {
                            ForEach(1...4, id: \.self) { index in
                                Rectangle()
                                    .fill(.fill)
                                    .frame(height: 5)
                                    .padding(.trailing, index == 4 ? 50 : 0)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        
                        let config = ImageViewerConfig(height: 100, cornerRadius: 10, spacing: 5)
                        
                        if #available(iOS 18.0, *) {
                            ImageViewer(config: config) {
                                ForEach(sampleImages) { image in
                                    /// Animations will work even when image is loading
                                    AsyncImage(url: URL(string: image.link)) { image in
                                        image
                                            .resizable()
                                        /// Fit/Fill resize will be done inside the image viewer
                                    } placeholder: {
                                        Rectangle()
                                            .fill(.gray.opacity(0.4))
                                            .overlay {
                                                ProgressView()
                                                    .tint(.blue)
                                                    .scaleEffect(0.7)
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            }
                                    }
                                    /// Updates callback only works when a view contains containerValue
                                    .containerValue(\.activeViewID, image.id)
                                    
                                }
                            } overlay: {
                                OverlayView(activeID: activeID)
                            } updates: { isPresented, activeID in
                                self.activeID = activeID?.base as? String
                            }
                        } else {
                            // Fallback on earlier versions
                        }
                        
                        HStack {
                            Image(systemName: "message")
                            Spacer()
                            Image(systemName: "arrow.trianglehead.bottomleft.capsulepath.clockwise")
                            Spacer()
                            Image(systemName: "suit.heart")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                        .foregroundStyle(.primary.secondary)
                        .padding(.top, 10)
                    }
                    .padding(.top, 10)
                }
                .padding(15)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Usage:")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    Text(
                        """
                        ImageViewer {
                            AsyncImages/Images...
                        }
                        """
                    )
                    .monospaced()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(15)
                .background(.gray.opacity(0.15), in: .rect(cornerRadius: 15))
                
                Spacer(minLength: 0)
            }
            .padding(15)
            .navigationTitle("Image Viewer")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

/// Overlay View
struct OverlayView: View {
    var activeID: String?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.white.secondary)
                    .padding(10)
                    .contentShape(.rect)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay {
                if let imageItem = sampleImages.first(where: { $0.id == activeID }) {
                    Text(imageItem.altText)
                        .font(.callout)
                        .foregroundStyle(.white)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(15)
    }
}

// MARK: - Preview
#Preview {
    ImageSliderContentView()
}
