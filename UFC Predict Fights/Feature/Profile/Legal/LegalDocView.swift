//
//  LegalDocView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 17/06/26.
//

import SwiftUI
import WebKit

struct LegalDocView: View {
    let title: String
    let url: String

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            if let webURL = URL(string: url) {
                WebView(url: webURL)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                Text("Document not available")
                    .foregroundColor(BSColors.textTertiary)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}
