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

        let logger = self.logger
        container.register { (object: inout TaggedLoggerDependency) in
            object.logger = SimpleTaggedLogger(logger: logger, tag: String(describing: type(of: object)))
        }
        container.register { () -> Logger in logger }

        let imageLoader = self.imageLoader
        container.register { (object: inout ImageLoaderDependency) in object.imageLoader = imageLoader }
        container.register { () -> ImageLoader in imageLoader }

        let feedService = self.feedService
        container.register { (object: inout FeedServiceDependency) in object.feedService = feedService }
        container.register { () -> FeedService in feedService }

        let mediaService = self.mediaService
        container.register { (object: inout MediaServiceDependency) in object.mediaService = mediaService }
        container.register { () -> MediaService in mediaService }

        container.register { [unowned container] (object: inout DependencyContainerDependency) in object.container = container }

        return container
    }
}
