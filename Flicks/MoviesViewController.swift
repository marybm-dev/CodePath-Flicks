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

class MoviesViewController: UIViewController, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies = [Movie]()
    var shouldRefresh = false
    var isMoreDataLoading = false
    let refreshControl = UIRefreshControl()
    
    let baseURL = "https://image.tmdb.org/t/p/w500"
    var endPoint = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fetchData(shouldRefresh: false, offset: 0)
    }
    
    func fetchData(shouldRefresh: Bool, offset: Int) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)&offset=\(offset)")
        
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            
            // show activity indicator
            KVNProgress.show()
            
            self.parseData(response: dataOrNil, shouldRefresh: shouldRefresh)
            
        });
        task.resume()
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
                
                // stop activity indicator
                KVNProgress.dismiss()
                
                // if refreshing, stop
                if shouldRefresh {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies[(indexPath?.row)!]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        detailViewController.baseURL = self.baseURL
    }
}

