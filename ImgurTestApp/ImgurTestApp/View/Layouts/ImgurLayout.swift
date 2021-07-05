//
//  ImgurLayout.swift
//  ImgurTestApp
//
//  Created by Пазин Даниил on 06.12.2020.
//

import UIKit

protocol ImgurLayoutDelegate: AnyObject {
    //  Метод для запроса высоты фотографий.
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class ImgurLayout: UICollectionViewLayout {
    // Переменная хранит ссылку на делегат.
    weak var delegate: ImgurLayoutDelegate?

    // Количество колонок и расстояние между ячейками.
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 6

    // Переменная хранит рассчитанные в методе prepare() свойства.
    private var cache: [UICollectionViewLayoutAttributes] = []

    private var contentHeight: CGFloat = 0
    // Ширина рассчитывается на основе ширины collection view.
    private var contentWidth: CGFloat {
      guard let collectionView = collectionView else {
        return 0
      }
      let insets = collectionView.contentInset
      return collectionView.bounds.width - (insets.left + insets.right)
    }

    // Ширина и высота контента collection view.
    override var collectionViewContentSize: CGSize {
      return CGSize(width: contentWidth, height: contentHeight)
    }

    /// - Tag: Вычисление рамеров каждого элемента в collection view.
    override func prepare() {
      // Расчёт производится только если переменная cache не хранит значений и collection view существует.
      guard let collectionView = collectionView else { return }
      // Вычисление позиций колонок по осям x и y.
      let columnWidth = contentWidth / CGFloat(numberOfColumns)
      var xOffset: [CGFloat] = []
      for column in 0..<numberOfColumns {
        xOffset.append(CGFloat(column) * columnWidth)
      }
      var column = 0
      var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
      // Цикл по ячейкам в коллекции.
      for item in 0..<collectionView.numberOfItems(inSection: 0) {
        let indexPath = IndexPath(item: item, section: 0)
          
        // Вычисление размеров каждой ячейки.
        let photoHeight = delegate?.collectionView(
          collectionView,
          heightForPhotoAtIndexPath: indexPath) ?? 180
        let height = cellPadding * 2 + photoHeight
        let frame = CGRect(x: xOffset[column],
                           y: yOffset[column],
                           width: columnWidth,
                           height: height)
        let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
          
        // Помещение заданных атрибутов в переменную cache.
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = insetFrame
        cache.append(attributes)
          
        // Увеличение высоты контента на высоту новой ячейки.
        contentHeight = max(contentHeight, frame.maxY)
        // Увеличение отступа текущей колонки по оси y.
        yOffset[column] = yOffset[column] + height
        // Изменение текущей колонки, чтобы следующая фотография была отображена в новой.
        column = column < (numberOfColumns - 1) ? (column + 1) : 0
      }
    }

    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
      var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
      
      // Цикл по массиву cache, поиск ячеек, которые находятся в видимом пользователю диапазоне.
      for attributes in cache {
        if attributes.frame.intersects(rect) {
          visibleLayoutAttributes.append(attributes)
        }
      }
      return visibleLayoutAttributes
    }

    // Возвращает данные объекта по заданному IndexPath.
    override func layoutAttributesForItem(at indexPath: IndexPath)
        -> UICollectionViewLayoutAttributes? {
      return cache[indexPath.item]
    }
}
