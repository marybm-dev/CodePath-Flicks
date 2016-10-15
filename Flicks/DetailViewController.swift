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
    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: Movie!
    var baseURL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        
        let posterURL = URL(string: baseURL + movie.poster)
        if let validURL = posterURL {
            posterView.setImageWith(validURL)
        }
    }
}
