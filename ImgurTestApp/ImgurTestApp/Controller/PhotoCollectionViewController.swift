//
//  ViewController.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 28.11.2020.
//

import UIKit
import Combine
import RealmSwift

class PhotoCollectionViewController: UICollectionViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    // MARK: - Constants and Variables
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let apiClient = APIClient()
    var subscriptions: Set<AnyCancellable> = []
    var gallery: [GalleryAlbum] = []
    // Ткущая страница в Imgur для загрузки данных.
    var currentPage: Int64 = 0
    // Индикатор, показывающий, осуществляется ли в настоящий момент запрос.
    var isFetchInProgress = false
    // Realm
    let realm = try! Realm()
    var realmGallery = List<RealmGalleryAlbum>()
    var useRealmForCurrentDatabase = true
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Визуальная настройка NavigationItem для DetailTableViewController.
        // Provide an empty backBarButton to hide the 'Back' text present by default in the back button.
        let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtton
        // Активировать индикатор загрузки.
        indicatorView.startAnimating()
        // Установка PhotoCollectionViewController в качестве делегата для layout.
        if let layout = collectionView?.collectionViewLayout as? ImgurLayout {
            layout.delegate = self
        }
        collectionView?.prefetchDataSource = self
        collectionView?.backgroundColor = .clear
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
        
        fetchGallery()
    }
    
    // Спрятать UINavigationBar.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // Показать UINavigationBar.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Methods
    
    func fetchGallery() {
        // Проверка, нет ли активного запроса.
        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true
        
        apiClient.gallery(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.isFetchInProgress = false
                    self.onFetchFailed(with: error.localizedDescription)
                }
            }, receiveValue: { object in
                switch object {
                case .success(let galleryObject):
                    // В случае успешного завершения запроса, увеличиваем счётчик страницы, снимаем флаг.
                    self.currentPage += 1
                    self.isFetchInProgress = false
                    // Добавление полученного значения в массив.
                    self.gallery.append(contentsOf: galleryObject.data)
                    //
                    self.realmGallery.append(objectsIn: self.convertDataToRealm(galleryObject.data))
                    // Если текущая страница не начальная, необходимо рассчитать IndexPath для обновления.
                    if self.currentPage > 1 {
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: galleryObject.data)
                        self.onFetchCompleted(with: indexPathsToReload)
                    } else {
                        self.onFetchCompleted(with: .none)
                        //
                        self.cachingGallery(self.realmGallery)
                    }
                case .failure(let errorObject):
                    self.isFetchInProgress = false
                    self.onFetchFailed(with: errorObject.data.error)
                }
            })
            .store(in: &subscriptions)
    }
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        //
        useRealmForCurrentDatabase = false
        // Начальная страница, убираем индикатор загрузки, показываем и обновляем таблицу.
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            indicatorView.stopAnimating()
            indicatorView.isHidden = true
            self.collectionView.reloadData()
            return
        }
        // Последующие страницы, обновление видимых ячеек.
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        collectionView.reloadItems(at: indexPathsToReload)
    }
    
    func onFetchFailed(with reason: String) {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        let alert = UIAlertController(title: "Warning", message: reason, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
        //
        let realmResult = self.realm.objects(RealmGalleryAlbum.self)
        self.realmGallery.append(objectsIn: realmResult)
        collectionView.reloadData()
    }
    
    // Расчёт IndexPath, которые необходимо обновить.
    func calculateIndexPathsToReload(from newGallery: [GalleryAlbum]) -> [IndexPath] {
        let startIndex = gallery.count - newGallery.count
        let endIndex = startIndex + newGallery.count
        return (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
    }
    
    // Расчёт ячеек, которые необходимо обновить после получения новой страницы.
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleItems).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    // Позволяет определить, что значение текущего indexPath больше чем количество объектов в gallery.
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.item >= gallery.count - 3
    }
    
    // MARK: - Navigation
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailTableViewController") as! DetailTableViewController
        if useRealmForCurrentDatabase {
            let object = realmGallery[indexPath.item]
            controller.realmDetailItem = object
        } else {
            let object = gallery[indexPath.item]
            controller.detailItem = object
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - Extensions

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if useRealmForCurrentDatabase {
            return realmGallery.count
        } else {
            return gallery.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
        
        // Получение фотографии для конкретной ячейки.
        if useRealmForCurrentDatabase {
            cell.photoRealm = realmGallery[indexPath.item]
        } else {
            cell.photo = gallery[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
    }
}

extension PhotoCollectionViewController: ImgurLayoutDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        if useRealmForCurrentDatabase {
            return CGFloat((realmGallery[indexPath.item].coverHeight.value ?? 540) / 3)
        } else {
            return CGFloat((gallery[indexPath.item].coverHeight ?? 540) / 3)
        }
    }
}

extension PhotoCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard !useRealmForCurrentDatabase else { return }
        if indexPaths.contains(where: isLoadingCell) {
            fetchGallery()
        }
    }
}

// MARK: Realm
extension PhotoCollectionViewController {
    
    func convertDataToRealm(_ gallery: [GalleryAlbum]) -> [RealmGalleryAlbum] {
        // Настройка даты.
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy 'в' HH:mm"
        let result = formatter.string(from: date)
        
        let realmGallery: [RealmGalleryAlbum] = gallery.map {
            let realmAlbumImages = List<RealmAlbumImages>()
            if let images = $0.images {
                for image in images {
                    realmAlbumImages.append(RealmAlbumImages(id: image.id, link: image.link))
                }
            }
            return RealmGalleryAlbum(id: $0.id,
                              title: $0.title,
                              albumDescription: $0.description,
                              datetime: $0.datetime,
                              cover: $0.cover,
                              coverWidth: RealmOptional($0.coverWidth),
                              coverHeight: RealmOptional($0.coverHeight),
                              accountUrl: $0.accountUrl,
                              accountId: $0.accountId,
                              privacy: $0.privacy,
                              layout: $0.layout,
                              views: $0.views,
                              link: $0.link,
                              ups: $0.ups,
                              downs: $0.downs,
                              points: $0.points,
                              score: $0.score,
                              isAlbum: $0.isAlbum,
                              vote: $0.vote,
                              favorite: $0.favorite,
                              nsfw: $0.nsfw,
                              commentCount: $0.commentCount,
                              topic: $0.topic,
                              topicId: $0.topicId,
                              imagesCount: RealmOptional($0.imagesCount),
                              inMostViral: $0.inMostViral,
                              images: realmAlbumImages,
                              date: result)
        }
        return realmGallery
    }
    
    func cachingGallery(_ gallery: List<RealmGalleryAlbum>) {
        do {
            try realm.write {
                let objects = realm.objects(RealmGalleryAlbum.self)
                realm.delete(objects)
                realm.add(gallery)
            }
        } catch let error as NSError {
            print(error)
        }
    }
}
