//
//  CGSize+Extension.swift
//  OpenCoreGraphics

public import Foundation

#if canImport(Darwin)
extension CGSize {
    public static let zero = CGSize(width: .zero, height: .zero)
}
#endif

extension CGSize: Swift.CustomDebugStringConvertible {
    public var debugDescription: String {
        "(\(width.description), \(height.description))"
    }
}
