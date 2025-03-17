//
//  MockData.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//


// MARK: - Data (Placeholder and Fake Data)

let placeholderTopics: [Topic] = [
    Topic(name: "Technology", icon: "laptopcomputer"),
    Topic(name: "Design", icon: "paintpalette"),
    Topic(name: "Gaming", icon: "gamecontroller"),
    Topic(name: "Mobile", icon: "iphone"),
    Topic(name: "Web Dev", icon: "globe"),
    Topic(name: "AI", icon: "brain"),
    Topic(name: "Data Science", icon: "chart.bar"),
    Topic(name: "UX/UI", icon: "person.crop.artframe"),
    Topic(name: "Cloud", icon: "cloud"),
    Topic(name: "Security", icon: "shield")
]

let placeholderAuthor = Author(name: "Jane Doe", imageName: "person.circle.fill") // SF Symbol

let placeholderArticles: [Article] = [
    Article(
        title: "The Future of Mobile Development",
        date: "March 15, 2024",
        author: placeholderAuthor,
        url: "example.com/article1",
        imageName: "placeholderImage1", // Replace with actual asset name
        topics: [
            placeholderTopics[0],
            placeholderTopics[3],
            placeholderTopics[4]
        ],
        isBookmarked: false,
        updatesSinceLastViewed: 2
    ),
    Article(
        title: "AI-Powered Design Tools",
        date: "March 10, 2024",
        author: Author(name: "John Smith", imageName: "person.circle.fill"),
        url: "example.com/article2",
        imageName: "placeholderImage2", // Replace with actual asset name
        topics: [
            placeholderTopics[1],
            placeholderTopics[5],
            placeholderTopics[7]
        ],
        isBookmarked: true,
        updatesSinceLastViewed: 5
    ),
    Article(
        title: "Mastering Cloud Security",
        date: "February 28, 2024",
        author: placeholderAuthor,
        url: "example.com/article3",
        imageName: "placeholderImage3",
        topics: [
            placeholderTopics[8],
            placeholderTopics[9]
        ],
        isBookmarked: false,
        updatesSinceLastViewed: 0
    )
]
