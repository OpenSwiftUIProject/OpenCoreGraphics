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
        return size.width
    }

    public var height: CGFloat {
        return size.height
    }

    public var minX: CGFloat {
        return origin.x
    }

    public var minY: CGFloat {
        return origin.y
    }

    public var maxX: CGFloat {
        return origin.x + size.width
    }

    public var maxY: CGFloat {
        return origin.y + size.height
    }

    public static let zero = CGRect(origin: .zero, size: .zero)
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
