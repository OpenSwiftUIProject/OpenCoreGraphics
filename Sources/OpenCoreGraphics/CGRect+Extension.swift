//
//  CGRect+Extension.swift
//  OpenCoreGraphics

public import Foundation

#if canImport(Darwin)
extension CGRect {
    public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
    }

    public var width: CGFloat {
        return abs(size.width)
    }

    public var height: CGFloat {
        return abs(size.height)
    }

    public var minX: CGFloat {
        return min(origin.x, origin.x + size.width)
    }

    public var minY: CGFloat {
        return min(origin.y, origin.y + size.height)
    }

    public var maxX: CGFloat {
        return max(origin.x, origin.x + size.width)
    }

    public var maxY: CGFloat {
        return max(origin.y, origin.y + size.height)
    }

    public var midX: CGFloat {
        return origin.x + size.width / 2
    }

    public var midY: CGFloat {
        return origin.y + size.height / 2
    }

    public var isNull: Bool {
        return origin.x == .infinity || origin.y == .infinity
    }

    public var standardized: CGRect {
        guard !isNull else { return .null }
        return CGRect(x: minX, y: minY, width: width, height: height)
    }

    public func contains(_ point: CGPoint) -> Bool {
        return !isNull && point.x >= minX && point.x < maxX
            && point.y >= minY && point.y < maxY
    }

    public func intersects(_ rect: CGRect) -> Bool {
        guard !isNull && !rect.isNull else { return false }
        func overlaps(_ start: CGFloat, _ end: CGFloat, _ otherStart: CGFloat, _ otherEnd: CGFloat) -> Bool {
            if start == otherStart { return true }
            return start < otherStart ? otherStart < end : start < otherEnd
        }
        return overlaps(minX, maxX, rect.minX, rect.maxX)
            && overlaps(minY, maxY, rect.minY, rect.maxY)
    }

    public func union(_ rect: CGRect) -> CGRect {
        if isNull { return rect }
        if rect.isNull { return self }
        let x = min(minX, rect.minX)
        let y = min(minY, rect.minY)
        return CGRect(x: x, y: y, width: max(maxX, rect.maxX) - x, height: max(maxY, rect.maxY) - y)
    }

    public static let zero = CGRect(origin: .zero, size: .zero)
    public static let null = CGRect(x: CGFloat.infinity, y: CGFloat.infinity, width: 0, height: 0)
}

extension CGRect: Swift.Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin)
        hasher.combine(size)
    }

    public static func == (lhs: CGRect, rhs: CGRect) -> Bool {
        return lhs.origin == rhs.origin && lhs.size == rhs.size
    }
}
#endif

extension CGRect: Swift.CustomDebugStringConvertible {
    public var debugDescription: String {
        "(\(origin.x.description), \(origin.y.description), \(size.width.description), \(size.height.description))"
    }
}
