//
//  ImageDetailViewController.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 17/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import UIKit

final class ImageDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var imageUrlString: String?
    
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    init() {
        super.init(nibName: "ImageDetailViewController", bundle: nil)
    }
    
    convenience init(imageUrlString: String?) {
        self.init()
        self.imageUrlString = imageUrlString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loaderView.startAnimating()
        if let urlString = self.imageUrlString, let url = URL(string: urlString) {
            self.imageView.sd_setImage(with: url) {
                _, _, _, _ in
                self.loaderView.stopAnimating()
            }
        }
    }
}
