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
let buildForDarwinPlatform = envEnable("OPENCOREGRAPHICS_BUILD_FOR_DARWIN_PLATFORM", default: true)
#else
let buildForDarwinPlatform = envEnable("OPENCOREGRAPHICS_BUILD_FOR_DARWIN_PLATFORM")
#endif

let isXcodeEnv = Context.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode"

let development = envEnable("OPENCOREGRAPHICS_DEVELOPMENT")

// MARK: - [env] OPENCOREGRAPHICS_COREGRAPHICS

let coreGraphicsCondition = envEnable("OPENCOREGRAPHICS_COREGRAPHICS", default: buildForDarwinPlatform)
if coreGraphicsCondition {
    sharedSwiftSettings.append(.define("OPENCOREGRAPHICS_COREGRAPHICS"))
}

// MARK: - [env] OPENCOREGRAPHICS_WERROR

let warningsAsErrorsCondition = envEnable("OPENCOREGRAPHICS_WERROR", default: isXcodeEnv && development)
if warningsAsErrorsCondition {
    sharedSwiftSettings.append(.unsafeFlags(["-warnings-as-errors"]))
}

// MARK: - [env] OPENCOREGRAPHICS_LIBRARY_EVOLUTION

let libraryEvolutionCondition = envEnable("OPENCOREGRAPHICS_LIBRARY_EVOLUTION", default: buildForDarwinPlatform)

if libraryEvolutionCondition {
    // NOTE: -enable-library-evolution will cause module verify failure for `swift build`.
    // Either set OPENCOREGRAPHICS_LIBRARY_EVOLUTION=0 or add `-Xswiftc -no-verify-emitted-module-interface` after `swift build`
    sharedSwiftSettings.append(.unsafeFlags(["-enable-library-evolution", "-no-verify-emitted-module-interface"]))
}

let package = Package(
    name: "OpenCoreGraphics",
    products: [
        .library(name: "OpenCoreGraphics", targets: ["OpenCoreGraphics"]),
        .library(name: "OpenCoreGraphicsShims", targets: ["OpenCoreGraphicsShims"]),
        .library(name: "OpenQuartzCore", targets: ["OpenQuartzCore"]),
        .library(name: "OpenQuartzCoreShims", targets: ["OpenQuartzCoreShims"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3"),
    ],
    targets: [
        .target(
            name: "OpenCoreGraphics",
            swiftSettings: sharedSwiftSettings
        ),
        .target(
            name: "OpenCoreGraphicsShims",
            dependencies: ["OpenCoreGraphics"],
            swiftSettings: sharedSwiftSettings,
            linkerSettings: [
                .linkedFramework("CoreGraphics", .when(platforms: .darwinPlatforms)),
            ]
        ),
        .testTarget(
            name: "OpenCoreGraphicsShimsTests",
            dependencies: [
                "OpenCoreGraphicsShims",
                .product(name: "Numerics", package: "swift-numerics"),
            ],
            swiftSettings: sharedSwiftSettings
        ),

        .target(
            name: "OpenQuartzCore",
            dependencies: ["OpenCoreGraphics"],
            swiftSettings: sharedSwiftSettings
        ),
        .target(
            name: "OpenQuartzCoreShims",
            dependencies: ["OpenQuartzCore"],
            swiftSettings: sharedSwiftSettings,
            linkerSettings: [
                .linkedFramework("QuartzCore", .when(platforms: .darwinPlatforms)),
            ]
        ),
        .testTarget(
            name: "OpenQuartzCoreShimsTests",
            dependencies: [
                "OpenQuartzCoreShims",
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
