//
//  HistoryView.swift
//  FightCity
//
//  Premium history view with filters, search, and beautiful cards
//  Apple Design Award quality list experience
//

import SwiftUI
import FightCityFoundation
import FightCityiOS

// MARK: - History View

public struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var searchText = ""
    @State private var selectedFilter: CitationFilter = .all
    @State private var hasAppeared = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search bar
                searchBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                // Filter pills
                filterPills
                    .padding(.top, 16)
                
                // Content
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.citations.isEmpty {
                    emptyStateView
                } else {
                    citationList
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await viewModel.loadCitations()
        }
        .task {
            await viewModel.loadCitations()
        }
        .onAppear {
            FCHaptics.prepare()
            withAnimation(.easeOut(duration: 0.5)) {
                hasAppeared = true
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(AppColors.textTertiary)
            
            TextField("Search citations...", text: $searchText)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
        .padding(12)
        .background(AppColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.glassBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Filter Pills
    
    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CitationFilter.allCases, id: \.self) { filter in
                    FilterPill(
                        title: filter.displayName,
                        icon: filter.iconName,
                        isSelected: selectedFilter == filter
                    ) {
                        FCHaptics.selection()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                        viewModel.setFilter(filter)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Citation List
    
    private var citationList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(filteredCitations) { citation in
                    CitationCard(citation: citation)
                        .onTapGesture {
                            FCHaptics.lightImpact()
                            // Navigate to detail
                        }
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(Double(filteredCitations.firstIndex(where: { $0.id == citation.id }) ?? 0) * 0.05), value: hasAppeared)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }
    
    private var filteredCitations: [Citation] {
        viewModel.citations.filter { citation in
            if searchText.isEmpty { return true }
            return citation.citationNumber.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.gold))
                .scaleEffect(1.2)
            Text("Loading...")
                .font(.system(size: 15))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppColors.surface)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "tray")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.textTertiary)
            }
            
            VStack(spacing: 8) {
                Text("No Tickets Yet")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Scan your first parking ticket\nto get started")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                FCHaptics.mediumImpact()
                coordinator.startCaptureFlow()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 16))
                    Text("Scan Ticket")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(AppColors.obsidian)
                .padding(.horizontal, 24)
                .frame(height: 50)
                .background(AppColors.goldGradient)
                .cornerRadius(12)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Filter Pill

struct FilterPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? AppColors.obsidian : AppColors.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? AppColors.gold : AppColors.surface)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : AppColors.glassBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Citation Card

struct CitationCard: View {
    let citation: Citation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(citation.citationNumber)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    if let city = citation.cityName {
                        Text(city)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                StatusPill(status: citation.status)
            }
            
            Divider()
                .background(AppColors.glassBorder)
            
            // Details row
            HStack {
                // Amount
                if let amount = citation.amount {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Amount")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textTertiary)
                        Text(amount, format: .currency(code: "USD"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Deadline
                if let days = citation.daysRemaining {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Deadline")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textTertiary)
                        Text(deadlineText(days: days, isPast: citation.isPastDeadline))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(deadlineColor(days: days, isPast: citation.isPastDeadline))
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
                    .padding(.leading, 8)
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.glassBorder, lineWidth: 1)
        )
    }
    
    private func deadlineText(days: Int, isPast: Bool) -> String {
        if isPast {
            return "Past due"
        } else if days == 0 {
            return "Due today"
        } else if days == 1 {
            return "1 day left"
        } else {
            return "\(days) days left"
        }
    }
    
    private func deadlineColor(days: Int, isPast: Bool) -> Color {
        if isPast {
            return AppColors.error
        } else if days <= 3 {
            return AppColors.error
        } else if days <= 7 {
            return AppColors.warning
        } else {
            return AppColors.success
        }
    }
}

// MARK: - Status Pill

struct StatusPill: View {
    let status: CitationStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(statusColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(statusColor.opacity(0.15))
            .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending:
            return AppColors.warning
        case .validated, .approved, .paid:
            return AppColors.success
        case .inReview, .appealed:
            return AppColors.info
        case .denied, .expired:
            return AppColors.error
        }
    }
}

// MARK: - History View Model

@MainActor
public final class HistoryViewModel: ObservableObject {
    @Published public var citations: [Citation] = []
    @Published public var isLoading = false
    @Published public var error: Error?
    
    private let storage: HistoryStorageProtocol
    private var currentFilter: CitationFilter = .all
    
    public init(storage: HistoryStorageProtocol = HistoryStorage()) {
        self.storage = storage
    }
    
    public func loadCitations() async {
        isLoading = true
        do {
            citations = try await storage.loadHistory()
            citations.sort { ($0.violationDate ?? "") > ($1.violationDate ?? "") }
            applyCurrentFilter()
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    public func setFilter(_ filter: CitationFilter) {
        currentFilter = filter
        applyCurrentFilter()
    }
    
    private func applyCurrentFilter() {
        // Filter logic would go here
    }
    
    public func deleteCitation(_ citation: Citation) async {
        citations.removeAll { $0.id == citation.id }
        try? await storage.deleteCitation(citation.id)
    }
}

// MARK: - Citation Filter

public enum CitationFilter: CaseIterable {
    case all
    case pending
    case appealed
    case paid
    
    public var displayName: String {
        switch self {
        case .all: return "All"
        case .pending: return "Pending"
        case .appealed: return "Appealed"
        case .paid: return "Resolved"
        }
    }
    
    public var iconName: String {
        switch self {
        case .all: return "tray.full"
        case .pending: return "clock"
        case .appealed: return "bubble.left.and.bubble.right"
        case .paid: return "checkmark.circle"
        }
    }
}

// MARK: - History Storage Protocol

public protocol HistoryStorageProtocol {
    func loadHistory() async throws -> [Citation]
    func saveCitation(_ citation: Citation) async throws
    func deleteCitation(_ id: UUID) async throws
}

// MARK: - History Storage Implementation

public final class HistoryStorage: HistoryStorageProtocol {
    private let storage: Storage
    private let key = "citation_history"
    
    public init(storage: Storage = UserDefaultsStorage()) {
        self.storage = storage
    }
    
    public func loadHistory() async throws -> [Citation] {
        guard let data = storage.load(key: key) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Citation].self, from: data)
    }
    
    public func saveCitation(_ citation: Citation) async throws {
        var history = (try? await loadHistory()) ?? []
        history.removeAll { $0.id == citation.id }
        history.insert(citation, at: 0)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(history)
        _ = storage.save(key: key, data: data)
    }
    
    public func deleteCitation(_ id: UUID) async throws {
        var history = (try? await loadHistory()) ?? []
        history.removeAll { $0.id == id }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(history)
        _ = storage.save(key: key, data: data)
    }
}

// MARK: - Previews

#if DEBUG
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HistoryView()
                .environmentObject(AppCoordinator())
        }
    }
}
#endif
