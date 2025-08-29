// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

func envEnable(_ key: String, default defaultValue: Bool = false) -> Bool {
    guard let value = Context.environment[key] else {
        return defaultValue
    }
    if value == "1" {
        return true
    } else if value == "0" {
        return false
    } else {
        return defaultValue
    }
}

var sharedSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
]

#if os(macOS)
// NOTE: #if os(macOS) check is not accurate if we are cross compiling for Linux platform. So we add an env key to specify it.
let buildForDarwinPlatform = envEnable("OPENGRAPHICS_BUILD_FOR_DARWIN_PLATFORM", default: true)
#else
let buildForDarwinPlatform = envEnable("OPENGRAPHICS_BUILD_FOR_DARWIN_PLATFORM")
#endif

let coreGraphicsCondition = envEnable("OPENGRAPHICS_COREGRAPHICS", default: buildForDarwinPlatform)
if coreGraphicsCondition {
    sharedSwiftSettings.append(.define("OPENGRAPHICS_COREGRAPHICS"))
}

let warningsAsErrorsCondition = envEnable("OPENGRAPHICS_WERROR", default: true)
if warningsAsErrorsCondition {
    sharedSwiftSettings.append(.unsafeFlags(["-warnings-as-errors"]))
}

let package = Package(
    name: "OpenGraphics",
    products: [
        .library(name: "OpenGraphics", targets: ["OpenGraphics"]),
        .library(name: "OpenGraphicsShims", targets: ["OpenGraphicsShims"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3"),
    ],
    targets: [
        .target(name: "OpenGraphics"),
        .target(
            name: "OpenGraphicsShims",
            dependencies: ["OpenGraphics"],
            swiftSettings: sharedSwiftSettings,
            linkerSettings: [
                .linkedFramework("CoreGraphics", .when(platforms: .darwinPlatforms)),
            ]
        ),
        .testTarget(
            name: "OpenGraphicsShimsTests",
            dependencies: [
                "OpenGraphicsShims",
                .product(name: "Numerics", package: "swift-numerics"),
            ],
            swiftSettings: sharedSwiftSettings
        ),
    ]
)

extension [Platform] {
    static var darwinPlatforms: [Platform] {
        [.iOS, .macOS, .tvOS, .watchOS, .visionOS, .macCatalyst]
    }

    static var nonDarwinPlatforms: [Platform] {
        [.linux, .android, .wasi, .openbsd, .windows]
    }
}
