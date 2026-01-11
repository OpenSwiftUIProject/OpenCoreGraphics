//
//  CALayer.swift
//  OpenCoreGraphics
//
//  Created by Kyle on 1/11/26.
//  Status: Empty

open class CALayer {
    open weak var delegate: CALayerDelegate?

    open var contents: CGImage?

    open var contentsScale: CGFloat = 1.0
}

extension CALayer: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func == (lhs: CALayer, rhs: CALayer) -> Bool {
        return lhs === rhs
    }
}

public protocol CALayerDelegate: AnyObject {
    func action(forKey event: String) -> CABasicAnimation?
}
