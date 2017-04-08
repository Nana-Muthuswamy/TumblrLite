//
//  PhotoDetailsViewController.swift
//  Tumblr
//
//  Created by Nana on 3/29/17.
//  Copyright © 2017 DevFountain LLC. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!

    var photoURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        if photoURL != nil {
            photoImageView.setImageWith(photoURL!)
        }
    }
}
