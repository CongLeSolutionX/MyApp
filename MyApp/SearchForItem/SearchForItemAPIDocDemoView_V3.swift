////
////  SearchForItemAPIDocDemoView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/16/25.
////
//
//import SwiftUI
//import Combine // Still useful for potential future extensions, though not strictly needed for .task debouncing
//
//// MARK: - Data Models (Mirroring the JSON Structure - Unchanged)
//
//// MARK: - Spotify Search Response Wrapper
//struct SpotifySearchResponse: Codable, Hashable {
//    let albums: Albums
//}
//
//// MARK: - Albums Container
//struct Albums: Codable, Hashable {
//    let href: String
//    let limit: Int
//    let next: String?
//    let offset: Int
//    let previous: String?
//    let total: Int
//    let items: [AlbumItem]
//}
//
//// MARK: - Album Item
//struct AlbumItem: Codable, Identifiable, Hashable {
//    let id: String
//    let album_type: String
//    let total_tracks: Int
//    let available_markets: [String]
//    let external_urls: ExternalUrls
//    let href: String
//    let images: [SpotifyImage]
//    let name: String
//    let release_date: String
//    let release_date_precision: String
//    let type: String
//    let uri: String
//    let artists: [Artist]
//
//    // Helper to get the best image URL (e.g., largest or medium) - Unchanged
//    var bestImageURL: URL? {
//        if let urlString = images.first(where: { $0.width == 640 })?.url {
//             return URL(string: urlString)
//        } else if let urlString = images.first(where: { $0.width == 300 })?.url {
//            return URL(string: urlString)
//        } else if let urlString = images.first?.url {
//             return URL(string: urlString)
//        }
//        return nil
//    }
//
//    // Helper for smaller image in list - Unchanged
//    var listImageURL: URL? {
//         if let urlString = images.first(where: { $0.width == 300 })?.url {
//            return URL(string: urlString)
//        } else if let urlString = images.first(where: { $0.width == 64 })?.url {
//             return URL(string: urlString)
//        } else if let urlString = images.first?.url {
//             return URL(string: urlString)
//        }
//        return nil
//    }
//
//    // Helper to format artist names - Unchanged
//    var formattedArtists: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//
//    // Helper to format release date based on precision - Unchanged
//    func formattedReleaseDate() -> String {
//        switch release_date_precision {
//        case "year":
//            return release_date
//        case "month":
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM"
//            if let date = formatter.date(from: release_date) {
//                formatter.dateFormat = "MMM yyyy"
//                return formatter.string(from: date)
//            }
//            return release_date // Fallback
//        case "day":
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd"
//             if let date = formatter.date(from: release_date) {
//                return date.formatted(date: .long, time: .omitted)
//            }
//            return release_date // Fallback
//        default:
//            return release_date
//        }
//    }
//}
//
//// MARK: - Artist - Unchanged
//struct Artist: Codable, Identifiable, Hashable {
//    let id: String
//    let external_urls: ExternalUrls
//    let href: String
//    let name: String
//    let type: String
//    let uri: String
//}
//
//// MARK: - Image - Unchanged
//struct SpotifyImage: Codable, Hashable {
//    let height: Int?
//    let url: String
//    let width: Int?
//}
//
//// MARK: - External URLs - Unchanged
//struct ExternalUrls: Codable, Hashable {
//    let spotify: String
//}
//
//// MARK: - Sample Data Provider (Unchanged)
//struct SampleData {
//    static let allAlbums: [AlbumItem] = { // Extracted for easier access
//         let jsonString = """
//         {
//           "albums": {
//             "href": "https://api.spotify.com/v1/search?offset=0&limit=20&query=remaster%2520track%3ADoxy%2520artist%3AMiles%2520Davis&type=album&include_external=audio&locale=en-US,en;q%3D0.9,vi;q%3D0.8,ko;q%3D0.7,ja;q%3D0.6",
//             "limit": 20,
//             "next": "https://api.spotify.com/v1/search?offset=20&limit=20&query=remaster%2520track%3ADoxy%2520artist%3AMiles%2520Davis&type=album&include_external=audio&locale=en-US,en;q%3D0.9,vi;q%3D0.8,ko;q%3D0.7,ja;q%3D0.6",
//             "offset": 0,
//             "previous": null,
//             "total": 800,
//             "items": [
//               { "album_type": "album", "total_tracks": 6, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/6KJgxZYve2dbchVjw3MxBQ" }, "href": "https://api.spotify.com/v1/albums/6KJgxZYve2dbchVjw3MxBQ", "id": "6KJgxZYve2dbchVjw3MxBQ", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273528f5d5bc76597cd876e3cb2", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02528f5d5bc76597cd876e3cb2", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851528f5d5bc76597cd876e3cb2", "width": 64 } ], "name": "Steamin' [Rudy Van Gelder edition]", "release_date": "1961", "release_date_precision": "year", "type": "album", "uri": "spotify:album:6KJgxZYve2dbchVjw3MxBQ", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" } ] },
//               { "album_type": "compilation", "total_tracks": 11, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/5SaMVD3JhB3JU9A66Xwj0E" }, "href": "https://api.spotify.com/v1/albums/5SaMVD3JhB3JU9A66Xwj0E", "id": "5SaMVD3JhB3JU9A66Xwj0E", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273f50bf8084da59379dd7f968e", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02f50bf8084da59379dd7f968e", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851f50bf8084da59379dd7f968e", "width": 64 } ], "name": "20th Century Masters: The Millennium Collection: Best Of The '80s", "release_date": "2000-08-08", "release_date_precision": "day", "type": "album", "uri": "spotify:album:5SaMVD3JhB3JU9A66Xwj0E", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/0LyfQWJT6nXafLPZqxe9Of" }, "href": "https://api.spotify.com/v1/artists/0LyfQWJT6nXafLPZqxe9Of", "id": "0LyfQWJT6nXafLPZqxe9Of", "name": "Various Artists", "type": "artist", "uri": "spotify:artist:0LyfQWJT6nXafLPZqxe9Of" } ] },
//               { "album_type": "album", "total_tracks": 35, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/69IMyjpYKbsVfVWJXQDYRo" }, "href": "https://api.spotify.com/v1/albums/69IMyjpYKbsVfVWJXQDYRo", "id": "69IMyjpYKbsVfVWJXQDYRo", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273e486895a3adc04449d2cf352", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02e486895a3adc04449d2cf352", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851e486895a3adc04449d2cf352", "width": 64 } ], "name": "Miles in France 1963 & 1964 - Miles Davis Quintet: The Bootleg Series, Vol. 8", "release_date": "2024-11-08", "release_date_precision": "day", "type": "album", "uri": "spotify:album:69IMyjpYKbsVfVWJXQDYRo", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" } ] },
//               { "album_type": "album", "total_tracks": 11, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/01EFyT5MpC3LYaOzws2Yjv" }, "href": "https://api.spotify.com/v1/albums/01EFyT5MpC3LYaOzws2Yjv", "id": "01EFyT5MpC3LYaOzws2Yjv", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273530f0ab99d541966644e5cbd", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02530f0ab99d541966644e5cbd", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851530f0ab99d541966644e5cbd", "width": 64 } ], "name": "Volume 2 (Vol. 2)", "release_date": "1956-01-01", "release_date_precision": "day", "type": "album", "uri": "spotify:album:01EFyT5MpC3LYaOzws2Yjv", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" } ] },
//               { "album_type": "album", "total_tracks": 20, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/3n0Rai2wkPIKr2CsfRkaNg" }, "href": "https://api.spotify.com/v1/albums/3n0Rai2wkPIKr2CsfRkaNg", "id": "3n0Rai2wkPIKr2CsfRkaNg", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273db1ea13011d360475462d94e", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02db1ea13011d360475462d94e", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851db1ea13011d360475462d94e", "width": 64 } ], "name": "Miles '54: The Prestige Recordings (Remastered 2024)", "release_date": "2024-11-22", "release_date_precision": "day", "type": "album", "uri": "spotify:album:3n0Rai2wkPIKr2CsfRkaNg", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" } ] },
//               { "album_type": "album", "total_tracks": 6, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/0Q0bftWuBSwZAHBKZr0lxB" }, "href": "https://api.spotify.com/v1/albums/0Q0bftWuBSwZAHBKZr0lxB", "id": "0Q0bftWuBSwZAHBKZr0lxB", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273918d4376b1b56318fcc728ca", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02918d4376b1b56318fcc728ca", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851918d4376b1b56318fcc728ca", "width": 64 } ], "name": "Steamin' With The Miles Davis Quintet", "release_date": "1961", "release_date_precision": "year", "type": "album", "uri": "spotify:album:0Q0bftWuBSwZAHBKZr0lxB", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/71Ur25Abq58vksqJINpGdx" }, "href": "https://api.spotify.com/v1/artists/71Ur25Abq58vksqJINpGdx", "id": "71Ur25Abq58vksqJINpGdx", "name": "Miles Davis Quintet", "type": "artist", "uri": "spotify:artist:71Ur25Abq58vksqJINpGdx" } ] },
//               { "album_type": "album", "total_tracks": 21, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/4sb0eMpDn3upAFfyi4q2rw" }, "href": "https://api.spotify.com/v1/albums/4sb0eMpDn3upAFfyi4q2rw", "id": "4sb0eMpDn3upAFfyi4q2rw", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b2730ebc17239b6b18ba88cfb8ca", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e020ebc17239b6b18ba88cfb8ca", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d000048510ebc17239b6b18ba88cfb8ca", "width": 64 } ], "name": "Kind Of Blue (Legacy Edition)", "release_date": "1959-08-17", "release_date_precision": "day", "type": "album", "uri": "spotify:album:4sb0eMpDn3upAFfyi4q2rw", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" } ] },
//               { "album_type": "album", "total_tracks": 14, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/6WOddaa5Vqp8gQZic8ZUw9" }, "href": "https://api.spotify.com/v1/albums/6WOddaa5Vqp8gQZic8ZUw9", "id": "6WOddaa5Vqp8gQZic8ZUw9", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b27375e7a7470a914679d2f90526", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e0275e7a7470a914679d2f90526", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d0000485175e7a7470a914679d2f90526", "width": 64 } ], "name": "Miles Ahead (Expanded Edition)", "release_date": "1957-11", "release_date_precision": "month", "type": "album", "uri": "spotify:album:6WOddaa5Vqp8gQZic8ZUw9", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" } ] },
//               { "album_type": "album", "total_tracks": 9, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/56I4vUYWQ4aXLiyfo8XuZv" }, "href": "https://api.spotify.com/v1/albums/56I4vUYWQ4aXLiyfo8XuZv", "id": "56I4vUYWQ4aXLiyfo8XuZv", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b2735e10a5aca3763224e2050016", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e025e10a5aca3763224e2050016", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d000048515e10a5aca3763224e2050016", "width": 64 } ], "name": "Milestones", "release_date": "1958-04", "release_date_precision": "month", "type": "album", "uri": "spotify:album:56I4vUYWQ4aXLiyfo8XuZv", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" } ] },
//               { "album_type": "compilation", "total_tracks": 244, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/0RPeS6tlJfJt1GQ1XilhkH" }, "href": "https://api.spotify.com/v1/albums/0RPeS6tlJfJt1GQ1XilhkH", "id": "0RPeS6tlJfJt1GQ1XilhkH", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273165ce4e9204e41d651b3f651", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02165ce4e9204e41d651b3f651", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851165ce4e9204e41d651b3f651", "width": 64 } ], "name": "Stax-Volt: The Complete Singles 1959-1968", "release_date": "1991", "release_date_precision": "year", "type": "album", "uri": "spotify:album:0RPeS6tlJfJt1GQ1XilhkH", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/0LyfQWJT6nXafLPZqxe9Of" }, "href": "https://api.spotify.com/v1/artists/0LyfQWJT6nXafLPZqxe9Of", "id": "0LyfQWJT6nXafLPZqxe9Of", "name": "Various Artists", "type": "artist", "uri": "spotify:artist:0LyfQWJT6nXafLPZqxe9Of" } ] },
//               { "album_type": "album", "total_tracks": 11, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/0QWea2w5Y6pSoSWHuc7JMf" }, "href": "https://api.spotify.com/v1/albums/0QWea2w5Y6pSoSWHuc7JMf", "id": "0QWea2w5Y6pSoSWHuc7JMf", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273f44518f7aea6cc64ecca8448", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02f44518f7aea6cc64ecca8448", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851f44518f7aea6cc64ecca8448", "width": 64 } ], "name": "Birth Of The Cool", "release_date": "1957", "release_date_precision": "year", "type": "album", "uri": "spotify:album:0QWea2w5Y6pSoSWHuc7JMf", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" } ] },
//               { "album_type": "album", "total_tracks": 8, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/7buLIJn2VuqsVORghMEvli" }, "href": "https://api.spotify.com/v1/albums/7buLIJn2VuqsVORghMEvli", "id": "7buLIJn2VuqsVORghMEvli", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273e2e871611c36d490252a2e9f", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02e2e871611c36d490252a2e9f", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851e2e871611c36d490252a2e9f", "width": 64 } ], "name": "Workin' With The Miles Davis Quintet", "release_date": "1959", "release_date_precision": "year", "type": "album", "uri": "spotify:album:7buLIJn2VuqsVORghMEvli", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/71Ur25Abq58vksqJINpGdx" }, "href": "https://api.spotify.com/v1/artists/71Ur25Abq58vksqJINpGdx", "id": "71Ur25Abq58vksqJINpGdx", "name": "Miles Davis Quintet", "type": "artist", "uri": "spotify:artist:71Ur25Abq58vksqJINpGdx" } ] },
//               { "album_type": "album", "total_tracks": 8, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/6Kr0V00FNt8Xn3Dk3opAVb" }, "href": "https://api.spotify.com/v1/albums/6Kr0V00FNt8Xn3Dk3opAVb", "id": "6Kr0V00FNt8Xn3Dk3opAVb", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273e56fa33678b78030ef42aace", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02e56fa33678b78030ef42aace", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851e56fa33678b78030ef42aace", "width": 64 } ], "name": "Them Changes", "release_date": "1970-01-01", "release_date_precision": "day", "type": "album", "uri": "spotify:album:6Kr0V00FNt8Xn3Dk3opAVb", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/2E9nO9Zav9FjjlFVVtMWdw" }, "href": "https://api.spotify.com/v1/artists/2E9nO9Zav9FjjlFVVtMWdw", "id": "2E9nO9Zav9FjjlFVVtMWdw", "name": "Buddy Miles", "type": "artist", "uri": "spotify:artist:2E9nO9Zav9FjjlFVVtMWdw" } ] },
//               { "album_type": "album", "total_tracks": 64, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/1jOKHjidCbzo9tegzIlrvo" }, "href": "https://api.spotify.com/v1/albums/1jOKHjidCbzo9tegzIlrvo", "id": "1jOKHjidCbzo9tegzIlrvo", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273d5578146fd6cb97040f7d8bc", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02d5578146fd6cb97040f7d8bc", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851d5578146fd6cb97040f7d8bc", "width": 64 } ], "name": "Odyssey: 1945-1952", "release_date": "2002-05-21", "release_date_precision": "day", "type": "album", "uri": "spotify:album:1jOKHjidCbzo9tegzIlrvo", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/5RzjqfPS0Bu4bUMkyNNDpn" }, "href": "https://api.spotify.com/v1/artists/5RzjqfPS0Bu4bUMkyNNDpn", "id": "5RzjqfPS0Bu4bUMkyNNDpn", "name": "Dizzy Gillespie", "type": "artist", "uri": "spotify:artist:5RzjqfPS0Bu4bUMkyNNDpn" } ] },
//               { "album_type": "album", "total_tracks": 20, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/4EuAVxsazdEFr5ylShtllS" }, "href": "https://api.spotify.com/v1/albums/4EuAVxsazdEFr5ylShtllS", "id": "4EuAVxsazdEFr5ylShtllS", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b27309742e3446a646bf23eeb21e", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e0209742e3446a646bf23eeb21e", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d0000485109742e3446a646bf23eeb21e", "width": 64 } ], "name": "Ultimate Collection: Dobie Gray", "release_date": "2001-01-01", "release_date_precision": "day", "type": "album", "uri": "spotify:album:4EuAVxsazdEFr5ylShtllS", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/3mC1KCuZZSOlN8Z0M56VsV" }, "href": "https://api.spotify.com/v1/artists/3mC1KCuZZSOlN8Z0M56VsV", "id": "3mC1KCuZZSOlN8Z0M56VsV", "name": "Dobie Gray", "type": "artist", "uri": "spotify:artist:3mC1KCuZZSOlN8Z0M56VsV" } ] },
//               { "album_type": "album", "total_tracks": 4, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/6QPFCq6SHAOhBI1Vf14G0y" }, "href": "https://api.spotify.com/v1/albums/6QPFCq6SHAOhBI1Vf14G0y", "id": "6QPFCq6SHAOhBI1Vf14G0y", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b2732a2d01f78d82ad4d8c095ab1", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e022a2d01f78d82ad4d8c095ab1", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d000048512a2d01f78d82ad4d8c095ab1", "width": 64 } ], "name": "Cookin' With The Miles Davis Quintet", "release_date": "1957", "release_date_precision": "year", "type": "album", "uri": "spotify:album:6QPFCq6SHAOhBI1Vf14G0y", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/71Ur25Abq58vksqJINpGdx" }, "href": "https://api.spotify.com/v1/artists/71Ur25Abq58vksqJINpGdx", "id": "71Ur25Abq58vksqJINpGdx", "name": "Miles Davis Quintet", "type": "artist", "uri": "spotify:artist:71Ur25Abq58vksqJINpGdx" } ] },
//               { "album_type": "album", "total_tracks": 5, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA" }, "href": "https://api.spotify.com/v1/albums/1weenld61qoidwYuZ1GESA", "id": "1weenld61qoidwYuZ1GESA", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e027ab89c25093ea3787b1995b4", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d000048517ab89c25093ea3787b1995b4", "width": 64 } ], "name": "Kind Of Blue", "release_date": "1959-08-17", "release_date_precision": "day", "type": "album", "uri": "spotify:album:1weenld61qoidwYuZ1GESA", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" } ] },
//               { "album_type": "album", "total_tracks": 10, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/6zK0vUxP3YQAWcc7injGov" }, "href": "https://api.spotify.com/v1/albums/6zK0vUxP3YQAWcc7injGov", "id": "6zK0vUxP3YQAWcc7injGov", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273751134d011840435d2a368e5", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02751134d011840435d2a368e5", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851751134d011840435d2a368e5", "width": 64 } ], "name": "Cool Night", "release_date": "1981", "release_date_precision": "year", "type": "album", "uri": "spotify:album:6zK0vUxP3YQAWcc7injGov", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/6EJmqnuK0r6qiAevFFiNNR" }, "href": "https://api.spotify.com/v1/artists/6EJmqnuK0r6qiAevFFiNNR", "id": "6EJmqnuK0r6qiAevFFiNNR", "name": "Paul Davis", "type": "artist", "uri": "spotify:artist:6EJmqnuK0r6qiAevFFiNNR" } ] },
//               { "album_type": "album", "total_tracks": 19, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/4VUawqEDCHHfrUe77ScQ2K" }, "href": "https://api.spotify.com/v1/albums/4VUawqEDCHHfrUe77ScQ2K", "id": "4VUawqEDCHHfrUe77ScQ2K", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273cb6f92683ff9ad65f27a3f9f", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02cb6f92683ff9ad65f27a3f9f", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851cb6f92683ff9ad65f27a3f9f", "width": 64 } ], "name": "'Round About Midnight", "release_date": "1957-03-18", "release_date_precision": "day", "type": "album", "uri": "spotify:album:4VUawqEDCHHfrUe77ScQ2K", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" } ] },
//               { "album_type": "album", "total_tracks": 6, "available_markets": [], "external_urls": { "spotify": "https://open.spotify.com/album/0dyIXPKoUBt1vFJHX57dqt" }, "href": "https://api.spotify.com/v1/albums/0dyIXPKoUBt1vFJHX57dqt", "id": "0dyIXPKoUBt1vFJHX57dqt", "images": [ { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273ab2083ab4b97f7948ff163a1", "width": 640 }, { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02ab2083ab4b97f7948ff163a1", "width": 300 }, { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851ab2083ab4b97f7948ff163a1", "width": 64 } ], "name": "Relaxin' With The Miles Davis Quintet", "release_date": "1958", "release_date_precision": "year", "type": "album", "uri": "spotify:album:0dyIXPKoUBt1vFJHX57dqt", "artists": [ { "external_urls": { "spotify": "https://open.spotify.com/artist/71Ur25Abq58vksqJINpGdx" }, "href": "https://api.spotify.com/v1/artists/71Ur25Abq58vksqJINpGdx", "id": "71Ur25Abq58vksqJINpGdx", "name": "Miles Davis Quintet", "type": "artist", "uri": "spotify:artist:71Ur25Abq58vksqJINpGdx" } ] }
//             ]
//           }
//         }
//         """
//         guard let data = jsonString.data(using: .utf8) else { return [] }
//         let decoder = JSONDecoder()
//         let response = try? decoder.decode(SpotifySearchResponse.self, from: data)
//         return response?.albums.items ?? []
//    }()
//
//    // Keep a reference to the first album for detail view previews if needed
//    static let firstAlbum: AlbumItem? = allAlbums.first
//}
//
//// MARK: - SwiftUI Views
//
//// MARK: - Main List View with Search
//struct SpotifyAlbumListView: View {
//    // State for the search query entered by the user
//    @State private var searchQuery: String = ""
//    // State to hold the albums currently displayed (search results or initial data)
//    @State private var displayedAlbums: [AlbumItem] = SampleData.allAlbums // Start with all sample data
//    // State to indicate if a search is in progress
//    @State private var isLoading: Bool = false
//    // State to store the original search metadata (could be updated in a real API)
//    @State private var searchInfo: Albums? = nil // Initially nil, set on first load/search
//
//    var body: some View {
//        NavigationView {
//            // Use a ZStack to overlay the loading indicator or empty state
//            ZStack {
//                // Main content: List of albums
//                List {
//                    ForEach(displayedAlbums) { album in
//                        NavigationLink(destination: AlbumDetailView(album: album)) {
//                            AlbumRow(album: album)
//                        }
//                        .listRowInsets(EdgeInsets())
//                        .padding(.horizontal)
//                        .padding(.vertical, 5)
//                    }
//                }
//                .listStyle(PlainListStyle())
//                // --- Search Functionality ---
//                .searchable(text: $searchQuery,
//                            placement: .navigationBarDrawer(displayMode: .always), // Or .automatic
//                            prompt: "Search Albums or Artists")
//                // --- End Search Functionality ---
//                .navigationTitle("Album Search") // More appropriate title
//                .overlay {
//                    // --- Loading and Empty State Handling ---
//                    if isLoading {
//                        ProgressView("Searching...")
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            .background(Color.black.opacity(0.1)) // Dim background slightly
//                    } else if displayedAlbums.isEmpty && !searchQuery.isEmpty {
//                         // Only show "No Results" if a search was performed
//                        Text("No results found for \"\(searchQuery)\"")
//                            .foregroundColor(.secondary)
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    }
//                    // --- End Loading and Empty State ---
//                }
//            }
//            // --- Debounced Search Task ---
//            .task(id: searchQuery) { // This task automatically cancels and restarts when searchQuery changes
//                await performDebouncedSearch()
//            }
//            // --- End Debounced Search Task ---
//        }
//    }
//
//    // --- Async function to perform the debounced search ---
//    private func performDebouncedSearch() async {
//        // Trim whitespace from the query
//        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        // If the trimmed query is empty, reset to the initial state (show all sample data)
//        guard !trimmedQuery.isEmpty else {
//            // Ensure we don't display loading for an empty query reset
//            if isLoading { isLoading = false }
//             // Reset to show all original sample data when search is cleared
//            if displayedAlbums.count != SampleData.allAlbums.count {
//                displayedAlbums = SampleData.allAlbums
//            }
//            return
//        }
//
//        // --- Debounce Logic ---
//        // Wait for 500 milliseconds (0.5 seconds) before proceeding
//        // This prevents searching on every single keystroke.
//        do {
//            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
//        } catch {
//            // Handle cancellation if the task is cancelled (e.g., user types quickly)
//            print("Search task cancelled.")
//            return // Exit if cancelled
//        }
//
//        // --- Start Search ---
//        isLoading = true
//        // Simulate network delay or actual fetch
//        // In a real app, replace this sleep with your API call:
//        // let results = await APIService.shared.searchAlbums(query: trimmedQuery)
//        try? await Task.sleep(nanoseconds: 300_000_000) // Simulate short network time (0.3s)
//
//        // --- Filter Results (Simulation) ---
//        // Perform case-insensitive filtering on album name or artist names
//         let results = SampleData.allAlbums.filter { album in
//             let queryLowercased = trimmedQuery.lowercased()
//             let nameMatch = album.name.lowercased().contains(queryLowercased)
//             let artistMatch = album.artists.contains { artist in
//                artist.name.lowercased().contains(queryLowercased)
//            }
//            return nameMatch || artistMatch
//        }
//
//        // --- Update UI ---
//        // This needs to be done on the main thread if the search was truly async
//        // .task automatically runs on the main actor by default after awaits unless specified otherwise
//        displayedAlbums = results
//        isLoading = false
//
//        // Optional: Update searchInfo based on results
//        // If using a real API, you'd get new metadata back.
//        // For simulation, we could just count results:
//        // self.searchInfo = Albums(href: "", limit: results.count, next: nil, offset: 0, previous: nil, total: results.count, items: [])
//    }
//     // --- End Async function ---
//}
//
//// MARK: - Header View for Search Metadata (Unchanged - Could be removed or adapted for search context)
//struct SearchMetadataHeader: View {
//    let totalResults: Int
//    let limit: Int
//    let offset: Int
//
//    var body: some View {
//        HStack {
//            Text("Total: \(totalResults)")
//            Spacer()
//            Text("Showing \(offset + 1)-\(min(offset + limit, totalResults))")
//        }
//        .font(.caption)
//        .foregroundColor(.secondary)
//        .padding(.horizontal)
//        .padding(.vertical, 4)
//    }
//}
//
//// MARK: - View for a single row in the album list (Unchanged)
//struct AlbumRow: View {
//    let album: AlbumItem
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 15) {
//            AlbumImageView(url: album.listImageURL)
//                .frame(width: 50, height: 50)
//                .clipShape(RoundedRectangle(cornerRadius: 4))
//                .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)
//
//            VStack(alignment: .leading, spacing: 3) {
//                Text(album.name)
//                    .font(.headline)
//                    .lineLimit(2)
//
//                Text(album.formattedArtists)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//
//                HStack(spacing: 6) {
//                     Text(album.album_type.capitalized)
//                         .font(.caption)
//                         .padding(.horizontal, 6)
//                         .padding(.vertical, 2)
//                         .background(Color.gray.opacity(0.15))
//                         .clipShape(Capsule())
//
//                     Text("• \(album.formattedReleaseDate())")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                     Spacer()
//                }
//                .padding(.top, 1)
//
//                Text("\(album.total_tracks) Tracks")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//            Spacer()
//        }
//    }
//}
//
//// MARK: - Album Detail View (Unchanged)
//struct AlbumDetailView: View {
//    let album: AlbumItem
//    @Environment(\.openURL) var openURL
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                AlbumImageView(url: album.bestImageURL)
//                    .aspectRatio(1, contentMode: .fit)
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
//                    .padding(.horizontal)
//
//                VStack(alignment: .center, spacing: 4) {
//                    Text(album.name)
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.center)
//                    Text(album.formattedArtists)
//                        .font(.title3)
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.center)
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.horizontal)
//
//                Divider()
//
//                VStack(alignment: .leading, spacing: 10) {
//                    DetailItem(label: "Type", value: album.album_type.capitalized)
//                    DetailItem(label: "Released", value: album.formattedReleaseDate())
//                    DetailItem(label: "Total Tracks", value: "\(album.total_tracks)")
//                }
//                .padding(.horizontal)
//
//                Divider()
//
//                if let spotifyURL = URL(string: album.external_urls.spotify) {
//                    Button { openURL(spotifyURL) } label: {
//                        HStack {
//                            Image(systemName: "play.circle.fill")
//                            Text("Open in Spotify")
//                        }
//                        .font(.headline)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                    }
//                    .padding(.horizontal)
//                }
//                Spacer()
//            }
//            .padding(.vertical)
//        }
//        .navigationTitle(album.name)
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - DetailItem Helper View (Unchanged)
//struct DetailItem: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        HStack {
//            Text(label)
//                .font(.headline)
//                .foregroundColor(.secondary)
//                .frame(width: 120, alignment: .leading)
//            Text(value)
//                .font(.body)
//            Spacer()
//        }
//    }
//}
//
//// MARK: - Reusable Async Image View (Unchanged)
//struct AlbumImageView: View {
//    let url: URL?
//
//    var body: some View {
//        Group { // Use Group to avoid needing explicit type for conditional content
//            if let url = url {
//                AsyncImage(url: url) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView()
//                             .frame(maxWidth: .infinity, maxHeight: .infinity)
//                             .background(Color.secondary.opacity(0.1)) // Show background during load
//                    case .success(let image):
//                        image
//                            .resizable()
//                            // Aspect ratio is handled by the caller (.fit in Detail, implicitly fill in Row)
//                    case .failure:
//                        Image(systemName: "photo.fill") // Placeholder for error
//                            .resizable()
//                            .scaledToFit()
//                            .foregroundColor(.secondary.opacity(0.5))
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            .background(Color.secondary.opacity(0.1))
//
//                    @unknown default:
//                        Image(systemName: "questionmark.diamond.fill")
//                             .resizable()
//                             .scaledToFit()
//                             .foregroundColor(.secondary.opacity(0.5))
//                             .frame(maxWidth: .infinity, maxHeight: .infinity)
//                             .background(Color.secondary.opacity(0.1))
//                    }
//                }
//            } else {
//                Image(systemName: "music.note.list") // Placeholder if no URL
//                     .resizable()
//                     .scaledToFit()
//                     .foregroundColor(.secondary.opacity(0.5))
//                     .frame(maxWidth: .infinity, maxHeight: .infinity)
//                     .background(Color.secondary.opacity(0.1))
//            }
//        }
//         // Background color applied within specific phases or if no URL
//    }
//}
//
//// MARK: - Preview Providers (Unchanged - Mostly)
//struct SpotifyAlbumListView_Previews: PreviewProvider {
//    static var previews: some View {
//        // You might want multiple previews: one initial, one searching, one empty
//        SpotifyAlbumListView() // Initial state
//            .previewDisplayName("Initial State")
//
//        // Example preview simulating search results
////        SpotifyAlbumListView(searchQuery: "Kind Of Blue", displayedAlbums: SampleData.allAlbums.filter { $0.name.contains("Kind Of Blue")})
////             .previewDisplayName("Search Results")
//
//        // Example preview simulating no results
////        SpotifyAlbumListView(searchQuery: "xyzabc", displayedAlbums: [])
////             .previewDisplayName("No Results")
//    }
//}
//
//// Detail View Preview remains the same
//struct AlbumDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            if let sampleAlbum = SampleData.firstAlbum {
//                AlbumDetailView(album: sampleAlbum)
//            } else {
//                Text("No sample album data available for preview.")
//            }
//        }
//         .previewDisplayName("Detail View")
//    }
//}
//
///*
//// Example Usage (Typically in your App struct - Unchanged)
//@main
//struct YourApp: App {
//    var body: some Scene {
//        WindowGroup {
//            SpotifyAlbumListView()
//        }
//    }
//}
//*/
