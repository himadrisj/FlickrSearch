//
//  ImageCollectionViewCell.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 17/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {

    static let nib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
}
