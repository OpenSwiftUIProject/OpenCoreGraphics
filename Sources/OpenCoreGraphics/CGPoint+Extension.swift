//
//  CGPoint+Extension.swift
//  OpenCoreGraphics
//

public import Foundation

#if canImport(Darwin)
extension CGPoint {
    public static let zero = CGPoint(x: .zero, y: .zero)
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    public static func == (lhs: CGPoint, rhs: CGPoint) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}
#endif

extension CGPoint: Swift.CustomDebugStringConvertible {
    public var debugDescription: String {
        "(\(x.description), \(y.description))"
    }
}
