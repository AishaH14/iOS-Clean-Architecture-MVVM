//
//  MainTabBarController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 18/11/1447 AH.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let height: CGFloat = 70
        let sideMargin: CGFloat = 24
        let bottomMargin: CGFloat = 24
        
        tabBar.frame = CGRect(
            x: sideMargin,
            y: view.frame.height - height - bottomMargin,
            width: view.frame.width - (sideMargin * 2),
            height: height
        )
        
        tabBar.layer.cornerRadius = 28
        tabBar.layer.masksToBounds = true
    }
}
