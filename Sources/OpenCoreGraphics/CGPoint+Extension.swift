//
//  CGPoint+Extension.swift
//  OpenCoreGraphics
//

public import Foundation

#if canImport(Darwin)
extension CGPoint {
    public static let zero = CGPoint(x: .zero, y: .zero)
}
#endif

extension CGPoint: Swift.CustomDebugStringConvertible {
    public var debugDescription: String {
        "(\(x.description), \(y.description))"
    }
}
