//
//  ViewController.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 28.11.2020.
//

import UIKit
import Combine

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
                    // Если текущая страница не начальная, необходимо рассчитать IndexPath для обновления.
                    if self.currentPage > 1 {
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: galleryObject.data)
                        self.onFetchCompleted(with: indexPathsToReload)
                    } else {
                        self.onFetchCompleted(with: .none)
                    }
                case .failure(let errorObject):
                    self.isFetchInProgress = false
                    self.onFetchFailed(with: errorObject.data.error)
                }
            })
            .store(in: &subscriptions)
    }
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
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
        let object = gallery[indexPath.item]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailTableViewController") as! DetailTableViewController
        controller.detailItem = object
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - Extensions

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
        
        // Получение фотографии для конкретной ячейки.
        cell.photo = gallery[indexPath.item]
        
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
        return CGFloat((gallery[indexPath.item].coverHeight ?? 540) / 3)
    }
}

extension PhotoCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            fetchGallery()
        }
    }
}
