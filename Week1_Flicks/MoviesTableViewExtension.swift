//
//  MoviesTableViewExtension.swift
//  Flicks
//
//  Created by Mary Martinez on 10/17/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

extension MoviesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.codepath.MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies[indexPath.row]
        let posterURL = URL(string: baseURL + movie.poster)
        
        cell.titleLabel.text = "\(movie.title)"
        cell.overviewLabel.text = "\(movie.overview)"
        
        // fade in image
        if let validURL = posterURL {
            self.animateUIView(validURL: validURL, posterView: cell.posterView)
        }
        
        // add style to cell
        cell.backgroundColor = UIColor.appleLightestGray()
        cell.titleLabel.textColor = UIColor.movieDbGreen()
        
        return cell
    }
    
    // Mark: TableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        // add style to selected
        cell?.contentView.backgroundColor = UIColor.movieDbGreen()
        let movieCell = cell as! MovieCell
        movieCell.titleLabel.textColor = UIColor.white
        
        self.performSegue(withIdentifier: "showMovieDetail", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        // revert style
        cell?.contentView.backgroundColor = UIColor.appleLightestGray()
        let movieCell = cell as! MovieCell
        movieCell.titleLabel.textColor = UIColor.movieDbGreen()
    }
}
