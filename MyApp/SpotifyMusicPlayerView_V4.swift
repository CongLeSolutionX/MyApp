//
//  SpotifyMusicPlayerView_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

//
//  SpotifyMusicPlayerView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI
import UIKit        // For UIImage and UIActivityViewController
import LinkPresentation  // For LPLinkMetadataSource

// MARK: - Custom Result Builder: ItemBuilder

@resultBuilder
struct ItemBuilder {
    static func buildBlock(_ components: [Any]...) -> [Any] {
        components.flatMap { $0 }
    }

    static func buildExpression(_ expression: String) -> [Any] {
        [expression]
    }

    static func buildExpression(_ expression: URL) -> [Any] {
        [expression]
    }

    static func buildExpression(_ expression: UIImage) -> [Any] {
        [expression]
    }

    static func buildExpression(_ expression: [Any]) -> [Any] {
        expression
    }

    static func buildOptional(_ component: [Any]?) -> [Any] {
        component ?? []
    }
    
    static func buildEither(first component: [Any]) -> [Any] {
        component
    }

    static func buildEither(second component: [Any]) -> [Any] {
        component
    }

    static func buildArray(_ components: [[Any]]) -> [Any] {
        components.flatMap { $0 }
    }
}

// MARK: - Music Player View

struct MusicPlayerView: View {
    // Constants
    private let songTitle = "để tôi ôm em bằng giai điệu này"
    private let artistName = "CongLeSolutionX"
    private let albumArtImageName = "My-meme-microphone"
    private let songURL: URL? = URL(string: "https://open.spotify.com/track/example-track-id")
    private let totalDurationSeconds: Double = 254
    
    // State Variables
    @State private var isPlaying: Bool = true
    @State private var progressValue: Double = 0.3
    @State private var isLiked: Bool = true
    @State private var isShuffling: Bool = true
    @State private var repeatMode: Int = 0  // 0 = none, 1 = repeat one, 2 = repeat all
    @State private var isShowingShareSheet = false

    // Computed Display Times
    var currentTime: String {
        let current = totalDurationSeconds * progressValue
        let minutes = Int(current) / 60
        let seconds = Int(current) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var remainingTime: String {
        let remaining = totalDurationSeconds * (1.0 - progressValue)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "-%d:%02d", minutes, seconds)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(red: 0.18, green: 0.20, blue: 0.18)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer(minLength: 10)
                
                topBar
                albumArt
                songInfo
                progressBar
                playbackControls
                bottomControls
                lyricsSection
                
                Spacer(minLength: 10)
            }
            .padding(.horizontal)
            .foregroundColor(.white)
        }
        // Share Sheet Modifier
        .sheet(isPresented: $isShowingShareSheet) {
            // Constructs items to share using the ItemBuilder.
            let itemsToShare = { () -> [Any] in
                "\(songTitle) - \(artistName)"
                if let url = songURL { url }
                if let image = UIImage(named: albumArtImageName) { image }
            }()
            
            if !itemsToShare.isEmpty {
                ActivityViewController(activityItems: itemsToShare)
                    .preferredColorScheme(.dark)
            } else {
                Text("Nothing available to share")
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isShowingShareSheet = false
                        }
                    }
            }
        }
    }
    
    // MARK: - UI Components

    private var topBar: some View {
        HStack {
            Button {
                // Placeholder action for dismissing
            } label: {
                Image(systemName: "chevron.down")
                    .font(.body.weight(.semibold))
            }
            Spacer()
            Text("Liked Songs")
                .font(.footnote.weight(.bold))
            Spacer()
            Button {
                // Placeholder action for options
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body.weight(.semibold))
            }
        }
        .padding(.vertical, 5)
    }

    private var albumArt: some View {
        Image(albumArtImageName)
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.vertical)
    }

    private var songInfo: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(songTitle)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)
                Text(artistName)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            Spacer()
            Button {
                isLiked.toggle()
            } label: {
                Image(systemName: isLiked ? "checkmark.circle.fill" : "plus.circle")
                    .font(.title2)
                    .foregroundColor(isLiked ? .green : .white.opacity(0.7))
            }
        }
    }

    private var progressBar: some View {
        VStack(spacing: 4) {
            Slider(value: $progressValue, in: 0...1)
                .accentColor(.white)
            HStack {
                Text(currentTime)
                Spacer()
                Text(remainingTime)
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical)
    }

    private var playbackControls: some View {
        HStack(spacing: 25) {
            Button {
                isShuffling.toggle()
            } label: {
                Image(systemName: "shuffle")
                    .font(.title2)
                    .foregroundColor(isShuffling ? .green : .white.opacity(0.7))
            }
            Button {
                // Placeholder action for previous track
            } label: {
                Image(systemName: "backward.fill")
                    .font(.title)
                    .fontWeight(.bold)
            }
            Button {
                isPlaying.toggle()
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .foregroundColor(.white)
            }
            Button {
                // Placeholder action for next track
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title)
                    .fontWeight(.bold)
            }
            Button {
                repeatMode = (repeatMode + 1) % 3
            } label: {
                Image(systemName: repeatMode == 1 ? "repeat.1" : "repeat")
                    .font(.title2)
                    .foregroundColor(repeatMode != 0 ? .green : .white.opacity(0.7))
            }
        }
    }

    private var bottomControls: some View {
        HStack {
            Button {
                // Placeholder action for external speaker
            } label: {
                Image(systemName: "hifispeaker.and.appletv")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            Button {
                isShowingShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.trailing, 5)
            Button {
                // Placeholder action for list view (lyrics section handles share now)
            } label: {
                Image(systemName: "list.bullet")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.top, 10)
    }

    private var lyricsSection: some View {
        HStack {
            Text("Lyrics")
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
            Button {
                isShowingShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.trailing, 5)
            Button {
                // Placeholder action for expanding lyrics
            } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
        .padding(.top)
    }
}

// MARK: - Share Sheet Wrapper (ActivityViewController)

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            print("Share sheet completed: \(completed), Activity: \(activityType?.rawValue ?? "none")")
            if let error = error {
                print("Error sharing: \(error.localizedDescription)")
            }
        }
        controller.activityItemsConfiguration = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No dynamic updates required for this simple use case.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, UIActivityItemsConfigurationReading, LPLinkMetadataSource {
        var parent: ActivityViewController
        private var linkMetadata: LPLinkMetadata?

        init(_ parent: ActivityViewController) {
            self.parent = parent
            super.init()
            self.linkMetadata = createLinkMetadata()
        }

        var itemProvidersForActivityItemsConfiguration: [NSItemProvider] {
            parent.activityItems.compactMap { item -> NSItemProvider? in
                if let string = item as? String {
                    return NSItemProvider(object: string as NSString)
                } else if let url = item as? URL {
                    let provider = NSItemProvider(object: url as NSURL)
                    if #available(iOS 13.0, *) {
                        provider.registerObject(linkMetadata ?? LPLinkMetadata(), visibility: .all)
                    }
                    return provider
                } else if let image = item as? UIImage {
                    return NSItemProvider(object: image)
                }
                return nil
            }
        }
        
        @available(iOS 13.0, *)
        var applicationActivitiesForActivityItemsConfiguration: [UIActivity]? {
            parent.applicationActivities
        }
        
        @available(iOS 13.0, *)
        func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
            linkMetadata
        }
        
        @available(iOS 13.0, *)
        private func createLinkMetadata() -> LPLinkMetadata? {
            guard let url = parent.activityItems.first(where: { $0 is URL }) as? URL else { return nil }
            let metadata = LPLinkMetadata()
            metadata.url = url
            metadata.originalURL = url
            if let title = parent.activityItems.first(where: { $0 is String }) as? String {
                metadata.title = title
            } else {
                metadata.title = "Shared Content"
            }
            if let image = parent.activityItems.first(where: { $0 is UIImage }) as? UIImage {
                metadata.imageProvider = NSItemProvider(object: image)
            }
            return metadata
        }
        
        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            parent.activityItems.first ?? ""
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            parent.activityItems.first
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
            parent.activityItems.first(where: { $0 is String }) as? String ?? "Check this out"
        }
    }
}

// MARK: - Preview

struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerView()
            .preferredColorScheme(.dark)
    }
}
