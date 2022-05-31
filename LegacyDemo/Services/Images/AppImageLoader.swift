//
// AppImageLoader
// LegacyDemo
//
// Created by Eugene Egorov on 05 September 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class AppImageLoader: ImageLoader {
    private let imageLoader: ImageLoader

    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
    }

    func load(url: URL, size: CGSize, mode: ResizeMode) async -> ImageLoaderResult {
        actor Loader {
            func load(dataUrl: URL?) -> ImageLoaderResult {
                if let dataUrl = dataUrl, let data = try? Data(contentsOf: dataUrl), let image = UIImage(data: data)?.prerenderedImage() {
                    return .success((data, image))
                } else {
                    return .failure(.creating)
                }
            }
        }

        if url.scheme == "app" {
            let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            let dataUrl = Bundle.main.url(forResource: path, withExtension: nil)
            return await Loader().load(dataUrl: dataUrl)
        } else if let scheme = url.scheme, let directory = Storage.schemeDirectories[scheme] {
            let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            let dataUrl = directory.appendingPathComponent(path)
            return await Loader().load(dataUrl: dataUrl)
        } else {
            return await imageLoader.load(url: url, size: size, mode: mode)
        }
    }
}
