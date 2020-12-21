//
//  DetailTableViewController.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 06.12.2020.
//

import UIKit
import Kingfisher
import Combine
import AVFoundation

class DetailTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Constants and Variables
    
    var detailItem: GalleryAlbum? {
        didSet {
            if isViewLoaded {
                configureView()
            }
        }
    }
    let apiClient = APIClient()
    var subscriptions: Set<AnyCancellable> = []
    var comments: [Comment] = []
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = UIColor.black
        configureView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Methods
    
    func configureView() {
        guard let detailItem = detailItem else { return }
        
        containerView.frame.size.height = setViewHeight(item: detailItem)
        
        if let image = detailItem.images?.first {
            if image.link.contains(".mp4") {
                guard let videoURL = URL(string: image.link) else { return }
                playVideo(videoURL)
            }
            imageView.kf.setImage(with: URL(string: image.link))
        } else {
            if detailItem.link.contains(".mp4") {
                guard let videoURL = URL(string: detailItem.link) else { return }
                playVideo(videoURL)
            }
            imageView.kf.setImage(with: URL(string: detailItem.link))
        }
        
        apiClient.imageComments(imageId: detailItem.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.tableView.reloadData()
                case .failure(let error):
                    self.onFetchFailed(with: error.localizedDescription)
                }
            }, receiveValue: { object in
                switch object {
                case .success(let comment):
                    self.comments.append(contentsOf: comment)
                case .failure(let errorObject):
                    self.onFetchFailed(with: errorObject.data.error)
                }
            })
            .store(in: &subscriptions)
    }
    
    // Расчёт высоты картинки на основе оригинального соотношения сторон.
    func setViewHeight(item: GalleryAlbum) -> CGFloat {
        let viewWide = UIScreen.main.bounds.width
        guard let imageHieght = item.coverHeight, let imageWide = item.coverWidth else {
            return viewWide
        }
        let viewHieght = CGFloat(imageHieght) / CGFloat(imageWide) * viewWide
        return viewHieght
    }
    
    // Воспроизведение видео.
    func playVideo(_ videoURL: URL) {
        let player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = containerView.bounds
        containerView.layer.addSublayer(playerLayer)
        player.play()
    }
    
    func onFetchFailed(with reason: String) {
        let alert = UIAlertController(title: "Warning", message: reason, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
        // Получение комментария для конкретной строки.
        let comment = comments[indexPath.row]
        
        // Установка содержимого ячейки (автор, комментарий, картинка).
        cell.authorLabel.text = comment.author
        cell.commentLabel.text = comment.comment
        
        // Если в комментарии есть ссылка на картинку, показываем картинку.
        cell.commentImageView.kf.setImage(with: comment.image, completionHandler:  { result in
            switch result {
            case .success(_):
                tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(_): break
            }
        })
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
