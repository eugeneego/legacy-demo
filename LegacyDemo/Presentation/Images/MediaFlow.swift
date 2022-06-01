//
// MediaFlow
// LegacyDemo
//
// Created by Eugene Egorov on 19 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy
import LegacyGallery

class MediaFlow {
    var viewController: UIViewController {
        navigationController
    }

    private let container: DependencyInjectionContainer
    private let mediaService: MediaService
    private let imageLoader: ImageLoader

    private let navigationController: UINavigationController
    private let mediaViewController: MediaViewController

    init(container: DependencyInjectionContainer, mediaService: MediaService, imageLoader: ImageLoader) {
        self.container = container
        self.mediaService = mediaService
        self.imageLoader = imageLoader

        mediaViewController = UIStoryboard(name: "Main", bundle: nil).instantiate()

        navigationController = UINavigationController(rootViewController: mediaViewController)

        let tabImage = UIImage.system(name: "photo")
        let tabSelectedImage = UIImage.system(name: "photo.fill")
        navigationController.tabBarItem = UITabBarItem(title: "Media", image: tabImage, selectedImage: tabSelectedImage)

        container.resolve(mediaViewController)
        mediaViewController.input = MediaViewController.Input(media: mediaService.media)
        mediaViewController.output = MediaViewController.Output(selectMedia: gallery, showModalList: showModalList)
    }

    private func showModalList() {
        let flow = MediaFlow(container: container, mediaService: mediaService, imageLoader: imageLoader)
        mediaViewController.present(flow.viewController, animated: true)
    }

    private func gallery(media: [Media], index: Int, image: UIImage?) {
        let media = media.enumerated().map { item -> GalleryMedia in
            switch item.element {
                case .image(let url):
                    return .image(GalleryMedia.Image(
                        previewImage: item.offset == index ? image : nil,
                        previewImageLoader: { [imageLoader] size in
                            let result = await imageLoader.load(url: url, size: size, mode: .fill)
                            return result.map(success: { .success($0.image) }, failure: { .failure($0) })
                        },
                        fullImage: nil,
                        fullImageLoader: { [imageLoader] in
                            let result = await imageLoader.load(url: url, size: .zero, mode: .original)
                            return result.map(success: { .success($0.image) }, failure: { .failure($0) })
                        }
                    ))
                case .video(let url, let thumbnail):
                    return .video(GalleryMedia.Video(
                        source: nil,
                        previewImage: item.offset == index ? image : nil,
                        previewImageLoader: thumbnail.map { thumbnail in
                            { [imageLoader] size in // swiftlint:disable:this opening_brace
                                let result = await imageLoader.load(url: thumbnail, size: size, mode: .fill)
                                return result.map(success: { .success($0.image) }, failure: { .failure($0) })
                            }
                        },
                        videoLoader: {
                            if url.scheme == "app" {
                                let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                                let localUrl = Bundle.main.url(forResource: path, withExtension: nil)
                                return Result(localUrl.map { .url($0) }, MediaError.unknown(nil))
                            } else if let scheme = url.scheme, let directory = Storage.schemeDirectories[scheme] {
                                let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                                let localUrl = directory.appendingPathComponent(path)
                                return .success(.url(localUrl))
                            } else {
                                return .success(.url(url))
                            }
                        }
                    ))
            }
        }

        let backgroundColor = UIColor.systemBackground
        let actionColor = UIColor.orange

        let previewView = createGalleryPreview(backgroundColor: backgroundColor)

        let setupItemAppearance = { (controller: GalleryItemViewController) in
            controller.view.backgroundColor = backgroundColor
            controller.titleView.backgroundColor = backgroundColor
            controller.loadingIndicatorView.color = actionColor
            controller.closeButton.setTitleColor(actionColor, for: .normal)
            controller.shareButton.setTitleColor(actionColor, for: .normal)
        }

        let controller = GalleryViewController(spacing: 20)
        container.resolve(controller)
        controller.items = media
        controller.initialIndex = index
        controller.transitionController = GalleryZoomTransitionController()
        controller.sharedControls = true
        controller.availableControls = [ .close, .share ]
        controller.initialControlsVisibility = true
        controller.statusBarStyle = .default
        controller.viewerForItem = { [container] item in
            switch item {
                case .image(let image):
                    let controller = GalleryImageViewController(image: image)
                    container.resolve(controller)
                    controller.setupAppearance = setupItemAppearance
                    return controller
                case .video(let video):
                    let controller = GalleryLightVideoViewController(video: video)
                    container.resolve(controller)
                    controller.setupAppearance = setupItemAppearance
                    return controller
            }
        }
        controller.setupAppearance = { controller in
            controller.initialControlsVisibility = true
            controller.view.backgroundColor = backgroundColor
            controller.titleView.backgroundColor = backgroundColor
            controller.closeButton.setTitleColor(actionColor, for: .normal)
            controller.shareButton.setTitleColor(actionColor, for: .normal)

            previewView.translatesAutoresizingMaskIntoConstraints = false
            controller.view.addSubview(previewView)
            NSLayoutConstraint.activate([
                previewView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
                previewView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
                previewView.bottomAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor),
                previewView.heightAnchor.constraint(equalToConstant: 80),
            ])
            previewView.items = controller.items
        }
        previewView.selectAction = { [weak controller, weak previewView] index in
            controller?.move(to: index, animated: true)
            previewView?.selectItem(at: index, animated: true)
        }
        controller.pageChanged = { [weak self] currentIndex in
            self?.mediaViewController.currentIndex = currentIndex
            previewView.selectItem(at: currentIndex, animated: true)
        }
        controller.viewAppeared = { controller in
            previewView.selectItem(at: controller.currentIndex, animated: true)
        }
        controller.controlsVisibilityChanged = { controlsVisibility in
            previewView.alpha = controlsVisibility ? 1 : 0
        }

        navigationController.topViewController?.present(controller, animated: true, completion: nil)
    }

    private func createGalleryPreview(backgroundColor: UIColor) -> GalleryPreviewCollectionView {
        let previewView = GalleryPreviewCollectionView()
        previewView.layout.itemSize = CGSize(width: 48, height: 64)
        previewView.layout.minimumInteritemSpacing = 4
        previewView.layout.minimumLineSpacing = 4
        previewView.layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        previewView.backgroundColor = .clear
        previewView.clipsToBounds = false
        previewView.cellSetup = { cell in
            cell.clipsToBounds = false
            cell.contentView.clipsToBounds = false

            if cell.selectedBackgroundView == nil {
                let view = UIView()
                view.clipsToBounds = false
                view.backgroundColor = backgroundColor
                view.layer.shadowRadius = 8
                view.layer.shadowOffset = CGSize(width: 0, height: 4)
                view.layer.shadowColor = UIColor.black.cgColor
                view.layer.shadowOpacity = 0.5
                cell.selectedBackgroundView = view
            }

            if let cell = cell as? GalleryPreviewCollectionCell, cell.videoIconView.image == nil {
                cell.videoIconView.contentMode = .scaleAspectFit
                cell.videoIconView.image = UIImage(named: "icon-play")
                cell.videoIconView.tintColor = .white
            }
        }
        return previewView
    }
}
