//
//  CGColor.swift
//  OpenCoreGraphics

public import Foundation

open class CGColor: NSObject {
    private enum Space: Hashable {
        case genericRGB
        case sRGB
        case genericGray
        case genericGrayGamma2_2
    }

    private let space: Space
    private let storedComponents: [CGFloat]

    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        space = .genericRGB
        storedComponents = [red, green, blue, alpha].map { min(max($0, 0), 1) }
        super.init()
    }

    public init(srgbRed red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        space = .sRGB
        storedComponents = [red, green, blue, alpha].map { min(max($0, 0), 1) }
        super.init()
    }

    public init(gray: CGFloat, alpha: CGFloat) {
        space = .genericGray
        storedComponents = [gray, alpha].map { min(max($0, 0), 1) }
        super.init()
    }

    public init(genericGrayGamma2_2Gray gray: CGFloat, alpha: CGFloat) {
        space = .genericGrayGamma2_2
        storedComponents = [gray, alpha].map { min(max($0, 0), 1) }
        super.init()
    }

    private init(space: Space, components: [CGFloat]) {
        self.space = space
        storedComponents = components
        super.init()
    }

    public class var black: CGColor {
        CGColor(genericGrayGamma2_2Gray: 0, alpha: 1)
    }

    public class var white: CGColor {
        CGColor(genericGrayGamma2_2Gray: 1, alpha: 1)
    }

    public class var clear: CGColor {
        CGColor(genericGrayGamma2_2Gray: 0, alpha: 0)
    }

    public var components: [CGFloat]? { storedComponents }

    public var numberOfComponents: Int { storedComponents.count }

    public var alpha: CGFloat { storedComponents[storedComponents.count - 1] }

    public func copy() -> CGColor? { self }

    public func copy(alpha: CGFloat) -> CGColor? {
        var components = storedComponents
        // Copying alpha does not apply the initializer's clamping.
        components[components.count - 1] = alpha
        return CGColor(space: space, components: components)
    }

    open override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CGColor else { return false }
        return self === other
            || (space == other.space && storedComponents == other.storedComponents)
    }

    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(space)
        hasher.combine(storedComponents)
        return hasher.finalize()
    }
}
