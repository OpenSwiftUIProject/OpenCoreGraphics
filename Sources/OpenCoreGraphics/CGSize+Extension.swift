//
//  CGSize+Extension.swift
//  OpenCoreGraphics

public import Foundation

#if canImport(Darwin)
extension CGSize {
    public static let zero = CGSize(width: .zero, height: .zero)
}

extension CGSize: Swift.Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }

    public static func == (lhs: CGSize, rhs: CGSize) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }
}
#endif

extension CGSize: Swift.CustomDebugStringConvertible {
    public var debugDescription: String {
        "(\(width.description), \(height.description))"
    }
}
