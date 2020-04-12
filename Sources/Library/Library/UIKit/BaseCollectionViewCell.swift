//
//  BaseCollectionViewCell.swift
//  Library
//
//  Created by Nikita Kislyakov on 11.02.2020.
//

import Foundation
import UIKit

open class BaseCollectionViewCell: UICollectionViewCell {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    open func setup() {
        contentView.backgroundColor = .white
    }
}
