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

class MoviesViewController: UIViewController, UITableViewDataSource, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
        
        // check for internet connection
        warningView.isHidden = IJReachability.isConnectedToNetwork() ? true : false
        
        // default view is tableView so remove collectionView
        //self.view.willRemoveSubview(collectionView)
        
        // get the data
        self.fetchData(shouldRefresh: false, page: currentPage)
        
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
    
    // Mark: Refresh control
    func refreshControlAction(refreshControl: UIRefreshControl) {
        self.fetchData(shouldRefresh: true, page: 1)
    }
    
    // Mark: App logic
    func fetchData(shouldRefresh: Bool, page: Int) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)&page=\(page)")
        
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            
            // show activity indicator
            KVNProgress.show()
            
            // parse the response
            self.parseData(response: dataOrNil, shouldRefresh: shouldRefresh)
            
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

    // Mark: TableView data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.codepath.MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies[indexPath.row]
        let posterURL = URL(string: baseURL + movie.poster)
        
        cell.titleLabel.text = "\(movie.title)"
        cell.overviewLabel.text = "\(movie.overview)"
        
        if let validURL = posterURL {
            cell.posterView.setImageWith(validURL)
        }
        
        return cell
    }
    
    // MARK: CollectionView data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "com.codepath.MovieGridCell", for: indexPath) as! MovieGridCell
        
        let movie = movies[indexPath.row]
        let posterURL = URL(string: baseURL + movie.poster)
        
        cell.titleLabel.text = "\(movie.title)"
        
        if let validURL = posterURL {
            cell.posterView.setImageWith(validURL)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (moviesPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / moviesPerRow
        
        return CGSize(width: widthPerItem, height: 178.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    // MARK: ScrollView delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let currentView = (segmentControl.selectedSegmentIndex == 0) ? tableView : collectionView
        
        if !isMoreDataLoading {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = currentView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - currentView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && currentView.isDragging) {
                isMoreDataLoading = true
                
                // ... Code to load more results ...
                self.fetchData(shouldRefresh: false, page: currentPage)
            }
        }
    }
    
    // Mark: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies[(indexPath?.row)!]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        detailViewController.baseURL = self.baseURL
    }

}

