//
//  SectionedLayout.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 13.02.2020.
//

import Foundation
import UIKit
import Library

extension UIEdgeInsets {
    var topLeftCorner: CGPoint {
        .init(x: left, y: top)
    }
}

extension SectionedLayout {
    struct Info {
        let contentInsets: UIEdgeInsets
        let itemsHorizontalSpacing: CGFloat
        let itemsVerticalSpacing: CGFloat
    }
}

class SectionedLayout: UICollectionViewLayout {
    private var contentRect = CGRect.zero
    
    private var cachedAttributes = [[UICollectionViewLayoutAttributes]]()
    
    let info: Info
    private let sizeProviderClosure: (IndexPath) -> CGSize
    
    init(info: Info, sizeProviderClosure: @escaping (IndexPath) -> CGSize) {
        self.info = info
        self.sizeProviderClosure = sizeProviderClosure
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else {
            return
        }
        
        cachedAttributes.removeAll()
        
        let collectionViewWidth = collectionView.bounds.size.width
        
        contentRect = .init(
            origin: .zero,
            size: .init(width: collectionViewWidth, height: 0)
        )
        
        let rightEdge = collectionViewWidth - info.contentInsets.right
        let sectionsCount = collectionView.numberOfSections
        
        var itemFrame = CGRect(origin: info.contentInsets.topLeftCorner, size: .zero)
        
        var maxY = itemFrame.maxY
        
        for section in 0 ..< sectionsCount {
            cachedAttributes.append([])
            
            let itemsCount = collectionView.numberOfItems(inSection: section)
            
            for item in 0 ..< itemsCount {
                let indexPath = IndexPath(item: item, section: section)
                
                let givenSize = sizeProviderClosure(indexPath)
                
                if !(section == 0 && item == 0) {
                    if itemFrame.maxX + info.itemsHorizontalSpacing + givenSize.width <= rightEdge {
                        itemFrame.origin.x = itemFrame.maxX + info.itemsHorizontalSpacing
                    } else {
                        itemFrame.origin.x = info.contentInsets.left
                        itemFrame.origin.y = maxY + info.itemsVerticalSpacing
                    }
                }
                
                itemFrame.size = givenSize
                
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                attribute.frame = itemFrame
                
                cachedAttributes[section].append(attribute)
                
                maxY = max(itemFrame.maxY, maxY)
            }
        }
        
        contentRect.size.height = maxY + info.contentInsets.bottom
    }
    
    override var collectionViewContentSize: CGSize {
        contentRect.size
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        
        return newBounds.size != collectionView.bounds.size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let flatArray = cachedAttributes.flatMap { $0 }
        
        var resultArray = [UICollectionViewLayoutAttributes]()
        
        let startIndex = flatArray.startIndex
        let endIndex = flatArray.endIndex
        
        guard let boundIndex = binSearch(rect: rect, from: startIndex, to: endIndex, in: flatArray) else {
            return resultArray
        }
        
        for attr in flatArray[boundIndex...] {
            guard attr.frame.minY <= rect.maxY else {
                break
            }
            
            resultArray.append(attr)
        }
        
        for attr in flatArray[..<boundIndex].reversed() {
            guard attr.frame.maxY >= rect.minY else {
                break
            }
            
            resultArray.append(attr)
        }
        
        return resultArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cachedAttributes[indexPath.section][indexPath.item]
    }
    
    private func binSearch(
        rect: CGRect,
        from startIndex: Int,
        to endIndex: Int,
        in array: [UICollectionViewLayoutAttributes]
    ) -> Int? {
        guard startIndex >= 0 && endIndex > startIndex else {
            return nil
        }
        
        let mid = (startIndex + endIndex) / 2
        let attr = array[mid]
        
        if attr.frame.intersects(rect) {
            return mid
        } else {
            if attr.frame.maxY < rect.minY {
                return binSearch(rect: rect, from: (mid + 1), to: endIndex, in: array)
            } else {
                return binSearch(rect: rect, from: startIndex, to: mid - 1, in: array)
            }
        }
    }
}
