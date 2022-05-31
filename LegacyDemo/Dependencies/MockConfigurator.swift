//
// MockConfigurator
// LegacyDemo
//
// Created by Eugene Egorov on 29 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import Foundation
import Legacy

final class MockConfigurator: Configurator {
    init() {
    }

    private let timeout: TimeInterval = 60
    private let imagesMemoryCapacity: Int = 50 * 1024 * 1024
    private let imagesDiskCapacity: Int = 100 * 1024 * 1024

    private func imagesHttp(logger: Logger) -> Http {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2
        configuration.urlCache = URLCache(memoryCapacity: imagesMemoryCapacity, diskCapacity: imagesDiskCapacity, diskPath: nil)

        let logger = DefaultUrlSessionHttpLogger(logger: SimpleTaggedLogger(logger: logger, tag: "ImagesHttp"))
        let http = UrlSessionHttp(configuration: configuration, logger: logger)
        return http
    }

    func create() -> DependencyInjectionContainer {
        let logger = PrintLogger()
        let imagesHttp = self.imagesHttp(logger: logger)

        let imageLoader = AppImageLoader(imageLoader: HttpImageLoader(http: imagesHttp))
        let feedService = MockFeedService()
        let mediaService = MockMediaService()

        let builder = ContainerBuilder(
            logger: logger,
            imageLoader: imageLoader,
            feedService: feedService,
            mediaService: mediaService
        )
        return builder.build()
    }
}
