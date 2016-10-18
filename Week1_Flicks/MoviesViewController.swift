//
//  ViewController.swift
//  Flicks
//
//  Created by Mary Martinez on 10/13/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import SwiftyJSON
import AFNetworking
import KVNProgress

class MoviesViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var warningView: UIView!
    
    var movies = [Movie]()
    var shouldRefresh = false
    var isMoreDataLoading = false
    let refreshControl = UIRefreshControl()
    
    let baseURL = "https://image.tmdb.org/t/p/w500"
    var endPoint = String()
    
    let segmentControl = UISegmentedControl()
    var segmentBarItem: UIBarButtonItem!
    
    let moviesPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup view controls
        self.initControls()
        
        // get the data
        self.fetchData(page: currentPage, shouldRefresh: false, shouldAnimateDelay: true)
        
    }
    
    // Mark: App logic
    func initControls() {
        
        // init refresh control
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // init segment control for list/grid view
        segmentControl.frame = CGRect(x: 0, y: 0, width: 90, height: 30.0)
        segmentControl.insertSegment(with: UIImage(named: "list"), at: 0, animated: true)
        segmentControl.insertSegment(with: UIImage(named: "grid"), at: 1, animated: true)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentControlAction(segmentControl:)), for: .valueChanged)
        segmentBarItem = UIBarButtonItem(customView: segmentControl)
        self.navigationItem.rightBarButtonItem = segmentBarItem
    }
    
    func fetchData(page: Int, shouldRefresh: Bool, shouldAnimateDelay: Bool) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)&page=\(page)")
        
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        // check for internet connection
        warningView.isHidden = IJReachability.isConnectedToNetwork() ? true : false
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            
            // show activity indicator
            KVNProgress.show()
            
            // add delay to view activity indicator
            let delay = shouldAnimateDelay ? (DispatchTime.now() + 1) : DispatchTime.now()
            DispatchQueue.main.asyncAfter(deadline: delay) {
                
                // parse the response
                self.parseData(response: dataOrNil, shouldRefresh: shouldRefresh)
            }
            
        });
        task.resume()
        
        currentPage += 1
    }
    
    func parseData(response: Data?, shouldRefresh: Bool) {
        if let data = response {
            let json = JSON(data: data)
            
            // grab the results array containing movies
            if let moviesArray = json["results"].array {
                
                // iterate through each movie to get the properties
                for movie in moviesArray {
                    let movieTitle = movie["title"].string
                    let moviePoster = movie["poster_path"].string
                    let movieBackdrop = movie["backdrop_path"].string
                    let movieOverview = movie["overview"].string
                    
                    guard let title = movieTitle else {
                        continue
                    }
                    guard let poster = moviePoster else {
                        continue
                    }
                    guard let backdrop = movieBackdrop else {
                        continue
                    }
                    guard let overview = movieOverview else {
                        continue
                    }
                    
                    let currMovie = Movie(title: title, backdrop: backdrop, poster: poster, overview: overview)
                    movies.append(currMovie)
                }
                
                // update flag
                self.isMoreDataLoading = false
                
                // reload the table view
                self.tableView.reloadData()
                self.collectionView.reloadData()
                
                // stop activity indicator
                KVNProgress.dismiss()
                
                // if refreshing, stop
                if shouldRefresh {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func animateUIView(validURL: URL, posterView: UIImageView) {
        let imageRequest = URLRequest(url: validURL)
        
        posterView.setImageWith(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    posterView.alpha = 0.0
                    posterView.image = image
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        posterView.alpha = 1.0
                    })
                } else {
                    posterView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
    }
    
    // Mark: Refresh control
    func refreshControlAction(refreshControl: UIRefreshControl) {
        self.fetchData(page: 1, shouldRefresh: true, shouldAnimateDelay: false)
    }
    
    // Mark: Segment Control
    func segmentControlAction(segmentControl: UISegmentedControl) {
        var toView = UIView()
        var fromView = UIView()
        
        if segmentControl.selectedSegmentIndex == 0 {
            fromView = self.collectionView
            toView = self.tableView
        }
        else {
            fromView = self.tableView
            toView = self.collectionView
        }
        
        toView.frame = self.view.bounds
        UIView.transition(from: fromView, to: toView, duration: 0.25, options: UIViewAnimationOptions.transitionFlipFromRight, completion: nil)
    }
    
    // Mark: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMovieDetail" {

            // extract the indexPath from the proper source (tableView vs. collectionView)
            var indexPath: IndexPath?
            if segmentControl.selectedSegmentIndex == 0 {
                let cell = sender as! UITableViewCell
                indexPath = tableView.indexPath(for: cell)
            }
            else {
                let cell = sender as! UICollectionViewCell
                indexPath = collectionView.indexPath(for: cell)
            }
            
            // grab the movie at indexPath and display in DetailView
            let movie = movies[(indexPath?.row)!]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
            detailViewController.baseURL = self.baseURL
        }
    }

}

