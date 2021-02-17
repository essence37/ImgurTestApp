//
//  RealmGalleryAlbum.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 15.02.2021.
//

import Foundation
import RealmSwift

class RealmGalleryAlbum: Object {

    @objc dynamic var id: String = "" // The ID for the image
    @objc dynamic var title: String = "" // The title of the album in the gallery
    @objc dynamic var albumDescription: String?   // The description of the album in the gallery
    @objc dynamic var datetime: Int = 0   // Time inserted into the gallery, epoch time
    @objc dynamic var cover: String?   // The ID of the album cover image
    var coverWidth = RealmOptional<Int>()   // The width, in pixels, of the album cover image
    var coverHeight = RealmOptional<Int>()    // The height, in pixels, of the album cover image
    @objc dynamic var accountUrl: String = ""    // The account username or null if it's anonymous.
    @objc dynamic var accountId: Int = 0  // The account ID of the account that uploaded it, or null.
    @objc dynamic var privacy: String?   // The privacy level of the album, you can only view public if not logged in as album owner
    @objc dynamic var layout: String?   // The view layout of the album.
    @objc dynamic var views: Int = 0   // The number of image views
    @objc dynamic var link: String = ""    // The URL link to the album
    @objc dynamic var ups: Int = 0   // Upvotes for the image
    @objc dynamic var downs: Int = 0   // Number of downvotes for the image
    @objc dynamic var points: Int = 0   // Upvotes minus downvotes
    @objc dynamic var score: Int = 0   // Imgur popularity score
    @objc dynamic var isAlbum: Bool = false    // if it's an album or not
    @objc dynamic var vote: String?   // The current user's vote on the album. null if not signed in or if the user hasn't voted on it.
    @objc dynamic var favorite: Bool = false   // Indicates if the current user favorited the album. Defaults to false if not signed in.
    @objc dynamic var nsfw: Bool = false   // Indicates if the album has been marked as nsfw or not. Defaults to null if information is not available.
    @objc dynamic var commentCount: Int = 0   // Number of comments on the gallery album.
    @objc dynamic var topic: String = ""   // Topic of the gallery album.
    @objc dynamic var topicId: Int = 0   // Topic ID of the gallery album.
    var imagesCount = RealmOptional<Int>()    // The total number of images in the album
    @objc dynamic var inMostViral: Bool = false   // Indicates if the album is in the most viral gallery or not.
    var images = List<RealmAlbumImages>()  // An array of all the images in the album (only available when requesting the direct album)
    @objc dynamic var date: String = ""

    convenience init(id: String,
                title: String,
                albumDescription: String?,
                datetime: Int,
                cover: String?,
                coverWidth: RealmOptional<Int>,
                coverHeight: RealmOptional<Int>,
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
                imagesCount: RealmOptional<Int>,
                inMostViral: Bool,
                images: List<RealmAlbumImages>,
                date: String) {
        self.init()
        self.id = id
        self.title = title
        self.albumDescription = albumDescription
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
        self.date = date
    }
}
