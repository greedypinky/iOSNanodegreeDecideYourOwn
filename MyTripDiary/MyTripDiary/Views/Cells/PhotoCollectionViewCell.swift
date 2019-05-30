//
//  PhotoCollectionViewCell.swift
//  MyTripDiary
//
//  Created by Man Wai  Law on 2019-05-28.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var flickrImage: UIImageView!
    
    @IBOutlet weak var noImage: UILabel!
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .whiteLarge)
        return ai
    }()
    
    func set(image: UIImage?) {
        flickrImage.image = image
        
        if image == nil {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    
}
