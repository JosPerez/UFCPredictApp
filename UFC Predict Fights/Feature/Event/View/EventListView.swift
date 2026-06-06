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
    @State private var showSettings = false
    @Environment(ThemeManager.self) private var themeManager

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
            // Header
            HStack {
                Text("Events")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                Spacer()
                // Sort toggle
                if vm.selectedFilter != .upcoming {
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
                }
                if vm.isSyncing {
                    ProgressView()
                        .tint(BSColors.accent)
                        .scaleEffect(0.7)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Upcoming / Completed toggle
            upcomingCompletedToggle(vm)

            // Search bar
            searchBar(vm)

            // Content
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
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Featured event (first upcoming)
                        if vm.selectedFilter == .upcoming, let featured = vm.events.first {
                            featuredEventCard(featured)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                                .padding(.top, 16)
                                .onTapGesture {
                                    path.append(featured.eventId)
                                }
                        }

                        // Year pills (solo si completed o all)
                        if vm.selectedFilter != .upcoming {
                            yearPills(vm)
                        }

                        // Count
                        HStack {
                            Text(vm.selectedFilter == .upcoming
                                ? "Upcoming events"
                                : "\(vm.eventCount) events")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(BSColors.textHint)
                                .textCase(.uppercase)
                                .kerning(1)
                            if vm.selectedFilter == .upcoming {
                                Text("\(vm.eventCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(BSColors.accent)
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)

                        // Event list
                        let startIndex = (vm.selectedFilter == .upcoming) ? 1 : 0
                        let displayEvents = Array(vm.events.dropFirst(startIndex))

                        ForEach(displayEvents, id: \.eventId) { event in
                            Button {
                                path.append(event.eventId)
                            } label: {
                                eventCard(event)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                            .onAppear {
                                vm.loadMore(currentItem: event)
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }
                .refreshable {
                    await vm.refresh()
                }
            }
        }
    }

    // MARK: - Upcoming / Completed Toggle

    @ViewBuilder
    private func upcomingCompletedToggle(_ vm: EventListViewModel) -> some View {
        HStack(spacing: 0) {
            toggleButton(
                title: "Upcoming",
                isSelected: vm.selectedFilter == .upcoming,
                action: { vm.selectFilter(.upcoming) }
            )
            toggleButton(
                title: "Completed",
                isSelected: vm.selectedFilter != .upcoming,
                action: { vm.selectFilter(.completed) }
            )
        }
        .padding(3)
        .background(BSColors.surface)
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    @ViewBuilder
    private func toggleButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : BSColors.textTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? BSColors.accent : Color.clear)
                .cornerRadius(8)
        }
    }

    // MARK: - Search Bar

    @ViewBuilder
    private func searchBar(_ vm: EventListViewModel) -> some View {
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
    }

    // MARK: - Year Pills

    @ViewBuilder
    private func yearPills(_ vm: EventListViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                DivisionPill(
                    title: "All",
                    isSelected: vm.selectedFilter == .completed
                ) {
                    vm.selectFilter(.completed)
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
            .padding(.vertical, 8)
        }
    }

    // MARK: - Featured Event Card

    @ViewBuilder
    private func featuredEventCard(_ event: CachedEvent) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Label
            Text("Featured event")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(BSColors.accent)
                .textCase(.uppercase)
                .kerning(1)

            // Event name
            Text(event.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(BSColors.textPrimary)

            // Location + date
            if let loc = event.location, !loc.isEmpty {
                Text(loc)
                    .font(.system(size: 13))
                    .foregroundColor(BSColors.textSecondary)
            }
            Text(formatEventDate(event.eventDate))
                .font(.system(size: 13))
                .foregroundColor(BSColors.textTertiary)

            // Badges row
            HStack(spacing: 8) {
                badgeChip(
                    icon: "figure.martial.arts",
                    text: "\(event.fightCount) Fights",
                    bg: BSColors.surfaceSecondary
                )
                if event.titleFights > 0 {
                    badgeChip(
                        icon: "trophy.fill",
                        text: "Title fight",
                        bg: BSColors.accent,
                        textColor: .white
                    )
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("View event")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(BSColors.textPrimary)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10))
                        .foregroundColor(BSColors.textTertiary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [BSColors.accent.opacity(0.15), BSColors.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(BSColors.accent.opacity(0.3), lineWidth: 0.5)
        )
    }

    // MARK: - Event Card

    @ViewBuilder
    private func eventCard(_ event: CachedEvent) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                // Event info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(event.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(BSColors.textPrimary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        if isPPV(event) {
                            Text("PPV")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(BSColors.accent)
                                .cornerRadius(3)
                        }
                    }

                    if let loc = event.location, !loc.isEmpty {
                        Text(loc)
                            .font(.system(size: 11))
                            .foregroundColor(BSColors.textSecondary)
                    }

                    Text(formatEventDate(event.eventDate))
                        .font(.system(size: 11))
                        .foregroundColor(BSColors.textTertiary)
                }

                Spacer()

                // Right side: fight count + title badge
                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(event.fightCount) Fights")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(BSColors.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(BSColors.surfaceSecondary)
                        .cornerRadius(6)

                    if event.titleFights > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 8))
                            Text("Title fight")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(BSColors.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(BSColors.accent.opacity(0.12))
                        .cornerRadius(6)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BSColors.surface)
        .cornerRadius(12)
        .overlay(alignment: .leading) {
            if event.titleFights > 0 {
                Rectangle()
                    .fill(BSColors.titleGold)
                    .frame(width: 3)
            } else if isPPV(event) {
                Rectangle()
                    .fill(BSColors.accent)
                    .frame(width: 3)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Components

    @ViewBuilder
    private func badgeChip(icon: String, text: String, bg: Color, textColor: Color = BSColors.textPrimary) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(textColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(bg)
        .cornerRadius(8)
    }

    // MARK: - Helpers

    private func isPPV(_ event: CachedEvent) -> Bool {
        event.name.range(of: #"^UFC \d+"#, options: .regularExpression) != nil
    }
    
    private func formatEventDate(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        let output = DateFormatter()
        output.dateFormat = "MMMM d, yyyy"
        return output.string(from: date)
    }
}
