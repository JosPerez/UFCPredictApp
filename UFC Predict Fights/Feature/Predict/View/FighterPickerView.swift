//
//  FighterPickerView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import SwiftUI
import SwiftData

struct FighterPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let onSelect: (CachedFighter) -> Void
    var allowedWeightClasses: [String]? = nil

    @State private var searchText: String = ""
    @State private var results: [CachedFighter] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0A").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "444444"))
                            .font(.system(size: 16))
                        TextField("", text: $searchText)
                            .placeholder(when: searchText.isEmpty) {
                                Text("Search fighter...").foregroundColor(Color(hex: "444444"))
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .onChange(of: searchText) { _, _ in
                                search()
                            }
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(hex: "444444"))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    if results.isEmpty && !searchText.isEmpty {
                        Spacer()
                        Text("No fighters found")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "555555"))
                        Spacer()
                    } else if results.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 28))
                                .foregroundColor(Color(hex: "3a3a3a"))
                            Text("Type to search fighters")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "555555"))
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(results, id: \.fighterId) { fighter in
                                Button {
                                    onSelect(fighter)
                                    dismiss()
                                } label: {
                                    FighterRow(fighter: fighter)
                                }
                                .listRowBackground(Color(hex: "0A0A0A"))
                                .listRowSeparatorTint(Color(hex: "1a1a1a"))
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Select fighter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "0A0A0A"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(hex: "FF3B30"))
                }
            }
        }
    }

    private func search() {
        guard searchText.count >= 2 else {
            results = []
            return
        }
        
        let query = searchText
        var descriptor = FetchDescriptor<CachedFighter>(
            sortBy: [SortDescriptor(\.lastName)]
        )
        descriptor.fetchLimit = 20
        
        descriptor.predicate = #Predicate {
            $0.isActive == true &&
            ($0.firstName.localizedStandardContains(query) ||
             $0.lastName.localizedStandardContains(query))
        }
        
        let fetched = (try? modelContext.fetch(descriptor)) ?? []
        
        if let allowed = allowedWeightClasses, !allowed.isEmpty {
            results = fetched.filter {
                guard let weightClass = $0.weightClass else { return false }
                return allowed.contains(weightClass)
            }
            
        } else {
            results = fetched
        }
        
    }
}
