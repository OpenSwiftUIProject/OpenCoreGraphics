//
//  CGGeometry+Hashable.swift
//  OpenCoreGraphics

// Only provide Hashable conformance on non-Darwin platforms with Swift < 6.2
// - On Darwin: CoreGraphics provides Hashable conformance
// - On Linux/Windows with Swift >= 6.2: swift-corelibs-foundation provides Hashable conformance
// - On Linux/Windows with Swift < 6.2: We provide Hashable conformance as a workaround
//
// See https://github.com/swiftlang/swift-corelibs-foundation/issues/5275
#if !canImport(Darwin) && compiler(<6.2)
public import Foundation

extension CGPoint: Swift.Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension CGSize: Swift.Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}

extension CGRect: Swift.Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin)
        hasher.combine(size)
    }
}
#endif
