//
//  HistoryView.swift
//  FightCityTickets
//
//  Citation history view
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var citations: [Citation] = []
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else if citations.isEmpty {
                emptyState
            } else {
                listView
            }
        }
        .navigationTitle("History")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    // Refresh
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            loadHistory()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textSecondary)
            
            Text("No Citations Yet")
                .headlineMedium()
            
            Text("Your scanned citations will appear here.")
                .bodyMedium()
                .foregroundColor(AppColors.textSecondary)
            
            PrimaryButton(title: "Scan First Citation") {
                coordinator.startCaptureFlow()
            }
            .padding(.top, 16)
        }
        .padding()
    }
    
    // MARK: - List View
    
    private var listView: some View {
        List(citations) { citation in
            CitationRow(citation: citation)
        }
        .listStyle(.plain)
    }
    
    // MARK: - Data Loading
    
    private func loadHistory() {
        isLoading = true
        
        // Load from local storage
        // In real implementation, load from UserDefaults or CoreData
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            citations = []
            isLoading = false
        }
    }
}

// MARK: - Citation Row

struct CitationRow: View {
    let citation: Citation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(citation.cityName ?? "Unknown City")
                    .labelMedium()
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                StatusBadge(
                    status: statusType,
                    text: citation.status.displayName
                )
            }
            
            Text(citation.displayCitationNumber)
                .citationNumber()
            
            if let deadline = citation.deadlineDate {
                HStack {
                    Text("Deadline:")
                        .bodySmall()
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(deadline)
                        .bodySmall()
                        .foregroundColor(citation.isUrgent ? AppColors.deadlineUrgent : AppColors.textPrimary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusType: StatusBadge.StatusType {
        switch citation.status {
        case .validated, .inReview:
            return .info
        case .appealed:
            return .warning
        case .approved:
            return .success
        case .denied:
            return .error
        default:
            return .info
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var config: AppConfig
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var telemetryEnabled: Bool
    @State private var showingTelemetryInfo = false
    
    init() {
        _telemetryEnabled = State(initialValue: AppConfig.shared.telemetryEnabled)
    }
    
    var body: some View {
        Form {
            Section("Telemetry") {
                Toggle("Share anonymous data to improve OCR", isOn: $telemetryEnabled)
                    .onChange(of: telemetryEnabled) { _, newValue in
                        config.setTelemetryEnabled(newValue)
                        TelemetryService.shared.setTelemetryEnabled(newValue)
                    }
                
                Button {
                    showingTelemetryInfo = true
                } label: {
                    HStack {
                        Text("What is shared?")
                        Spacer()
                        Image(systemName: "info.circle")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Button {
                    Task {
                        await TelemetryService.shared.uploadPending()
                    }
                } label: {
                    Text("Upload pending telemetry")
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Link(destination: URL(string: "https://fightcitytickets.com/privacy")!) {
                    Text("Privacy Policy")
                }
                
                Link(destination: URL(string: "https://fightcitytickets.com/terms")!) {
                    Text("Terms of Service")
                }
            }
            
            Section {
                Button(role: .destructive) {
                    // Clear all data
                } label: {
                    Text("Clear All Data")
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingTelemetryInfo) {
            TelemetryOptInSheet()
        }
    }
}

#if DEBUG
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HistoryView()
                .environmentObject(AppCoordinator())
                .environmentObject(AppConfig.shared)
        }
    }
}
#endif
