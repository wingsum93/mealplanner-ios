//
//  ImageCacheConfig.swift
//  Meal Planner
//
//  Created by eric ho on 16/9/2026.
//

import Kingfisher

enum ImageCacheConfig {
    static func configure() {
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 256 * 1024 * 1024
        cache.memoryStorage.config.countLimit = 250
        cache.diskStorage.config.sizeLimit = 1024 * 1024 * 1024
        cache.diskStorage.config.expiration = .days(7)
    }
}
