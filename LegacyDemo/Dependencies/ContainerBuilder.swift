//
// ContainerBuilder
// LegacyDemo
//
// Created by Eugene Egorov on 06 May 2019.
// Copyright (c) 2019 Eugene Egorov. All rights reserved.
//

import Legacy

struct ContainerBuilder {
    let logger: Logger
    let imageLoader: ImageLoader
    let feedService: FeedService
    let mediaService: MediaService

    func build() -> DependencyInjectionContainer {
        let container = Odin()

        container.register { [logger] (object: inout TaggedLoggerDependency) in
            object.logger = SimpleTaggedLogger(logger: logger, tag: String(describing: type(of: object)))
        }
        container.register { [logger] () -> Logger in logger }

        container.register { [imageLoader] (object: inout ImageLoaderDependency) in object.imageLoader = imageLoader }
        container.register { [imageLoader] () -> ImageLoader in imageLoader }

        container.register { [feedService] (object: inout FeedServiceDependency) in object.feedService = feedService }
        container.register { [feedService] () -> FeedService in feedService }

        container.register { [mediaService] (object: inout MediaServiceDependency) in object.mediaService = mediaService }
        container.register { [mediaService] () -> MediaService in mediaService }

        container.register { [unowned container] (object: inout DependencyContainerDependency) in object.container = container }

        return container
    }
}
