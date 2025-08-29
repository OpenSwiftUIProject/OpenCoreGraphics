//
//  Shims.swift
//  OpenCoreGraphics

#if canImport(Darwin)
public import Foundation

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

}

extension CGPoint {
    public static let zero = CGPoint(x: .zero, y: .zero)
}
#endif
