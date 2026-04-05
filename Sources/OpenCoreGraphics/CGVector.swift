//
//  CGVector.swift
//  OpenCoreGraphics

public import Foundation

// MARK: - CGVector

public struct CGVector: Equatable, Sendable {
    public init() {
        dx = .zero
        dy = .zero
    }

    public init(dx: CGFloat, dy: CGFloat) {
        self.dx = dx
        self.dy = dy
    }

    public var dx: CGFloat
    public var dy: CGFloat

    public static let zero = CGVector()
}

// MARK: - Hashable

extension CGVector: Swift.Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(dx)
        hasher.combine(dy)
    }
}

// MARK: - CustomDebugStringConvertible

extension CGVector: Swift.CustomDebugStringConvertible {
    public var debugDescription: String {
        "(\(dx.description), \(dy.description))"
    }
}
