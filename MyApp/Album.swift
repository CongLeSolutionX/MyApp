//
//  Album.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//


import SwiftUI

// MARK: Album Model and Sample Albums
struct Album: Identifiable{
    var id = UUID().uuidString
    var albumName: String
    var albumImage: String
    var isLiked: Bool = false
}

// ZStack Albums
var stackAlbums: [Album] = [
    Album(albumName: "Quán karaoke nào có âm thanh hay dzạ?", albumImage: "Album2"),
    Album(albumName: "Xinh đẹp nhưng khó chịu vô cùng", albumImage: "Album3"),
    Album(albumName: "Bộ đồ này nóng vl", albumImage: "Album4"),
    Album(albumName: "Cơm nước gì chưa người đẹp", albumImage: "Album8"),
]

var albums: [Album] = [

    Album(albumName: "The Best", albumImage: "Album2",isLiked: true),
    Album(albumName: "My Everything", albumImage: "Album3"),
    Album(albumName: "Yours Truly", albumImage: "Album4"),
    Album(albumName: "Sweetener", albumImage: "Album5",isLiked: true),
    Album(albumName: "Rain On Me", albumImage: "Album6"),
    Album(albumName: "Stuck With U", albumImage: "Album7"),
    Album(albumName: "7 rings", albumImage: "Album8",isLiked: true),
    Album(albumName: "Bang Bang", albumImage: "Album9"),
]

