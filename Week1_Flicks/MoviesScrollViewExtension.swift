//
//  MoviesScrollViewExtension.swift
//  Flicks
//
//  Created by Mary Martinez on 10/17/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

extension MoviesViewController: UIScrollViewDelegate {
    
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
                self.fetchData(page: currentPage, shouldRefresh: false, shouldAnimateDelay: true)
            }
        }
    }
}
