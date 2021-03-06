//
// FeedFlow
// LegacyDemo
//
// Created by Eugene Egorov on 19 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class FeedFlow {
    private let container: DependencyInjectionContainer
    private let navigationController: UINavigationController
    private let feedViewController: FeedViewController

    var viewController: UIViewController {
        navigationController
    }

    init(container: DependencyInjectionContainer) {
        self.container = container

        feedViewController = UIStoryboard(name: "Main", bundle: nil).instantiate()
        container.resolve(feedViewController)

        navigationController = UINavigationController(rootViewController: feedViewController)

        let tabImage = UIImage.system(name: "table")
        let tabSelectedImage = UIImage.system(name: "table.fill")
        navigationController.tabBarItem = UITabBarItem(title: "Feed", image: tabImage, selectedImage: tabSelectedImage)
    }
}
