//
//  HomeViewController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/11/1447 AH.
//

import UIKit

final class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

// MARK: - Private
private extension HomeViewController {
    
    func setupView() {
        view.backgroundColor = .white
        title = "Home"
    }
}
