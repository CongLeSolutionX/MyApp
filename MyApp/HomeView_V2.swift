////
////  HomeView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//
//import SwiftUI
//
//// MARK: - Data Models
//
//struct Story: Identifiable {
//    let id = UUID()
//    let userName: String? // Optional for "Create Story"
//    let profileImageName: String? // Optional for "Create Story"
//    let storyImageName: String
//    var isCreateStory: Bool = false
//}
//
//struct FeedPost: Identifiable {
//    let id = UUID()
//    let userName: String
//    let profileImageName: String
//    let timestamp: String
//    let postText: String
//    let postImageNames: [String]
//}
//
//// Enum for Tab Bar Items
//enum FBTabBarItem: String, CaseIterable, Identifiable {
//    case home, friends, video, feeds, notifications, menu
//
//    var id: String { self.rawValue }
//
//    var title: String {
//        return self == .feeds ? "" : self.rawValue.capitalized
//    }
//
//    var iconName: String {
//        switch self {
//        case .home: return "house"
//        case .friends: return "person.2"
//        case .video: return "play.tv"
//        case .feeds: return "list.bullet.rectangle.portrait"
//        case .notifications: return "bell"
//        case .menu: return "line.3.horizontal"
//        }
//    }
//
//    var selectedIconName: String {
//        switch self {
//        case .home: return "house.fill"
//        case .friends: return "person.2.fill"
//        case .video: return "play.tv.fill"
//        case .feeds: return "list.bullet.rectangle.portrait.fill"
//        case .notifications: return "bell.fill"
//        case .menu: return "line.3.horizontal"
//        }
//    }
//
//     @ViewBuilder
//     var view: some View {
//         switch self {
//         case .home:
//             FacebookHomeFeedView()
//         default:
//             PlaceholderTabView(title: self.rawValue.capitalized)
//         }
//     }
//}
//
//// MARK: - Sample Data
//
//var storiesData: [Story] = [
//    Story(userName: nil, profileImageName: "profile_cong", storyImageName: "story_create_bg", isCreateStory: true),
//    Story(userName: "Your story", profileImageName: "profile_cong", storyImageName: "story_cong"),
//    Story(userName: "Amelia Tran", profileImageName: "profile_amelia", storyImageName: "story_amelia"),
//    Story(userName: "Phuong", profileImageName: "profile_phuong", storyImageName: "story_phuong"),
//    Story(userName: "Test User 1", profileImageName: "person.circle", storyImageName: "placeholder_image_1"),
//    Story(userName: "Test User 2", profileImageName: "person.crop.circle.fill", storyImageName: "placeholder_image_2")
//]
//
//let feedPostsData: [FeedPost] = [
//    FeedPost(userName: "Raymond de Lacaze", profileImageName: "profile_raymond", timestamp: "17m", postText: "Don't Believe the Vibe: Best Practices for Coding with AI Agents (Pascal Biese, April 2025)... See more", postImageNames: ["post_ai_1", "post_ai_2"]),
//    FeedPost(userName: "Jane Doe", profileImageName: "profile_jane", timestamp: "1h", postText: "Just enjoying a beautiful sunset! Absolutely stunning views tonight. #nature #sunset #beautiful", postImageNames: ["placeholder_image_1"]),
//    FeedPost(userName: "John Appleseed", profileImageName: "profile_john", timestamp: "3h", postText: "Thinking about the weekend plans. Any suggestions for fun activities around the city? Let me know! 😊", postImageNames: [])
//]
//
//// MARK: - Reusable & Component Views
//
//// --- Navigation Bar ---
//struct FacebookNavigationBar: View {
//     @Binding var messengerBadgeCount: Int
//
//    var body: some View {
//        HStack(spacing: 12) {
//            Text("facebook")
//                .font(.system(size: 30, weight: .bold))
//                .foregroundColor(Color.blue)
//
//            Spacer()
//
//            HStack(spacing: 12) {
//                NavBarIcon(systemName: "plus")
//                NavBarIcon(systemName: "magnifyingglass")
//                NavBarIcon(systemName: "message.fill", badgeCount: $messengerBadgeCount)
//            }
//        }
//        .padding(.horizontal, 16)
//        .frame(height: 44)
//        .background(Color(UIColor.systemBackground))
//    }
//}
//
//struct NavBarIcon: View {
//    let systemName: String
//    @Binding var badgeCount: Int
//
//    init(systemName: String, badgeCount: Binding<Int> = .constant(0)) {
//        self.systemName = systemName
//        self._badgeCount = badgeCount
//    }
//
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            Button {
//                print("\(systemName) tapped")
//            } label: {
//                Image(systemName: systemName)
//                    .font(.system(size: 18, weight: .bold))
//                    .foregroundColor(.primary)
//                    .frame(width: 36, height: 36)
//                    .background(Color(UIColor.systemGray5))
//                    .clipShape(Circle())
//            }
//
//             if badgeCount > 0 {
//                 Text("\(badgeCount)")
//                     .font(.system(size: 10, weight: .bold))
//                     .foregroundColor(.white)
//                     .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
//                     .background(Color.red)
//                     .clipShape(Capsule())
//                     .offset(x: 6, y: -6)
//                     .zIndex(1)
//             }
//        }
//    }
//}
//
//// --- Status Update Prompt ---
//struct StatusUpdateView: View {
//    let profileImageName: String
//
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(profileImageName)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 40, height: 40)
//                .clipShape(Circle())
//
//            Text("What's on your mind?")
//                .foregroundColor(.secondary)
//
//            Spacer()
//
//            Image(systemName: "photo.on.rectangle.angled")
//                .font(.title2)
//                .foregroundColor(.green)
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 10)
//        .background(Color(UIColor.systemBackground))
//    }
//}
//
//// --- Stories Section ---
//struct StoriesScrollView: View {
//    let stories: [Story]
//
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 8) {
//                ForEach(stories) { story in
//                    StoryCardView(story: story)
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 10)
//        }
//        .background(Color(UIColor.systemBackground))
//    }
//}
//
//struct StoryCardView: View {
//    let story: Story
//    private let cardWidth: CGFloat = 110
//    private let cardHeight: CGFloat = 190
//    private let createStoryExtraHeight: CGFloat = 50
//
//    var body: some View {
//        Button {
//             print("Tapped story: \(story.userName ?? (story.isCreateStory ? "Create" : "Unknown"))")
//        } label: {
//            ZStack(alignment: story.isCreateStory ? .bottom : .bottomLeading) {
//                 Image(story.storyImageName)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: cardWidth, height: cardHeight)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                 LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.1), .black.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
//                      .frame(width: cardWidth, height: cardHeight)
//                      .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                 if story.isCreateStory {
//                     VStack(spacing: 0) {
//                         Spacer()
//                         Image(systemName: "plus")
//                             .font(.system(size: 20, weight: .bold))
//                             .foregroundColor(.white)
//                             .frame(width: 40, height: 40)
//                             .background(Color.blue)
//                             .clipShape(Circle())
//                             .overlay(
//                                 Circle().stroke(Color(UIColor.systemBackground), lineWidth: 3)
//                             )
//                             .offset(y: 20)
//                             .zIndex(1)
//                         createStoryTextLabel
//                     }
//                 } else {
//                     VStack(alignment: .leading, spacing: 4) {
//                         if let profileImg = story.profileImageName {
//                             Image(profileImg)
//                                 .resizable()
//                                 .scaledToFill()
//                                 .frame(width: 36, height: 36)
//                                 .clipShape(Circle())
//                                 .overlay(
//                                     Circle().stroke(Color.blue, lineWidth: 2.5)
//                                 )
//                         }
//                         if let name = story.userName {
//                             Text(name)
//                                 .font(.system(size: 13, weight: .semibold))
//                                 .foregroundColor(.white)
//                                 .lineLimit(1)
//                                 .shadow(radius: 2)
//                         }
//                     }
//                     .padding(8)
//                 }
//            }
//             .frame(width: cardWidth, height: story.isCreateStory ? cardHeight + createStoryExtraHeight : cardHeight)
//             .background(Color(UIColor.secondarySystemGroupedBackground))
//             .cornerRadius(12)
//             .contentShape(Rectangle())
//        }
//        .buttonStyle(.plain)
//    }
//
//    @ViewBuilder
//     private var createStoryTextLabel: some View {
//          Text("Create\nstory")
//             .font(.system(size: 13, weight: .semibold))
//             .foregroundColor(.primary)
//             .multilineTextAlignment(.center)
//             .frame(width: cardWidth, height: createStoryExtraHeight)
//             .padding(.top, 5)
//     }
//}
//
//// --- Feed Post Components ---
//struct PostHeaderView: View {
//    let post: FeedPost
//
//    var body: some View {
//        HStack(spacing: 8) {
//            Image(post.profileImageName)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 40, height: 40)
//                .clipShape(Circle())
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(post.userName)
//                    .font(.headline)
//                    .fontWeight(.medium)
//                HStack(spacing: 4) {
//                    Text(post.timestamp)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    Image(systemName: "globe.americas.fill")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//            }
//
//            Spacer()
//
//            Button { print("More tapped") } label: {
//                 Image(systemName: "ellipsis")
//                     .foregroundColor(.secondary)
//                     .frame(width: 44, height: 44, alignment: .trailing)
//             }
//             Button { print("Close tapped") } label: {
//                 Image(systemName: "xmark")
//                     .foregroundColor(.secondary)
//                     .frame(width: 44, height: 44, alignment: .trailing)
//             }
//        }
//        .padding(.horizontal, 16)
//        .padding(.top, 12)
//        .padding(.bottom, 8)
//    }
//}
//
//struct PostContentView: View {
//    let text: String
//
//    var body: some View {
//         if !text.isEmpty {
//            Text(text)
//                .font(.system(size: 16))
//                .lineSpacing(4)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 16)
//                .padding(.bottom, 8)
//         } else {
//              EmptyView()
//          }
//    }
//}
//
//struct PostMediaView: View {
//    let imageNames: [String]
//
//    var body: some View {
//        if imageNames.isEmpty {
//            EmptyView()
//        } else if imageNames.count == 1 {
//            Image(imageNames[0])
//                .resizable()
//                .scaledToFit()
//                .frame(maxWidth: .infinity)
//                .clipped()
//        } else {
//            HStack(spacing: 2) {
//                ForEach(imageNames, id: \.self) { imageName in
//                    Image(imageName)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(height: 300)
//                        .clipped()
//                }
//            }
//            .frame(maxWidth: .infinity)
//            .clipped()
//        }
//    }
//}
//
//struct PostActionsView: View {
//    @State private var isLiked: Bool = false
//
//    var body: some View {
//        VStack(spacing: 0) {
//            Divider()
//                 .padding(.horizontal, 16)
//                 .padding(.vertical, 8)
//
//            HStack {
//                 ActionButton(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup",
//                              label: "Like",
//                              isActive: $isLiked,
//                              activeColor: .blue)
//                 Spacer()
//                 ActionButton(systemName: "message", label: "Comment")
//                 Spacer()
//                 ActionButton(systemName: "arrowshape.turn.up.forward", label: "Share")
//            }
//            .padding(.horizontal, 25)
//            .padding(.bottom, 12)
//        }
//    }
//}
//
//struct ActionButton: View {
//    let systemName: String
//    let label: String
//    @Binding var isActive: Bool
//    var activeColor: Color = .accentColor
//    var defaultColor: Color = .secondary
//
//    // Initializer for non-stateful buttons
//     init(systemName: String, label: String) {
//         self.systemName = systemName
//         self.label = label
//         // FIX: Use Binding.constant()
//         self._isActive = Binding.constant(false)
//         self.activeColor = .secondary
//         self.defaultColor = .secondary
//     }
//
//     // Initializer for stateful buttons
//     init(systemName: String, label: String, isActive: Binding<Bool>, activeColor: Color, defaultColor: Color = .secondary) {
//         self.systemName = systemName
//         self.label = label
//         self._isActive = isActive
//         self.activeColor = activeColor
//         self.defaultColor = defaultColor
//     }
//
//    var body: some View {
//        Button {
//            // FIX: Check if the binding passed is the non-stateful default one
////             if self._isActive != Binding.constant(false) {
////                 isActive.toggle()
////                 print("\(label) button toggled: \(isActive)")
////             } else {
////                 print("\(label) button tapped (non-stateful)")
////             }
//        } label: {
//            HStack(spacing: 5) {
//                Image(systemName: systemName)
//                Text(label)
//            }
//            .font(.subheadline)
//            .fontWeight(.medium)
//            .foregroundColor(isActive ? activeColor : defaultColor)
//        }
//         .padding(.vertical, 4)
//         .contentShape(Rectangle())
//    }
//}
//
//// -- Generic Placeholder for other Tabs ---
// struct PlaceholderTabView: View {
//     let title: String
//     var body: some View {
//          ZStack {
//               Color(UIColor.systemGroupedBackground).ignoresSafeArea()
//               Text("\(title) Screen")
//                   .font(.largeTitle)
//                   .foregroundColor(.secondary)
//           }
//     }
// }
//
//// --- Feed Post Container ---
//struct FeedPostView: View {
//    let post: FeedPost
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            PostHeaderView(post: post)
//            PostContentView(text: post.postText)
//            PostMediaView(imageNames: post.postImageNames)
//            PostActionsView()
//        }
//        .background(Color(UIColor.systemBackground))
//    }
//}
//
//// MARK: - Main Home Feed View
//
//struct FacebookHomeFeedView: View {
//    @State private var messengerBadgeCount: Int = 5
//
//    var body: some View {
//        VStack(spacing: 0) {
//             FacebookNavigationBar(messengerBadgeCount: $messengerBadgeCount)
//
//            ScrollView {
//                LazyVStack(spacing: 0) {
//                    StatusUpdateView(profileImageName: "profile_cong")
//                    Divider()
//                    StoriesScrollView(stories: storiesData)
//                     Rectangle()
//                         .fill(Color(UIColor.systemGray5))
//                         .frame(height: 8)
//
//                    ForEach(feedPostsData) { post in
//                        FeedPostView(post: post)
//                         Rectangle()
//                             .fill(Color(UIColor.systemGray5))
//                             .frame(height: 8)
//                    }
//                    Spacer(minLength: 80)
//                }
//            }
//            .background(Color(UIColor.secondarySystemGroupedBackground))
//            .coordinateSpace(name: "scroll")
//            .refreshable {
//                 print("Refreshing feed...")
//                 try? await Task.sleep(nanoseconds: 1_500_000_000)
//                 messengerBadgeCount = Int.random(in: 0...10)
//                 print("Feed refreshed!")
//            }
//        }
//         .background(Color(UIColor.secondarySystemGroupedBackground))
//         .ignoresSafeArea(edges: .bottom)
//    }
//}
//
//// MARK: - Custom Tab Bar View
//
//struct FacebookTabBarView: View {
//    @Binding var selectedTab: FBTabBarItem
//    // FIX: Specify the type EdgeInsets for the environment value
////    @Environment(\.safeAreaInsets) private var safeAreaInsets: EdgeInsets
//    let menuProfileImageName: String = "profile_cong"
//
//    var body: some View {
//         HStack(alignment: .top) {
//            ForEach(FBTabBarItem.allCases) { item in
//                Spacer()
//                 Button {
//                    selectedTab = item
//                } label: {
//                     VStack(spacing: 3) {
//                         if item == .menu {
//                              Image(menuProfileImageName)
//                                  .resizable()
//                                  .scaledToFill()
//                                  .frame(width: 26, height: 26)
//                                  .clipShape(Circle())
//                                  .overlay(
//                                       Circle().stroke(selectedTab == item ? Color.blue : Color.clear, lineWidth: 1.5)
//                                  )
//                         } else {
//                             Image(systemName: selectedTab == item ? item.selectedIconName : item.iconName)
//                                 .font(.system(size: 24))
//                                 .frame(height: 26)
//                         }
//                         if !item.title.isEmpty {
//                             Text(item.title)
//                                 .font(.system(size: 10))
//                         }
//                    }
//                    .foregroundColor(selectedTab == item ? .blue : .secondary)
//                    .frame(maxWidth: .infinity)
//                 }
//                Spacer()
//            }
//         }
//         .frame(height: 50)
////         .padding(.bottom, safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom / 2 : 0)
//         .padding(.top, 5)
//         .background(.thinMaterial)
//         .compositingGroup()
//         .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: -1)
//    }
//}
//
//// MARK: - Main Container View
//
//struct FacebookMainView: View {
//    @State private var selectedTab: FBTabBarItem = .home
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//             selectedTab.view
//             FacebookTabBarView(selectedTab: $selectedTab)
//         }
//         .ignoresSafeArea(.keyboard)
//    }
//}
//
//// MARK: - App Entry Point
//
//@main
//struct FacebookCloneAppFixed: App { // RENAME this App struct
//    var body: some Scene {
//        WindowGroup {
//            FacebookMainView()
//        }
//    }
//}
//
//// MARK: - Previews
//
//#Preview("Full Screen") {
//    FacebookMainView()
//}
//
//// ... other previews remain the same ...
//
//#Preview("Tab Bar") {
//     FacebookTabBarView(selectedTab: .constant(.home))
//         .padding(.horizontal)
//         .background(Color(UIColor.systemBackground))
//}
