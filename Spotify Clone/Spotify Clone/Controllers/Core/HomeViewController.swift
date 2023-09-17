//
//  ViewController.swift
//  Spotify Clone
//
//  Created by Bryan Yong on 03/09/2023.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "gear"),
            style: .done,
            target: self,
            action: #selector(didTapSettings)
        )
    }

    @objc func didTapSettings() {
        let vc = ProfileViewController()
        vc.title = "Profile"
        vc .navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

