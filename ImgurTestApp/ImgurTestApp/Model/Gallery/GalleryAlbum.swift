//
//  GalleryAlbum.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 29.11.2020.
//

import Foundation

public struct GalleryAlbum: Codable {

    public var id: String // The ID for the image
    public var title: String // The title of the album in the gallery
    public var description: String? // The description of the album in the gallery
    public var datetime: Int    // Time inserted into the gallery, epoch time
    public var cover: String?    // The ID of the album cover image
    public var coverWidth: Int?   // The width, in pixels, of the album cover image
    public var coverHeight: Int?    // The height, in pixels, of the album cover image
    public var accountUrl: String    // The account username or null if it's anonymous.
    public var accountId: Int   // The account ID of the account that uploaded it, or null.
    public var privacy: String?    // The privacy level of the album, you can only view public if not logged in as album owner
    public var layout: String?    // The view layout of the album.
    public var views: Int    // The number of image views
    public var link: String    // The URL link to the album
    public var ups: Int    // Upvotes for the image
    public var downs: Int    // Number of downvotes for the image
    public var points: Int    // Upvotes minus downvotes
    public var score: Int   // Imgur popularity score
    public var isAlbum: Bool    // if it's an album or not
    public var vote: String?    // The current user's vote on the album. null if not signed in or if the user hasn't voted on it.
    public var favorite: Bool    // Indicates if the current user favorited the album. Defaults to false if not signed in.
    public var nsfw: Bool    // Indicates if the album has been marked as nsfw or not. Defaults to null if information is not available.
    public var commentCount: Int    // Number of comments on the gallery album.
    public var topic: String?    // Topic of the gallery album.
    public var topicId: Int?   // Topic ID of the gallery album.
    public var imagesCount: Int?    // The total number of images in the album
    public var inMostViral: Bool   // Indicates if the album is in the most viral gallery or not.
    public var images: [AlbumImages]?    // An array of all the images in the album (only available when requesting the direct album)
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case datetime
        case cover
        case coverWidth = "cover_width"
        case coverHeight = "cover_height"
        case accountUrl = "account_url"
        case accountId = "account_id"
        case privacy
        case layout
        case views
        case link
        case ups
        case downs
        case points
        case score
        case isAlbum = "is_album"
        case vote
        case favorite
        case nsfw
        case commentCount = "comment_count"
        case topic
        case topicId = "topic_id"
        case imagesCount = "images_count"
        case inMostViral = "in_most_viral"
        case images
    }
    
    public init(id: String,
                title: String,
                description: String?,
                datetime: Int,
                cover: String?,
                coverWidth: Int?,
                coverHeight: Int?,
                accountUrl: String,
                accountId: Int,
                privacy: String?,
                layout: String?,
                views: Int,
                link: String,
                ups: Int,
                downs: Int,
                points: Int,
                score: Int,
                isAlbum: Bool,
                vote: String?,
                favorite: Bool,
                nsfw: Bool,
                commentCount: Int,
                topic: String,
                topicId: Int,
                imagesCount: Int?,
                inMostViral: Bool,
                images: [AlbumImages]?) {
        self.id = id
        self.title = title
        self.description = description
        self.datetime = datetime
        self.cover = cover
        self.coverWidth = coverWidth
        self.coverHeight = coverHeight
        self.accountUrl = accountUrl
        self.accountId = accountId
        self.privacy = privacy
        self.layout = layout
        self.views = views
        self.link = link
        self.ups = ups
        self.downs = downs
        self.points = points
        self.score = score
        self.isAlbum = isAlbum
        self.vote = vote
        self.favorite = favorite
        self.nsfw = nsfw
        self.commentCount = commentCount
        self.topic = topic
        self.topicId = topicId
        self.imagesCount = imagesCount
        self.inMostViral = inMostViral
        self.images = images
    }
}
