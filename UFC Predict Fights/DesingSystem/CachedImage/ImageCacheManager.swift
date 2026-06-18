//
//  ImageCacheManager.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 17/06/26.
//

import UIKit
import CryptoKit

final class ImageCacheManager {

    static let shared = ImageCacheManager()
    private init() {
        createCacheDirectory()
    }

    // In-memory cache (fast, limited size)
    private let memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024  // 50 MB
        return cache
    }()

    // Disk cache directory
    private var cacheDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImageCache", isDirectory: true)
    }

    private let diskCacheTTL: TimeInterval = 7 * 24 * 60 * 60  // 7 days

    // MARK: - Get (memory → disk → nil)

    func get(key: String) -> UIImage? {
        let cacheKey = NSString(string: key)

        // Memory
        if let memImage = memoryCache.object(forKey: cacheKey) {
            return memImage
        }

        // Disk
        if let diskImage = loadFromDisk(key: key) {
            memoryCache.setObject(diskImage, forKey: cacheKey)
            return diskImage
        }

        return nil
    }

    // MARK: - Download + cache

    func download(urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200,
                  let image = UIImage(data: data) else {
                return nil
            }

            // Save to both caches
            let cacheKey = NSString(string: urlString)
            memoryCache.setObject(image, forKey: cacheKey)
            saveToDisk(data: data, key: urlString)

            return image
        } catch {
            return nil
        }
    }

    // MARK: - Disk Operations

    private func diskPath(key: String) -> URL {
        let hash = SHA256.hash(data: Data(key.utf8))
        let filename = hash.compactMap { String(format: "%02x", $0) }.joined()
        return cacheDirectory.appendingPathComponent(filename)
    }

    private func saveToDisk(data: Data, key: String) {
        let path = diskPath(key: key)
        try? data.write(to: path)
    }

    private func loadFromDisk(key: String) -> UIImage? {
        let path = diskPath(key: key)

        guard FileManager.default.fileExists(atPath: path.path) else { return nil }

        // Check TTL
        if let attrs = try? FileManager.default.attributesOfItem(atPath: path.path),
           let modified = attrs[.modificationDate] as? Date,
           Date().timeIntervalSince(modified) > diskCacheTTL {
            try? FileManager.default.removeItem(at: path)
            return nil
        }

        guard let data = try? Data(contentsOf: path) else { return nil }
        return UIImage(data: data)
    }

    private func createCacheDirectory() {
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Cleanup

    func clearMemory() {
        memoryCache.removeAllObjects()
    }

    func clearDisk() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        createCacheDirectory()
    }

    func clearAll() {
        clearMemory()
        clearDisk()
    }

    func clearExpired() {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey]
        ) else { return }

        for file in files {
            if let attrs = try? FileManager.default.attributesOfItem(atPath: file.path),
               let modified = attrs[.modificationDate] as? Date,
               Date().timeIntervalSince(modified) > diskCacheTTL {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}
