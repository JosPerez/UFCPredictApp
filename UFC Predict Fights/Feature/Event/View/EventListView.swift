//
//  EventListView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import SwiftUI
import BlackSpartan

@MainActor
struct EventListView: View {
    let repository: EventRepository
    @State private var viewModel: EventListViewModel?
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .top) {
                BSColors.background.ignoresSafeArea()

                if let viewModel {
                    content(viewModel)
                } else {
                    ProgressView().tint(BSColors.accent)
                }
            }
            .navigationDestination(for: Int.self) { eventId in
                EventDetailView(eventId: eventId)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = EventListViewModel(repository: repository)
            }
        }
    }

    @ViewBuilder
    private func content(_ vm: EventListViewModel) -> some View {
        VStack(spacing: 0) {
            // Nav title
            HStack {
                Text("Events")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                Spacer()
                Button {
                    vm.toggleSortOrder()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: vm.sortAscending ? "arrow.up" : "arrow.down")
                            .font(.system(size: 12, weight: .semibold))
                        Text(vm.sortAscending ? "Oldest" : "Newest")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(BSColors.accent)
                }
                if vm.isSyncing {
                    HStack(spacing: 4) {
                        ProgressView()
                            .tint(BSColors.accent)
                            .scaleEffect(0.7)
                        if let progress = vm.syncProgress {
                            Text(progress)
                                .font(.system(size: 9))
                                .foregroundColor(BSColors.textTertiary)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // SearchBar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(BSColors.textHint)
                    .font(.system(size: 16))
                TextField("", text: Bindable(vm).searchText)
                    .placeholder(when: vm.searchText.isEmpty) {
                        Text("Search event...").foregroundColor(BSColors.textHint)
                    }
                    .foregroundColor(BSColors.textPrimary)
                    .font(.system(size: 14))
                if !vm.searchText.isEmpty {
                    Button {
                        vm.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(BSColors.textHint)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(BSColors.surface)
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.top, 10)

            // Year pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    DivisionPill(
                        title: "Upcoming",
                        isSelected: vm.selectedFilter == .upcoming
                    ) {
                        vm.selectFilter(.upcoming)
                    }
                    DivisionPill(
                        title: "All",
                        isSelected: vm.selectedFilter == .all
                    ) {
                        vm.selectFilter(.all)
                    }
                    ForEach(vm.years, id: \.self) { year in
                        DivisionPill(
                            title: "\(year)",
                            isSelected: vm.selectedFilter == .year(year)
                        ) {
                            vm.selectFilter(.year(year))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }

            // Count
            HStack {
                if vm.searchText.isEmpty && vm.selectedFilter == .all {
                    Text("\(vm.eventCount) events")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(BSColors.textHint)
                        .textCase(.uppercase)
                        .kerning(1)
                } else {
                    HStack(spacing: 6) {
                        Text("\(vm.eventCount) results")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(BSColors.textHint)
                            .textCase(.uppercase)
                            .kerning(1)
                        if vm.selectedFilter != .all || !vm.searchText.isEmpty {
                            Button {
                                vm.searchText = ""
                                vm.selectFilter(.all)
                            } label: {
                                HStack(spacing: 3) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 8, weight: .bold))
                                    Text("Clear filters")
                                        .font(.system(size: 10, weight: .semibold))
                                }
                                .foregroundColor(BSColors.accent)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)

            // List
            if vm.isLoading && vm.events.isEmpty {
                Spacer()
                ProgressView().tint(BSColors.accent)
                Spacer()
            } else if let error = vm.errorMessage {
                ErrorStateView(message: error) {
                    vm.reload()
                }
            } else if vm.events.isEmpty {
                EmptyStateView(message: "No events found")
            } else {
                List {
                    ForEach(vm.events, id: \.eventId) { event in
                        NavigationLink(value: event.eventId) {
                            EventRow(event: event)
                        }
                        .listRowBackground(BSColors.background)
                        .listRowSeparator(.hidden)          // ← quitar separador
                        .listRowInsets(EdgeInsets(           // ← padding custom
                            top: 4, leading: 16, bottom: 4, trailing: 16
                        ))
                        .onAppear {
                            vm.loadMore(currentItem: event)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .refreshable {
                    await vm.refresh()
                }
                .tint(BSColors.accent)
            }
        }
    }
}

// MARK: - Event Row (ahora usa CachedEvent)

struct EventRow: View {
    let event: CachedEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Name + PPV badge
            HStack(alignment: .top, spacing: 8) {
                Text(event.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                if isPPV {
                    Text("PPV")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(BSColors.accent)
                        .cornerRadius(4)
                }
            }
            
            // Date + fight count + titles
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(BSColors.textTertiary)
                    Text(event.eventDate)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "888888"))
                }
                HStack(spacing: 4) {
                    Text("\(event.fightCount)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(BSColors.accent)
                    Text("fights")
                        .font(.system(size: 13))
                        .foregroundColor(BSColors.textTertiary)
                }
                if event.titleFights > 0 {
                    HStack(spacing: 4) {
                        Text("\(event.titleFights)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(BSColors.titleGold)
                        Text(event.titleFights == 1 ? "title" : "titles")
                            .font(.system(size: 13))
                            .foregroundColor(BSColors.textTertiary)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BSColors.surface)
        .cornerRadius(12)
        .overlay(alignment: .leading) {
            if accentColor != .clear {
                Rectangle()
                    .fill(accentColor)
                    .frame(width: 5)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var isPPV: Bool {
        event.name.range(of: #"^UFC \d+"#, options: .regularExpression) != nil
    }

    private var accentColor: Color {
        if event.titleFights > 0 {
            return BSColors.titleGold
        }
        if isPPV {
            return BSColors.accent
        }
        if event.name.contains("Fight Night") {
            return BSColors.textHint
        }
        return .clear
    }
}
