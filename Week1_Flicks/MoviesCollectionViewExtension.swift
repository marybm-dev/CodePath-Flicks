//
//  MoviesCollectionViewExtension.swift
//  Flicks
//
//  Created by Mary Martinez on 10/17/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

extension MoviesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "com.codepath.MovieGridCell", for: indexPath) as! MovieGridCell
        
        let movie = movies[indexPath.row]
        let posterURL = URL(string: baseURL + movie.poster)
        
        cell.titleLabel.text = "\(movie.title)"
        
        // fade in image
        if let validURL = posterURL {
            self.animateUIView(validURL: validURL, posterView: cell.posterView)
        }
        
        // add style to cell
        cell.backgroundColor = UIColor.appleLightestGray()
        
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
    
    // Mark: CollectionView delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        // add style to selected
        cell?.contentView.backgroundColor = UIColor.movieDbGreen()
        
        self.performSegue(withIdentifier: "showMovieDetail", sender: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // revert style
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.appleLightestGray()
    }

}
