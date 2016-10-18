//
//  AppDelegateExtension.swift
//  Flicks
//
//  Created by Mary Martinez on 10/17/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

extension AppDelegate {
    func configureAppStyling() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = styleUIBars()
        window?.makeKeyAndVisible()
    }
    
    func styleNavigationBar() -> [UINavigationController] {
        // reference storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // reference navigation controller for Now Playing
        let nowPlayingNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationController") as! UINavigationController
        let nowPlayingViewController = nowPlayingNavigationController.topViewController as! MoviesViewController
        nowPlayingViewController.endPoint = "now_playing"
        nowPlayingNavigationController.tabBarItem.title = "Now Playing"
        nowPlayingNavigationController.tabBarItem.image = UIImage(named: "now_playing")
        
        // reference navigation controller for Top Rated
        let topRatedNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationController") as! UINavigationController
        let topRatedViewController = topRatedNavigationController.topViewController as! MoviesViewController
        topRatedViewController.endPoint = "top_rated"
        topRatedNavigationController.tabBarItem.title = "Top Rated"
        topRatedNavigationController.tabBarItem.image = UIImage(named: "top_rated")
        
        return [nowPlayingNavigationController, topRatedNavigationController]
    }
    
    func styleUIBars() -> UITabBarController {
        // setup the tab bar
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = styleNavigationBar()
        
        // add styles to nav and tab bars
        let navBar = UINavigationBar.appearance()
        navBar.tintColor = UIColor.movieDbGreen()       // bar button items
        navBar.barStyle = UIBarStyle.black              // bar style
        
        let tabBar = UITabBar.appearance()
        tabBar.tintColor = UIColor.movieDbGreen()       // bar button items
        tabBar.barStyle = UIBarStyle.black              // bar style
        
        return tabBarController
    }
    
    
}
