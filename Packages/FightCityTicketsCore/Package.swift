// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "FightCityTicketsCore",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .linux()
    ],
    products: [
        .library(
            name: "FightCityTicketsCore",
            targets: ["FightCityTicketsCore"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FightCityTicketsCore",
            dependencies: [],
            path: "Sources",
            sources: [
                "Domain",
                "Core",
                "Network"
            ],
            exclude: [
                ".gitkeep"
            ]
        ),
        .testTarget(
            name: "FightCityTicketsCoreTests",
            dependencies: ["FightCityTicketsCore"],
            path: "Tests",
            sources: [
                "CoreTests",
                "DomainTests",
                "NetworkTests"
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
