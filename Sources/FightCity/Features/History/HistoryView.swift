//
//  HistoryView.swift
//  FightCity
//
//  View displaying citation history with search and filtering
//

import SwiftUI
import FightCityFoundation
import FightCityiOS

public struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var searchText = ""
    @State private var selectedFilter: CitationFilter = .all
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.citations.isEmpty {
                    EmptyHistoryView(onAddTapped: {
                        // Navigate to capture
                    })
                } else {
                    historyList
                }
            }
            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search citations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterMenu
                }
            }
            .refreshable {
                await viewModel.loadCitations()
            }
            .task {
                await viewModel.loadCitations()
            }
        }
    }
    
    private var historyList: some View {
        List {
            ForEach(groupedCitations.keys.sorted().reversed(), id: \.self) { month in
                Section(header: Text(month)) {
                    ForEach(groupedCitations[month] ?? []) { citation in
                        NavigationLink(destination: CitationDetailView(citation: citation)) {
                            CitationRow(citation: citation)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var filterMenu: some View {
        // TODO: PHASE 2, TASK 2.3 - Implement history filtering
        // Current: UI exists but filtering is not wired
        // Required filters:
        // 1. By city (SF, LA, NYC, Denver, All)
        // 2. By status (All, Pending, Submitted, Resolved)
        // 3. By date range (Last 7 days, Last 30 days, Last year, All time)
        //
        // Implementation:
        // var filteredCitations: [Citation] {
        //     citations.filter { citation in
        //         // City filter
        //         if selectedCity != "All", citation.city != selectedCity { return false }
        //         // Status filter
        //         if selectedStatus != "All", citation.status != selectedStatus { return false }
        //         // Date filter
        //         if let startDate = dateRangeStart, citation.date < startDate { return false }
        //         return true
        //     }
        // }
        Menu {
            ForEach(CitationFilter.allCases, id: \.self) { filter in
                Button(action: {
                    selectedFilter = filter
                    viewModel.setFilter(filter)
                }) {
                    Label(filter.displayName, systemImage: filter.iconName)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
    
    private var groupedCitations: [String: [Citation]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        var groups: [String: [Citation]] = [:]
        
        let filtered = viewModel.citations.filter { citation in
            if searchText.isEmpty { return true }
            return citation.citationNumber.localizedCaseInsensitiveContains(searchText)
        }
        
        for citation in filtered {
            let key = formatter.string(from: citation.violationDate ?? Date())
            groups[key, default: []].append(citation)
        }
        
        return groups
    }
}

// MARK: - History View Model

@MainActor
public final class HistoryViewModel: ObservableObject {
    @Published public var citations: [Citation] = []
    @Published public var isLoading = false
    @Published public var error: Error?
    
    private let storage: HistoryStorageProtocol
    
    public init(storage: HistoryStorageProtocol = HistoryStorage()) {
        self.storage = storage
    }
    
    public func loadCitations() async {
        isLoading = true
        do {
            citations = try await storage.loadHistory()
            citations.sort { ($0.violationDate ?? .distantPast) > ($1.violationDate ?? .distantPast) }
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    public func setFilter(_ filter: CitationFilter) {
        // Apply filter logic
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
        case .paid: return "Paid"
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

// MARK: - Citation Row

struct CitationRow: View {
    let citation: Citation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(citation.citationNumber)
                    .font(.headline)
                Spacer()
                StatusBadge(status: citation.status)
            }
            
            HStack {
                if let city = citation.cityName {
                    Text(city)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let date = citation.violationDate {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let amount = citation.amount {
                Text(amount, format: .currency(code: "USD"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty History View

struct EmptyHistoryView: View {
    let onAddTapped: () -> Void
    
    var body: some View {
        EmptyStateView(
            icon: "tray",
            title: "No Citations Yet",
            message: "Capture your first parking ticket to get started.",
            buttonTitle: "Scan Ticket",
            buttonAction: onAddTapped
        )
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
        
        // Remove existing with same ID
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
