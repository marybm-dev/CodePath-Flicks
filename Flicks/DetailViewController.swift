//
//  DetailViewController.swift
//  Flicks
//
//  Created by Mary Martinez on 10/14/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import AFNetworking

class DetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    
    var movie: Movie!
    var baseURL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        overviewLabel.sizeToFit()
        
        let posterURL = URL(string: baseURL + movie.poster)
        if let validURL = posterURL {
            posterView.setImageWith(validURL)
        }
    }
}
