//
//  CachedAsyncImage.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 17/06/26.
//

import SwiftUI

struct CachedAsyncImage<Placeholder: View>: View {
    let url: String?
    let size: CGFloat
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var image: UIImage? = nil
    @State private var isLoading = false
    @State private var loadedURL: String? = nil

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                placeholder()
                    .frame(width: size, height: size)
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: url) { _, newURL in
            if newURL != loadedURL {
                image = nil
                isLoading = false
                loadedURL = nil
                loadImage()
            }
        }
    }
    
    private func loadImage() {
        guard let urlString = url, !urlString.isEmpty else { return }
        guard urlString != loadedURL, !isLoading else { return }
        
        // Check cache
        if let cached = ImageCacheManager.shared.get(key: urlString) {
            image = cached
            loadedURL = urlString
            return
        }
        
        // Download
        isLoading = true
        Task {
            if let downloaded = await ImageCacheManager.shared.download(urlString: urlString) {
                await MainActor.run {
                    image = downloaded
                    loadedURL = urlString
                    isLoading = false
                }
            } else {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}
