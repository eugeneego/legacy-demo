//
// ProfileFlow
// LegacyDemo
//
// Created by Eugene Egorov on 19 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class ProfileFlow {
    private let container: DependencyInjectionContainer
    private let navigationController: UINavigationController
    private let profileViewController: ProfileViewController

    var viewController: UIViewController {
        navigationController
    }

    init(container: DependencyInjectionContainer) {
        self.container = container

        profileViewController = UIStoryboard(name: "Main", bundle: nil).instantiate()
        container.resolve(profileViewController)

        navigationController = UINavigationController(rootViewController: profileViewController)

        let tabImage = UIImage.system(name: "person")
        let tabSelectedImage = UIImage.system(name: "person.fill")
        navigationController.tabBarItem = UITabBarItem(title: "Profile", image: tabImage, selectedImage: tabSelectedImage)
    }
}
