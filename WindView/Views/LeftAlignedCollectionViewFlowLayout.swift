//
//  LeftAlignedCollectionViewFlowLayout.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/13.
//

import UIKit

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0

        for layoutAttribute in layoutAttributes {
            if layoutAttribute.representedElementCategory != .cell { continue }

            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }

        return layoutAttributes
    }
}
