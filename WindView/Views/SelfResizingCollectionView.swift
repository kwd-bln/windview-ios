//
//  SelfResizingCollectionView.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/13.
//


import UIKit

class SelfResizingCollectionView: UICollectionView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: contentSize.width, height: contentSize.height)
    }
}
