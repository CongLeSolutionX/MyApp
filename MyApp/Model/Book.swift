//
//  Book.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

/// Book Model
struct Book: Identifiable,Hashable{
    var id: String = UUID().uuidString
    var title: String
    var imageName: String
    var author: String
    var rating: Int
    var bookViews: Int
}

var sampleBooks: [Book] = [
    .init(title: "Five Feet Apart", imageName: "My-meme-cordyceps", author: "Rachael Lippincott", rating: 4, bookViews: 1023),
    .init(title: "The Alchemist", imageName: "My-meme-heineken", author: "William B.Irvine", rating: 5, bookViews: 2049),
    .init(title: "Booke of Hapiness", imageName: "My-meme-orange", author: "Anne", rating: 4, bookViews: 920),
    .init(title: "Living Alone", imageName: "My-meme-red-wine-glass", author: "William Lippincott", rating: 3, bookViews: 560),
    .init(title: "Five Feet Apart", imageName: "My-meme-with-cap", author: "Jenna Lippincott", rating: 5, bookViews: 240),
]
