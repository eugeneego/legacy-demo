//
// RestConfigurator
// LegacyDemo
//
// Created by Eugene Egorov on 29 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import Foundation
import Legacy

class RestConfigurator: Configurator {
    private let baseUrl: URL

    init(baseUrl: URL) {
        self.baseUrl = baseUrl
    }

    private let timeout: TimeInterval = 60
    private let imagesMemoryCapacity: Int = 50 * 1024 * 1024
    private let imagesDiskCapacity: Int = 100 * 1024 * 1024

    private func apiHttp(logger: Logger) -> Http {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2
        configuration.urlCache = nil

        let trustPolicies: [String: ServerTrustPolicy] = [
            "test.com": .disabled,
            "google.com": .default(checkHost: true),
            "eego.pro": .hpkp(
                hashes: Hpkp.hashes([ "ByG1podSp1TMfs8+uEHLkV8vPVjTJv0K2ftHppjzKB8=" ]),
                algorithms: [ .rsa2048, .rsa4096 ],
                checkChain: true,
                checkHost: true
            )
        ]

        let queue = DispatchQueue.global(qos: .default)
        let http = UrlSessionHttp(configuration: configuration, responseQueue: queue, logger: logger, loggerTag: "ApiHttp")
        http.trustPolicies = trustPolicies
        return http
    }

    private func imagesHttp(logger: Logger) -> Http {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2
        configuration.urlCache = URLCache(memoryCapacity: imagesMemoryCapacity, diskCapacity: imagesDiskCapacity, diskPath: nil)

        let queue = DispatchQueue.global(qos: .default)
        let http = UrlSessionHttp(configuration: configuration, responseQueue: queue, logger: logger, loggerTag: "ImagesHttp")
        return http
    }

    private func rest(baseUrl: URL, http: Http) -> LightRestClient {
        let url = baseUrl.appendingPathComponent("feed", isDirectory: true)
        let queue = DispatchQueue.global(qos: .default)
        let rest = BaseRestClient(http: http, baseURL: url, workQueue: queue, completionQueue: DispatchQueue.main)
        return rest
    }

    func create() -> DependencyInjectionContainer {
        let logger = PrintLogger()
        let apiHttp = self.apiHttp(logger: logger)
        let imagesHttp = self.imagesHttp(logger: logger)
        let imageLoader = AppImageLoader(imageLoader: HttpImageLoader(http: imagesHttp))

        let feedUrl = baseUrl.appendingPathComponent("feed", isDirectory: true)
        let feedService = RestFeedService(rest: rest(baseUrl: feedUrl, http: apiHttp))

        let mediaUrl = baseUrl.appendingPathComponent("media", isDirectory: true)
        let mediaService = RestMediaService(rest: rest(baseUrl: mediaUrl, http: apiHttp))

        let builder = ContainerBuilder(
            logger: logger,
            imageLoader: imageLoader,
            feedService: feedService,
            mediaService: mediaService
        )
        return builder.build()
    }
}
