////
////  SpotifyHomeView.swift
////  MyApp
////
////  Created by Cong Le on 3/25/25.
////
//
//import SwiftUI
//
//struct SpotifyHomeView: View {
//    var body: some View {
//        ZStack(alignment: .bottom) { // ZStack for overall layout and bottom player
//            ScrollView { // Main scrollable content
//                VStack {
//                    // 1. Status Bar (Simulated)
//                    StatusBarView()
//
//                    // 2. Filter Buttons
//                    FilterButtonsView()
//
//                    // 3. Content Cards (Playlists/Albums)
//                    ContentCardsView()
//
//                    // 4. Podcast Section
//                    PodcastSectionView()
//
//                    // 5. Your Top Mixes Section
//                    TopMixesSectionView() // Scrollable row of smaller cards
//                    
//                    Spacer(minLength: 80) // Add space at bottom for bottom player
//                }
//            }
//            .background(Color.black.edgesIgnoringSafeArea(.all))
//            .foregroundColor(.white)
//            
//            // 6. Bottom Player
//            BottomPlayerView()
//
//            // 7. Tab Bar
//            TabBarView()
//        }
//        .edgesIgnoringSafeArea(.bottom)
//    }
//}
//
//// Component Views (extracted for readability)
//
//struct StatusBarView: View {
//    var body: some View {
//        HStack {
//            Text("7:28")
//            Spacer()
//            HStack {
//                Image(systemName: "speaker.wave.2")
//                Image(systemName: "wifi")
//                Image(systemName: "battery.100")
//                Text("9")
//                    .padding(2)
//                    .background(Circle().fill(Color.red))
//                    .font(.system(size: 10))
//                    .foregroundColor(.white)
//                    .offset(x: -7)
//            }
//        }
//        .padding()
//    }
//}
//
//struct FilterButtonsView: View {
//    let filters = ["C", "All", "Music", "Podcasts", "Audiobooks"]
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(filters, id: \.self) { filter in
//                    Button(action: {
//                        // Handle filter selection
//                    }) {
//                        Text(filter)
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                            .background(
//                                Capsule()
//                                    .fill(filter == "All" ? Color.green : Color.gray.opacity(0.3))
//                            )
//                            .foregroundColor(.white)
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//}
//
//struct ContentCardsView: View {
//    // Dummy data for card content
//    let cardData = [
//        ("The Art of War", "A SPOTIFY AUDIOBOOK", "art_of_war_cover"),
//        ("Khóa Ly Biệt", "Ti", "khoa_ly_biet_cover"),
//        ("Liked Songs", "", "liked_songs_cover"),
//        ("Vicky Nhung Mix", "Vicky Nhung Mix", "vicky_nhung_cover"),
//        ("SLANDER", "", "slander_cover"),
//        ("DICKSON", "" ,"dickson_cover"),
//        ("The Masked Singer Mix", "CA SI MAT NA - The masked singer mix", "masked_singer_cover"),
//        ("Một Nơi Bé Nhỏ Nào Đó (Tet 2025 Movi...", "", "mot_noi_be_nho_cover")
//    ]
//    
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(0..<cardData.count, id: \.self) { index in
//                    let (title, subtitle, imageName) = cardData[index]
//                    VStack(alignment: .leading) {
//                      if !subtitle.isEmpty {
//                          Text(subtitle)
//                              .font(.system(size: 10))
//                              .foregroundColor(.gray)
//                              .padding(.bottom, -5)
//                      }
//
//                      Image(imageName) // Replace with your image loading
//                          .resizable()
//                          .aspectRatio(1, contentMode: .fit)
//                          .frame(width: 100)
//                          .cornerRadius(5)
//                          
//                      Text(title)
//                          .font(.headline)
//
//                    }
//
//                    .frame(width: 100)
//                    .padding()
//
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//    struct PodcastSectionView: View {
//        var body: some View {
//            VStack(alignment: .leading) {
//                Text("Picked for you")
//                    .font(.title3)
//                    .fontWeight(.bold)
//                    .padding(.horizontal)
//
//                Text("How We're Approaching Volatility in 2025")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .padding(.horizontal)
//                    .padding(.bottom, 5)
//
//                ZStack(alignment: .bottomLeading) {
//                    Image("podcast_preview") // Replace with your image loading
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(maxWidth: .infinity)
//                        .cornerRadius(10)
//
//                    HStack {
//                        Image(systemName: "xmark.circle")
//                        Text("Preview episode")
//                    }
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 5)
//                    .background(Capsule().fill(Color.black.opacity(0.7)))
//                    .foregroundColor(.white)
//                    .font(.system(size: 12))
//                    .padding()
//                    .offset(x: 10, y: -140)
//
//                  HStack(alignment: .bottom) {
//                      Spacer()
//                    HStack{
//                        Image(systemName: "plus.circle.fill")
//                            .font(.largeTitle)
//                            .colorInvert()
//                        Image(systemName: "play.circle.fill")
//                            .font(.system(size: 50))
//                            .background(Circle().stroke(Color.gray, lineWidth: 3))
//                            .shadow(color: .red, radius: .pi)
//                    }
//                        
//                    }.padding()
//                        .offset(y: -10)
//                }
//                .padding(.horizontal)
//            }
//        }
//    }
//
//struct TopMixesSectionView: View {
//    let topMixesData = [
//          TopMix(title: "Rất Lâu Rồi Mới Khóc", artist: "Quốc Thiên", imageName: "My-meme-red-wine-glass")
//    ]
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Your top mixes")
//                .font(.title3)
//                .fontWeight(.bold)
//                .padding(.horizontal)
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    ForEach(topMixesData) { mix in
//                        TopMixCardView(mix: mix)
//                    }
//                }
//                .padding(.horizontal)
//            }
//        }
//    }
//}
//
//struct TopMix: Identifiable {
//    let id = UUID()
//    let title: String
//    let artist: String
//    let imageName: String
//}
//
//struct TopMixCardView: View {
//    let mix: TopMix
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            Image(mix.imageName) // Replace with your image loading
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 200, height: 120)
//                .cornerRadius(10)
//                .clipped()
//
//            VStack(alignment: .leading) {
//                Text(mix.title)
//                    .font(.headline)
//                    .foregroundColor(.white)
//                Text(mix.artist)
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//            }
//            .padding(8)
//            .frame(width: 200, alignment: .leading)
//            .background(Color.black.opacity(0.6))
//        }
//        .frame(width: 200, height: 120)
//    }
//}
//
//struct BottomPlayerView: View {
//    var body: some View {
//      ZStack{
//          HStack {
//              Image("rat_lau_roi_cover") // Replace with your image loading
//                  .resizable()
//                  .aspectRatio(contentMode: .fit)
//                  .frame(width: 40, height: 40)
//                  .cornerRadius(5)
//
//              VStack(alignment: .leading) {
//                  Text("Rất Lâu Rồi Mới Khóc - Live Band Version")
//                      .font(.subheadline)
//                  Text("Quốc Thiên")
//                      .font(.system(size: 10))
//                      .foregroundColor(.gray)
//              }
//              Spacer()
//              Image(systemName: "list.bullet.below.rectangle")
//                  .font(.title3)
//              Image(systemName: "play.fill")
//                  .font(.title2)
//          }
//          .padding()
//         
//      }.background(Color(UIColor.secondarySystemBackground))
//        .frame(height: 60)
//    }
//}
//
//struct TabBarView: View {
//    var body: some View {
//      ZStack{
//          HStack {
//              TabBarIcon(iconName: "house.fill", label: "Home")
//              Spacer()
//              TabBarIcon(iconName: "magnifyingglass", label: "Search")
//              Spacer()
//              TabBarIcon(iconName: "list.bullet", label: "Your Library")
//              Spacer()
//              TabBarIcon(iconName: "plus", label: "Create")
//
//          }.padding(.horizontal, 20)
//      }.padding()
//            .background(Color.yellow)
//    }
//}
//
//struct TabBarIcon: View {
//    let iconName: String
//    let label: String
//
//    var body: some View {
//        VStack {
//            Image(systemName: iconName)
//                .font(.title2)
//            Text(label)
//                .font(.system(size: 10))
//        }
//    }
//}
//// Example Image Placeholder (Replace with your image loading)
//extension Image {
//    init(_ imageName: String) {
//        self.init(systemName: "photo") // Default placeholder
//        // In a real app, load from assets or URL here
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyHomeView()
//    }
//}
