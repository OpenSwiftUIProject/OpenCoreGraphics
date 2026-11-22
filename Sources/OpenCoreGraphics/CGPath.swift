//
//  CGPath.swift
//  OpenCoreGraphics
//
//  License: MIT
//  Modified from https://github.com/PureSwift/Silica/blob/22c72ff508c40ae5e673c16ad39f39235f6ddd01/Sources/Silica/CGPath.swift

public import Foundation

/// A graphics path is a mathematical description of a series of shapes or lines.
public class CGPath: Hashable {
    public typealias Element = PathElement

    public var elements: [Element]

    public init(elements: [Element] = []) {
        self.elements = elements
    }

    /// Creates an immutable path of a rectangle.
    public convenience init(rect: CGRect, transform: UnsafePointer<CGAffineTransform>?) {
        self.init(elements: Self.rectElements(rect, transform: transform?.pointee))
    }

    /// Creates an immutable path of an ellipse.
    public convenience init(ellipseIn rect: CGRect, transform: UnsafePointer<CGAffineTransform>?) {
        self.init(elements: Self.ellipseElements(in: rect, transform: transform?.pointee))
    }

    /// Creates an immutable path of a rounded rectangle.
    public convenience init(
        roundedRect rect: CGRect,
        cornerWidth: CGFloat,
        cornerHeight: CGFloat,
        transform: UnsafePointer<CGAffineTransform>?
    ) {
        self.init(
            elements: Self.roundedRectElements(
                in: rect,
                cornerWidth: cornerWidth,
                cornerHeight: cornerHeight,
                transform: transform?.pointee
            )
        )
    }

    public static func == (lhs: CGPath, rhs: CGPath) -> Bool {
        lhs.elements == rhs.elements
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(elements)
    }

    public var isEmpty: Bool {
        elements.isEmpty
    }

    /// The current point in a graphics path.
    ///
    /// If the path is empty, this value is `CGPoint.zero`.
    public var currentPoint: CGPoint {
        var currentPoint: CGPoint?
        var subpathStart: CGPoint?

        for element in elements {
            switch element {
            case let .moveToPoint(point):
                currentPoint = point
                subpathStart = point
            case let .addLineToPoint(end),
                 let .addQuadCurveToPoint(_, end),
                 let .addCurveToPoint(_, _, end):
                guard currentPoint != nil else { continue }
                currentPoint = end
            case .closeSubpath:
                if let start = subpathStart {
                    currentPoint = start
                }
            }
        }

        return currentPoint ?? .zero
    }

    /// The smallest rectangle completely enclosing all points in the path,
    /// not including control points for Bézier cubic and quadratic curves.
    ///
    /// If the path is empty, this value is `CGRect.null`.
    public var boundingBoxOfPath: CGRect {
        var minX = CGFloat.infinity
        var minY = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var maxY = -CGFloat.infinity

        func include(_ point: CGPoint) {
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }

        var currentPoint: CGPoint?
        var subpathStart: CGPoint?
        var pendingMove: CGPoint?

        for element in elements {
            switch element {
            case let .moveToPoint(point):
                guard point.x.isFinite, point.y.isFinite else { continue }
                currentPoint = point
                subpathStart = point
                pendingMove = point
            case let .addLineToPoint(end):
                guard end.x.isFinite, end.y.isFinite, let start = currentPoint else { continue }
                pendingMove = nil
                include(start)
                include(end)
                currentPoint = end
            case let .addQuadCurveToPoint(control, end):
                guard control.x.isFinite, control.y.isFinite,
                      end.x.isFinite, end.y.isFinite,
                      let start = currentPoint else { continue }
                pendingMove = nil
                include(start)
                include(end)
                expandQuadCurveBounds(start.x, control.x, end.x, minValue: &minX, maxValue: &maxX)
                expandQuadCurveBounds(start.y, control.y, end.y, minValue: &minY, maxValue: &maxY)
                currentPoint = end
            case let .addCurveToPoint(control1, control2, end):
                guard control1.x.isFinite, control1.y.isFinite,
                      control2.x.isFinite, control2.y.isFinite,
                      end.x.isFinite, end.y.isFinite,
                      let start = currentPoint else { continue }
                pendingMove = nil
                include(start)
                include(end)
                expandCubicCurveBounds(start.x, control1.x, control2.x, end.x, minValue: &minX, maxValue: &maxX)
                expandCubicCurveBounds(start.y, control1.y, control2.y, end.y, minValue: &minY, maxValue: &maxY)
                currentPoint = end
            case .closeSubpath:
                if let pending = pendingMove {
                    include(pending)
                    pendingMove = nil
                }
                if let start = subpathStart {
                    currentPoint = start
                }
            }
        }

        if let pending = pendingMove {
            include(pending)
        }

        guard minX <= maxX, minY <= maxY else {
            return .null
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    public func mutableCopy() -> CGMutablePath? {
        self as? CGMutablePath
    }

    public func applyWithBlock(_ block: (UnsafePointer<CGPathElement>) -> Void) {
        var pointStorage = (CGPoint.zero, CGPoint.zero, CGPoint.zero)
        withUnsafeMutablePointer(to: &pointStorage) { tuplePtr in
            tuplePtr.withMemoryRebound(to: CGPoint.self, capacity: 3) { pointsPtr in
                for item in elements {
                    let type: CGPathElementType
                    switch item {
                    case let .moveToPoint(point):
                        type = .moveToPoint
                        pointsPtr[0] = point
                    case let .addLineToPoint(point):
                        type = .addLineToPoint
                        pointsPtr[0] = point
                    case let .addQuadCurveToPoint(control, destination):
                        type = .addQuadCurveToPoint
                        pointsPtr[0] = control
                        pointsPtr[1] = destination
                    case let .addCurveToPoint(control1, control2, destination):
                        type = .addCurveToPoint
                        pointsPtr[0] = control1
                        pointsPtr[1] = control2
                        pointsPtr[2] = destination
                    case .closeSubpath:
                        type = .closeSubpath
                    }
                    var element = CGPathElement(type: type, points: pointsPtr)
                    withUnsafePointer(to: &element) { block($0) }
                }
            }
        }
    }
}

/// For compatibility with CoreGraphics API.
public class CGMutablePath: CGPath {}

public final class CGPathRef {
    public var path: CGPath

    public init(path: CGPath) {
        self.path = path
    }
}

// MARK: - Supporting Types

/// A path element.
public enum PathElement: Hashable {

    /// The path element that starts a new subpath. The element holds a single point for the destination.
    case moveToPoint(CGPoint)

    /// The path element that adds a line from the current point to a new point.
    /// The element holds a single point for the destination.
    case addLineToPoint(CGPoint)

    /// The path element that adds a quadratic curve from the current point to the specified point.
    /// The element holds a control point and a destination point.
    case addQuadCurveToPoint(CGPoint, CGPoint)

    /// The path element that adds a cubic curve from the current point to the specified point.
    /// The element holds two control points and a destination point.
    case addCurveToPoint(CGPoint, CGPoint, CGPoint)

    /// The path element that closes and completes a subpath. The element does not contain any points.
    case closeSubpath
}

// MARK: - Constructing a Path

public extension CGPath {

    func addRect(_ rect: CGRect, transform: CGAffineTransform = .identity) {
        elements.append(contentsOf: Self.rectElements(rect, transform: transform == .identity ? nil : transform))
    }

    func addEllipse(in rect: CGRect, transform: CGAffineTransform = .identity) {
        elements.append(contentsOf: Self.ellipseElements(in: rect, transform: transform == .identity ? nil : transform))
    }

    func addRoundedRect(
        in rect: CGRect,
        cornerWidth: CGFloat,
        cornerHeight: CGFloat,
        transform: CGAffineTransform = .identity
    ) {
        elements.append(
            contentsOf: Self.roundedRectElements(
                in: rect,
                cornerWidth: cornerWidth,
                cornerHeight: cornerHeight,
                transform: transform == .identity ? nil : transform
            )
        )
    }

    func move(to point: CGPoint) {

        elements.append(.moveToPoint(point))
    }

    func addLine(to point: CGPoint) {

        elements.append(.addLineToPoint(point))
    }

    func addCurve(to endPoint: CGPoint, control1: CGPoint, control2: CGPoint) {

        elements.append(.addCurveToPoint(control1, control2, endPoint))
    }

    func addQuadCurve(to endPoint: CGPoint, control: CGPoint) {

        elements.append(.addQuadCurveToPoint(control, endPoint))
    }

    func closeSubpath() {

        elements.append(.closeSubpath)
    }
}

// This magic number is 4 *(sqrt(2) -1)/3
private let KAPPA: CGFloat = 0.5522847498

private extension CGPath {
    static func rectElements(_ rect: CGRect, transform: CGAffineTransform?) -> [Element] {
        let rect = rect.standardized
        let minX = rect.origin.x
        let minY = rect.origin.y
        let maxX = minX + rect.size.width
        let maxY = minY + rect.size.height
        var p0 = CGPoint(x: minX, y: minY)
        var p1 = CGPoint(x: maxX, y: minY)
        var p2 = CGPoint(x: maxX, y: maxY)
        var p3 = CGPoint(x: minX, y: maxY)
        if let transform {
            p0 = p0.applying(transform)
            p1 = p1.applying(transform)
            p2 = p2.applying(transform)
            p3 = p3.applying(transform)
        }
        return [
            .moveToPoint(p0),
            .addLineToPoint(p1),
            .addLineToPoint(p2),
            .addLineToPoint(p3),
            .closeSubpath,
        ]
    }

    static func ellipseElements(in rect: CGRect, transform: CGAffineTransform?) -> [Element] {
        let rect = rect.standardized
        let rx = Double(rect.size.width) * 0.5
        let ry = Double(rect.size.height) * 0.5
        var matrix = CGAffineTransform(
            a: rx,
            b: 0,
            c: 0,
            d: ry,
            tx: Double(rect.origin.x) + rx,
            ty: Double(rect.origin.y) + ry
        )
        if let transform {
            matrix = matrix.concatenating(transform)
        }
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: x, y: y).applying(matrix)
        }
        let p0 = point(1, 0)
        return [
            .moveToPoint(p0),
            .addCurveToPoint(point(1, KAPPA), point(KAPPA, 1), point(0, 1)),
            .addCurveToPoint(point(-KAPPA, 1), point(-1, KAPPA), point(-1, 0)),
            .addCurveToPoint(point(-1, -KAPPA), point(-KAPPA, -1), point(0, -1)),
            .addCurveToPoint(point(KAPPA, -1), point(1, -KAPPA), p0),
            .closeSubpath,
        ]
    }

    static func roundedRectElements(
        in rect: CGRect,
        cornerWidth: CGFloat,
        cornerHeight: CGFloat,
        transform: CGAffineTransform?
    ) -> [Element] {
        let rect = rect.standardized
        precondition(
            cornerWidth >= 0 && 2 * cornerWidth <= rect.size.width &&
            cornerHeight >= 0 && 2 * cornerHeight <= rect.size.height
        )
        if cornerWidth == 0 || cornerHeight == 0 || rect.isNull {
            return rectElements(rect, transform: transform)
        }
        let minX = rect.origin.x
        let minY = rect.origin.y
        let maxX = minX + rect.size.width
        let maxY = minY + rect.size.height
        let midY = minY + rect.size.height * 0.5
        let dx = cornerWidth * (1 - KAPPA)
        let dy = cornerHeight * (1 - KAPPA)
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            let p = CGPoint(x: x, y: y)
            return transform.map { p.applying($0) } ?? p
        }
        return [
            .moveToPoint(point(maxX, midY)),
            .addLineToPoint(point(maxX, maxY - cornerHeight)),
            .addCurveToPoint(point(maxX, maxY - dy), point(maxX - dx, maxY), point(maxX - cornerWidth, maxY)),
            .addLineToPoint(point(minX + cornerWidth, maxY)),
            .addCurveToPoint(point(minX + dx, maxY), point(minX, maxY - dy), point(minX, maxY - cornerHeight)),
            .addLineToPoint(point(minX, minY + cornerHeight)),
            .addCurveToPoint(point(minX, minY + dy), point(minX + dx, minY), point(minX + cornerWidth, minY)),
            .addLineToPoint(point(maxX - cornerWidth, minY)),
            .addCurveToPoint(point(maxX - dx, minY), point(maxX, minY + dy), point(maxX, minY + cornerHeight)),
            .closeSubpath,
        ]
    }
}

private func expandQuadCurveBounds(
    _ p0: CGFloat,
    _ p1: CGFloat,
    _ p2: CGFloat,
    minValue: inout CGFloat,
    maxValue: inout CGFloat
) {
    let denom = p0 - 2 * p1 + p2
    guard denom != 0 else { return }
    let t = (p0 - p1) / denom
    guard t > 0, t < 1 else { return }
    let u = 1 - t
    let value = u * u * p0 + 2 * u * t * p1 + t * t * p2
    minValue = min(minValue, value)
    maxValue = max(maxValue, value)
}

private func expandCubicCurveRoot(
    _ p0: CGFloat,
    _ p1: CGFloat,
    _ p2: CGFloat,
    _ p3: CGFloat,
    t: CGFloat,
    minValue: inout CGFloat,
    maxValue: inout CGFloat
) {
    guard t > 0, t < 1 else { return }
    let u = 1 - t
    let value = u * u * u * p0 + 3 * u * u * t * p1 + 3 * u * t * t * p2 + t * t * t * p3
    minValue = min(minValue, value)
    maxValue = max(maxValue, value)
}

private func expandCubicCurveBounds(
    _ p0: CGFloat,
    _ p1: CGFloat,
    _ p2: CGFloat,
    _ p3: CGFloat,
    minValue: inout CGFloat,
    maxValue: inout CGFloat
) {
    let a = -p0 + 3 * p1 - 3 * p2 + p3
    let b = 2 * (p0 - 2 * p1 + p2)
    let c = p1 - p0
    if a == 0 {
        guard b != 0 else { return }
        expandCubicCurveRoot(p0, p1, p2, p3, t: -c / b, minValue: &minValue, maxValue: &maxValue)
        return
    }
    let discriminant = b * b - 4 * a * c
    guard discriminant >= 0 else { return }
    if discriminant == 0 {
        expandCubicCurveRoot(p0, p1, p2, p3, t: -b / (2 * a), minValue: &minValue, maxValue: &maxValue)
        return
    }
    let root = discriminant.squareRoot()
    let q = -0.5 * (b + (b >= 0 ? root : -root))
    expandCubicCurveRoot(p0, p1, p2, p3, t: q / a, minValue: &minValue, maxValue: &maxValue)
    if q != 0 {
        expandCubicCurveRoot(p0, p1, p2, p3, t: c / q, minValue: &minValue, maxValue: &maxValue)
    }
}

// MARK: - CoreGraphics API

public struct CGPathElement {

    public var type: CGPathElementType

    public var points: UnsafeMutablePointer<CGPoint>

    public init(type: CGPathElementType, points: UnsafeMutablePointer<CGPoint>) {

        self.type = type
        self.points = points
    }
}

/// Rules for determining which regions are interior to a path.
///
/// When filling a path, regions that a fill rule defines as interior to the path are painted.
/// When clipping with a path, regions interior to the path remain visible after clipping.
public enum CGPathFillRule: Int {

    /// A rule that considers a region to be interior to a path based on the number of times it is enclosed by path elements.
    case evenOdd

    /// A rule that considers a region to be interior to a path if the winding number for that region is nonzero.
    case winding
}

/// The type of element found in a path.
public enum CGPathElementType: Int32, Sendable {

    /// The path element that starts a new subpath. The element holds a single point for the destination.
    case moveToPoint = 0

    /// The path element that adds a line from the current point to a new point.
    /// The element holds a single point for the destination.
    case addLineToPoint = 1

    /// The path element that adds a quadratic curve from the current point to the specified point.
    /// The element holds a control point and a destination point.
    case addQuadCurveToPoint = 2

    /// The path element that adds a cubic curve from the current point to the specified point.
    /// The element holds two control points and a destination point.
    case addCurveToPoint = 3

    /// The path element that closes and completes a subpath. The element does not contain any points.
    case closeSubpath = 4
}

// MARK: - Silica Conversion

public extension PathElement {

    init(_ element: CGPathElement) {

        switch element.type {

        case .moveToPoint: self = .moveToPoint(element.points[0])

        case .addLineToPoint: self = .addLineToPoint(element.points[0])

        case .addQuadCurveToPoint: self = .addQuadCurveToPoint(element.points[0], element.points[1])

        case .addCurveToPoint: self = .addCurveToPoint(element.points[0], element.points[1], element.points[2])

        case .closeSubpath: self = .closeSubpath
        }
    }
}
