//
//  LocationVerifier.swift
//  FightCityiOS
//
//  MapKit Look Around integration for location evidence collection
//

import MapKit
import CoreLocation

import os.log

/// APPLE INTELLIGENCE: MapKit Look Around for street-level evidence collection
/// APPLE INTELLIGENCE: iOS 17+ feature for capturing location context
/// APPLE INTELLIGENCE: Snapshot-based evidence for appeal support

// MARK: - Location Evidence

/// Location evidence captured for appeal
public struct LocationEvidence {
    public let coordinate: CLLocationCoordinate2D
    public let snapshotImage: UIImage?
    public let address: String?
    public let timestamp: Date
    public let lookAroundSupported: Bool
    public let nearbyLandmarks: [String]
    public let streetName: String?
    
    public init(
        coordinate: CLLocationCoordinate2D,
        snapshotImage: UIImage? = nil,
        address: String? = nil,
        timestamp: Date = Date(),
        lookAroundSupported: Bool,
        nearbyLandmarks: [String] = [],
        streetName: String? = nil
    ) {
        self.coordinate = coordinate
        self.snapshotImage = snapshotImage
        self.address = address
        self.timestamp = timestamp
        self.lookAroundSupported = lookAroundSupported
        self.nearbyLandmarks = nearbyLandmarks
        self.streetName = streetName
    }
}

// MARK: - Location Verifier

/// Location verification service using MapKit Look Around
public final class LocationVerifier {
    
    // MARK: - Properties
    
    /// Shared instance
    public static let shared = LocationVerifier()
    
    /// Whether Look Around is available on device
    public var isLookAroundAvailable: Bool {
        if #available(iOS 17.0, *) {
            return true
        } else {
            return false
        }
    }
    
    /// Map snapshotter for Look Around
    @available(iOS 17.0, *)
    private var lookAroundSnapshotter: MKLookAroundSnapshotter?
    
    /// Geocoder for address lookup
    private let geocoder = CLGeocoder()
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Public Methods
    
    /// Capture location evidence using Look Around
    /// - Parameter coordinate: Location coordinate to capture
    /// - Returns: Location evidence with snapshot
    @available(iOS 16.0, *)
    public func captureEvidence(at coordinate: CLLocationCoordinate2D) async -> LocationEvidence {
        let address = await geocodeCoordinate(coordinate)
        let streetName = extractStreetName(from: address)
        
        // Check if Look Around is available (iOS 17+)
        if #available(iOS 17.0, *) {
            let snapshot = await captureLookAroundSnapshot(at: coordinate)
            let landmarks = await discoverLandmarks(near: coordinate)
            
            return LocationEvidence(
                coordinate: coordinate,
                snapshotImage: snapshot,
                address: address,
                lookAroundSupported: true,
                nearbyLandmarks: landmarks,
                streetName: streetName
            )
        } else {
            // Fallback to standard map snapshot
            let snapshot = await captureStandardMapSnapshot(at: coordinate)
            
            return LocationEvidence(
                coordinate: coordinate,
                snapshotImage: snapshot,
                address: address,
                lookAroundSupported: false,
                nearbyLandmarks: [],
                streetName: streetName
            )
        }
    }
    
    /// Check if Look Around is available at a location
    /// - Parameter coordinate: Location to check
    /// - Returns: Whether Look Around is available at that location
    @available(iOS 17.0, *)
    public func isLookAroundAvailable(at coordinate: CLLocationCoordinate2D) async -> Bool {
        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        
        do {
            let scene = try await request.scene
            return scene != nil
        } catch {
            return false
        }
    }
    
    /// Get nearby points of interest
    /// - Parameter coordinate: Center coordinate
    /// - Returns: Array of nearby points of interest
    @available(iOS 16.0, *)
    public func getNearbyPOIs(at coordinate: CLLocationCoordinate2D, radius: Double = 500) async -> [MKMapItem] {
        // Use MKLocalSearch as fallback since MKLocalPointsOfInterestRequest API may vary
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurants"
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        
        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            return response.mapItems
        } catch {
            return []
        }
    }
    
    /// Reverse geocode coordinate to address
    /// - Parameter coordinate: Location coordinate
    /// - Returns: Formatted address string
    private func geocodeCoordinate(_ coordinate: CLLocationCoordinate2D) async -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.compactAddress
        } catch {
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    @available(iOS 17.0, *)
    private func captureLookAroundSnapshot(at coordinate: CLLocationCoordinate2D) async -> UIImage? {
        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        
        do {
            guard let scene = try await request.scene else {
                return nil
            }
            
            let options = MKLookAroundSnapshotter.Options()
            options.size = CGSize(width: 800, height: 600)
            
            let snapshotter = MKLookAroundSnapshotter(scene: scene, options: options)
            
            do {
                return try await snapshotter.snapshot.image
            } catch {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    private func captureStandardMapSnapshot(at coordinate: CLLocationCoordinate2D) async -> UIImage? {
        let options = MKMapSnapshotter.Options()
        options.size = CGSize(width: 800, height: 600)
        options.mapType = .standard
        
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 200,
            longitudinalMeters: 200
        )
        options.region = region
        
        let snapshotter = MKMapSnapshotter(options: options)
        
        do {
            let snapshot = try await snapshotter.start()
            return snapshot.image
        } catch {
            return nil
        }
    }
    
    @available(iOS 16.0, *)
    private func discoverLandmarks(near coordinate: CLLocationCoordinate2D) async -> [String] {
        // Use MKLocalSearch for landmark discovery
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "landmarks"
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        
        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            
            return response.mapItems.prefix(5).compactMap { item in
                item.name
            }
        } catch {
            return []
        }
    }
    
    private func extractStreetName(from address: String?) -> String? {
        guard let address = address else { return nil }
        
        // Simple extraction - look for street name patterns
        let components = address.components(separatedBy: ",")
        return components.first?.trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - CLPlacemark Extension

extension CLPlacemark {
    var compactAddress: String? {
        var components: [String] = []
        
        if let streetNumber = name {
            components.append(streetNumber)
        }
        
        if let city = locality {
            components.append(city)
        }
        
        if let state = administrativeArea {
            components.append(state)
        }
        
        if let zip = postalCode {
            components.append(zip)
        }
        
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}

// MARK: - Evidence Collection Error

extension LocationVerifier {
    /// Error types for location verification
    public enum LocationEvidenceError: LocalizedError {
        case lookAroundNotAvailable
        case snapshotFailed
        case geocodingFailed
        case noLocationPermission
        
        public var errorDescription: String? {
            switch self {
            case .lookAroundNotAvailable:
                return "Look Around is not available at this location"
            case .snapshotFailed:
                return "Failed to capture location snapshot"
            case .geocodingFailed:
                return "Failed to determine address for location"
            case .noLocationPermission:
                return "Location access not granted"
            }
        }
    }
}

// MARK: - Mock Location for Previews

extension LocationVerifier {
    /// Create mock location evidence for previews
    public static func mockEvidence() -> LocationEvidence {
        LocationEvidence(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            snapshotImage: nil,
            address: "123 Main St, San Francisco, CA 94102",
            lookAroundSupported: true,
            nearbyLandmarks: ["City Hall", "UN Plaza"],
            streetName: "Main St"
        )
    }
}
