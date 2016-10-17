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
        
        // set the scroll view to include offscreen view
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        // set the labels
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        overviewLabel.sizeToFit()
        
        // set the image
        let posterURL = URL(string: baseURL + movie.poster)
        if let validURL = posterURL {
            self.animateUIView(validURL: validURL, posterView: posterView)
        }
        
        // add style
        titleLabel.textColor = UIColor.movieDbGreen()
    }
    
    func animateUIView(validURL: URL, posterView: UIImageView) {
        let smallImageRequest = NSURLRequest(url: validURL)
        let largeImageRequest = NSURLRequest(url: validURL)
        
        posterView.setImageWith(
            smallImageRequest as URLRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                posterView.alpha = 0.0
                posterView.image = smallImage;
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    posterView.alpha = 1.0
                    }, completion: { (sucess) -> Void in
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        posterView.setImageWith(
                            largeImageRequest as URLRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                posterView.image = largeImage;
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
        })
    }
}
