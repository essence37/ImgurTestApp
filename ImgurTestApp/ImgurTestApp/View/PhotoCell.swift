//
//  PhotoCell.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 28.11.2020.
//

import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
    }
    
    var photo: GalleryAlbum? {
        didSet {
            if let photo = photo {
                guard let image = photo.images?.first?.link else {
                    showPhoto(photo.link)
                    nameLabel.text = photo.title
                    return
                }
                showPhoto(image)
                nameLabel.text = photo.title
            }
        }
    }
    
    var photoRealm: RealmGalleryAlbum? {
        didSet {
            if let photo = photoRealm {
                guard let image = photo.images.first?.link else {
                    showPhoto(photo.link)
                    nameLabel.text = photo.title
                    print(photo.link)
                    print(photo.title)
                    return
                }
                showPhoto(image)
                nameLabel.text = photo.title
            }
        }
    }
    
    func showPhoto(_ image: String) {
        let imageURL = URL(string: image)
        if image.contains(".mp4") {
            let provider = AVAssetImageDataProvider(
                assetURL: imageURL!,
                seconds: 5.0
            )
            imageView.kf.setImage(with: provider)
        } else {
            imageView.kf.setImage(with: imageURL)
        }
    }
}
