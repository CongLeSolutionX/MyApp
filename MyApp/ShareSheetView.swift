////
////  ShareSheetView.swift
////  MyApp
////
////  Created by Cong Le on 4/1/25.
////
//
//import SwiftUI
//
//// MARK: - Share Target Data Structure
//struct ShareTarget: Identifiable {
//    let id = UUID()
//    let iconName: String // SF Symbol name or Asset name
//    let label: String
//    let iconColor: Color? // Optional: Specific background color for the icon circle
//    let isSFSymbol: Bool // Flag to differentiate SF Symbols from asset images
//    
//    // Example Initializer for SF Symbols
//    init(sfSymbolName: String, label: String, iconBgColor: Color? = Color(.darkGray) ) {
//        self.iconName = sfSymbolName
//        self.label = label
//        self.iconColor = iconBgColor
//        self.isSFSymbol = true
//    }
//    
//    // Example Initializer for Asset Images (like app logos)
//    init(assetName: String, label: String, iconBgColor: Color? = nil) { // App icons often have their own color
//        self.iconName = assetName
//        self.label = label
//        self.iconColor = iconBgColor
//        self.isSFSymbol = false
//    }
//}
//
//// MARK: - Share Sheet View Implementation
//struct ShareSheetView: View {
//    @State private var isEditing = false // Tracks if the edit mode is active
//    
//    // Placeholder data for share targets (replace icons/colors as needed)
//    let shareTargets: [ShareTarget] = [
//        ShareTarget(sfSymbolName: "link", label: "Copy link"),
//        ShareTarget(assetName: "facebook_logo", label: "Stories", iconBgColor: Color(red: 0.1, green: 0.48, blue: 0.96)), // Placeholder blue
//        ShareTarget(assetName: "tiktok_logo", label: "TikTok", iconBgColor: .black), // Placeholder black
//        ShareTarget(assetName: "whatsapp_logo", label: "WhatsApp", iconBgColor: Color(red: 0.15, green: 0.8, blue: 0.28)), // Placeholder green
//        ShareTarget(assetName: "instagram_logo", label: "Stories", iconBgColor: nil), // Placeholder, needs gradient or asset
//        ShareTarget(assetName: "messenger_logo", label: "Messages", iconBgColor: Color(red: 0, green: 0.5, blue: 1.0)), // Placeholder blue
//        // Add more targets...
//    ]
//    
//    @State private var selectedColorIndex: Int = 0 // To track selected color/style
//    let backgroundColors: [Color] = [.clear, .gray.opacity(0.5), .black] // Example background options for circles
//    
//    var body: some View {
//        ZStack {
//            // Main Sheet Background (Very Dark)
//            Color(red: 0.08, green: 0.08, blue: 0.09)
//                .ignoresSafeArea()
//            
//            VStack(spacing: 0) { // No spacing between major sections
//                
//                // Optional: Add a grabber handle
//                Capsule()
//                    .fill(Color.gray.opacity(0.5))
//                    .frame(width: 40, height: 5)
//                    .padding(.vertical, 8)
//                
//                // 1. Content Preview Section
//                contentPreview
//                    .padding(.horizontal)
//                    .padding(.bottom) // Space before share icons
//                
//                // 2. Share Actions Section
//                shareActions
//                
//                Spacer() // Pushes content up if needed
//            }
//        }
//        // Ensure text is readable on the dark background
//        .foregroundColor(.white)
//    }
//    
//    // MARK: - UI Components for Share Sheet
//    
//    private var contentPreview: some View {
//        VStack {
//            // Main ZStack for Background Layering
//            ZStack {
//                // Conditional Background (Lined Paper or Green)
//                if isEditing {
//                    Image("lined_paper_background") // *** Needs Asset ***
//                        .resizable()
//                        .aspectRatio(contentMode: .fill) // Fill the area
//                } else {
//                    // Original Dark Green Rounded Background
//                    RoundedRectangle(cornerRadius: 15)
//                        .fill(Color(red: 0.18, green: 0.25, blue: 0.18))
//                }
//                
//                // Add Doodles in Edit Mode (Behind the Card)
//                if isEditing {
//                    // Position these doodle images using .offset or precise frames
//                    // These are placeholders - adjust images and offsets
//                    Image("doodle_star_scribble") // *** Needs Asset ***
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 80)
//                        .rotationEffect(.degrees(-15))
//                        .offset(x: -120, y: -150)
//                    
//                    Image("doodle_heart_notes") // *** Needs Asset ***
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100)
//                        .rotationEffect(.degrees(10))
//                        .offset(x: -100, y: 100)
//                    
//                    Image("doodle_pink_marks") // *** Needs Asset ***
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 120)
//                        .offset(x: 100, y: -140)
//                    
//                    Image("doodle_red_marks") // *** Needs Asset ***
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100)
//                        .offset(x: 110, y: 80)
//                    
//                }
//                
//                // The Card Content (Style changes based on isEditing)
//                VStack(spacing: 8) {
//                    Image("My-meme-microphone")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .cornerRadius(isEditing ? 4 : 8) // Slightly sharper corners?
//                    // Less padding inside for polaroid border effect
//                        .padding(isEditing ? EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8) : EdgeInsets(top: 20, leading: 40, bottom: 10, trailing: 40))
//                    
//                    Text("để tôi ôm em bằng giai điệu này")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, isEditing ? 8 : 20)
//                        .foregroundColor(isEditing ? .black : .white) // Text color changes
//                    
//                    Text("CongLeSolutionX")
//                        .font(.subheadline)
//                        .foregroundColor(isEditing ? .black.opacity(0.7) : .gray) // Text color changes
//                        .padding(.bottom, isEditing ? 0 : 10)
//                    
//                    HStack {
//                        Image("spotify_icon")
//                            .resizable()
//                            .renderingMode(.template)
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 18, height: 18)
//                        Text("Spotify")
//                            .font(.caption)
//                            .fontWeight(.medium)
//                    }
//                    // Icon/Text color changes
//                    .foregroundColor(isEditing ? .black : .white)
//                    // Thicker bottom padding for polaroid effect
//                    .padding(.bottom, isEditing ? 16 : 20)
//                    .opacity(isEditing ? 1.0 : 1.0) // Ensure it's visible
//                    
//                }
//                // Apply the background *after* padding for the polaroid border effect
//                .background(isEditing ? Color(white: 0.97) : Color.black) // Off-white vs Black
//                .cornerRadius(isEditing ? 6 : 10) // Adjust corner radius
//                // Overall padding within the ZStack (Green/Paper)
//                .padding(isEditing ? 15 : 20) // Slightly less padding in edit mode?
//                .shadow(radius: isEditing ? 5 : 0) // Optional shadow in edit mode
//                
//            }
//            // Clip the ZStack to its rounded corners if using Image background
//            .cornerRadius(15)
//            .clipped() // Important if the paper image goes beyond bounds
//            
//            // Color/Style Selection Row (Modified Edit Button)
//            HStack(spacing: 15) {
//                styleCircle(index: 0, color: Color(red: 0.35, green: 0.4, blue: 0.35)) // Darker green/gray
//                styleCircle(index: 1, gradient: LinearGradient(colors: [Color(white: 0.4), .black], startPoint: .topLeading, endPoint: .bottomTrailing)) // Darker gradient
//                styleCircle(index: 2, color: .black)
//                
//                Spacer()
//                
//                // -- EDITED: Edit Button Action --
//                Button {
//                    withAnimation(.easeInOut(duration: 0.3)) { // Add animation
//                        isEditing.toggle()
//                    }
//                } label: {
//                    Image(systemName: "square.and.pencil")
//                        .font(.title2)
//                        .foregroundColor(.white.opacity(0.8))
//                        .frame(width: 35, height: 35)
//                        .background(
//                            Circle()
//                                .fill(Color.white.opacity(0.2)) // Slightly visible background
//                            //.stroke(Color.gray, lineWidth: 1) // Keep or remove stroke? Screenshot looks filled.
//                        )
//                }
//                // -- -------------------------- --
//            }
//            .padding(.top)
//            .padding(.horizontal, 20)
//            
//        }
//    }
//    
//    // Helper view for the style selection circles
//    @ViewBuilder
//    private func styleCircle(index: Int, color: Color? = nil, gradient: LinearGradient? = nil, strokeColor: Color = .clear) -> some View { // Default to no stroke
//        Button {
//            // Potentially disable color changing when isEditing? Or change what it does.
//            if !isEditing {
//                selectedColorIndex = index
//            } else {
//                // Action in edit mode? Maybe cycle through doodle styles? (Advanced)
//                print("Style tapped in edit mode")
//            }
//        } label: {
//            ZStack {
//                let isActive = selectedColorIndex == index && !isEditing
//                
//                if let gradient = gradient {
//                    Circle().fill(gradient)
//                } else if let color = color {
//                    Circle().fill(color)
//                }
//                
//                // Add outline based on selection AND if not editing
//                Circle()
//                    .stroke(isActive ? .white : strokeColor, lineWidth: isActive ? 2 : 0) // Show stroke only when selected and not editing
//            }
//            .frame(width: 35, height: 35)
//        }
//    }
//    private var shareActions: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(alignment: .top, spacing: 20) { // Align items to the top, add spacing
//                ForEach(shareTargets) { target in
//                    Button {
//                        // --- ADD ACTION FOR EACH SHARE TARGET ---
//                        print("Share to \(target.label)")
//                        // e.g., copyToClipboard(), openFacebookStories(), etc.
//                        // --- -------------------------------- ---
//                    } label: {
//                        VStack(spacing: 8) {
//                            ZStack {
//                                // Background circle if color is provided
//                                if let bgColor = target.iconColor {
//                                    Circle().fill(bgColor)
//                                } else if !target.isSFSymbol {
//                                    // Placeholder gradient/color for asset-based icons without explicit color
//                                    // Attempting Instagram-like gradient
//                                    if target.iconName.contains("instagram") {
//                                        Circle().fill(
//                                            RadialGradient(
//                                                gradient: Gradient(colors: [.yellow, .red, .purple]),
//                                                center: .center,
//                                                startRadius: 0,
//                                                endRadius: 30 // Adjust radius based on frame size
//                                            )
//                                        )
//                                    } else {
//                                        Circle().fill(Color(.darkGray)) // Default if no color specified
//                                    }
//                                } else {
//                                    Circle().fill(Color(.darkGray)) // Default for SF Symbols
//                                }
//                                
//                                // The Icon Image
//                                if target.isSFSymbol {
//                                    Image(systemName: target.iconName)
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .padding(15) // Adjust padding inside the circle
//                                        .foregroundColor(.white) // Color for SF Symbols
//                                } else {
//                                    // Assume Assets for app logos
//                                    Image(target.iconName) // Needs assets named e.g. "facebook_logo.png"
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .padding(target.iconColor == .black ? 12 : 10) // Less padding if icon is complex (like TikTok)
//                                }
//                            }
//                            .frame(width: 60, height: 60) // Size of the circular icon area
//                            .clipShape(Circle()) // Ensure icon is contained
//                            
//                            Text(target.label)
//                                .font(.caption)
//                                .foregroundColor(.gray) // Label color
//                        }
//                    }
//                }
//            }
//            .padding(.horizontal) // Padding for the scroll view content
//            .padding(.top) // Space above the icons
//        }
//        .frame(height: 100) // Give the scroll view a defined height
//        .padding(.bottom, 30) // Space at the very bottom
//    }
//}
//
//// MARK: - Share Sheet Preview
//
//
//#Preview("Share Sheet View") {
//    ShareSheetView()
//        .preferredColorScheme(.dark)
//        .onAppear {
//            // Add placeholder images to Assets:
//            // album_art_placeholder.jpg
//            // spotify_icon.png (ideally a template image)
//            // facebook_logo.png
//            // tiktok_logo.png
//            // whatsapp_logo.png
//            // instagram_logo.png
//            // messenger_logo.png
//        }
//}
//
//struct ShareSheetViewWithEdit_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview in both states
//        VStack {
//            Text("Default State").font(.caption).foregroundColor(.gray)
//            ShareSheetView()
//            Divider()
//            Text("Editing State").font(.caption).foregroundColor(.gray)
//            ShareSheetView(isEditing: true) // Pass initial state for preview
//        }
//        .preferredColorScheme(.dark)
//        .onAppear {
//            // Add placeholder images to Assets:
//            // album_art_placeholder.jpg
//            // spotify_icon.png
//            // facebook_logo.png
//            // tiktok_logo.png
//            // whatsapp_logo.png
//            // instagram_logo.png
//            // messenger_logo.png
//            // *** NEW ASSETS ***
//            // lined_paper_background.png (or .jpg)
//            // doodle_star_scribble.png
//            // doodle_heart_notes.png
//            // doodle_pink_marks.png
//            // doodle_red_marks.png
//        }
//    }
//}
//
//// Convenience initializer for previewing specific state
//extension ShareSheetView {
//    init(isEditing: Bool) {
//        self._isEditing = State(initialValue: isEditing)
//        // Initialize other state vars if needed for preview
//        self._selectedColorIndex = State(initialValue: 0)
//    }
//}
