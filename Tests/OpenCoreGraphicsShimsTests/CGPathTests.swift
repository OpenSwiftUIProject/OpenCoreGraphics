//
//  CGPathTests.swift
//  OpenCoreGraphicsShimsTests

import Numerics
import OpenCoreGraphicsShims
import Testing
#if OPENCOREGRAPHICS_COREGRAPHICS
import struct CoreGraphics.CGAffineTransform
#else
import struct OpenCoreGraphics.CGAffineTransform
#endif

struct CGPathTests {
    @Test
    func emptyAndInvalidPathsReturnNullBoundingBox() {
        let empty = CGMutablePath()
        #expect(empty.boundingBoxOfPath.isNull)

        let lineWithoutMove = CGMutablePath()
        lineWithoutMove.addLine(to: CGPoint(x: 10, y: 20))
        #expect(lineWithoutMove.boundingBoxOfPath.isNull)

        let nanMove = CGMutablePath()
        nanMove.move(to: CGPoint(x: CGFloat.nan, y: 0))
        #expect(nanMove.boundingBoxOfPath.isNull)
    }

    @Test
    func moveCoalescingAndSubpathClosureBounds() {
        let singleMove = CGMutablePath()
        singleMove.move(to: CGPoint(x: 10, y: 20))
        #expect(singleMove.boundingBoxOfPath == CGRect(x: 10, y: 20, width: 0, height: 0))

        let consecutiveMoves = CGMutablePath()
        consecutiveMoves.move(to: CGPoint(x: 100, y: 200))
        consecutiveMoves.move(to: CGPoint(x: 10, y: 20))
        consecutiveMoves.addLine(to: CGPoint(x: 30, y: 40))
        #expect(consecutiveMoves.boundingBoxOfPath == CGRect(x: 10, y: 20, width: 20, height: 20))

        let trailingMove = CGMutablePath()
        trailingMove.move(to: CGPoint(x: 10, y: 20))
        trailingMove.addLine(to: CGPoint(x: 30, y: 40))
        trailingMove.move(to: CGPoint(x: 100, y: 200))
        #expect(trailingMove.boundingBoxOfPath == CGRect(x: 10, y: 20, width: 90, height: 180))

        let closedThenLine = CGMutablePath()
        closedThenLine.move(to: CGPoint(x: 10, y: 20))
        closedThenLine.addLine(to: CGPoint(x: 30, y: 40))
        closedThenLine.closeSubpath()
        closedThenLine.addLine(to: CGPoint(x: 5, y: 5))
        #expect(closedThenLine.boundingBoxOfPath == CGRect(x: 5, y: 5, width: 25, height: 35))
    }

    @Test
    func rectAndEllipseBoundingBoxes() {
        let negativeRectPath = CGMutablePath()
        negativeRectPath.addRect(CGRect(x: 10, y: 20, width: -6, height: -8))
        #expect(negativeRectPath.boundingBoxOfPath == CGRect(x: 4, y: 12, width: 6, height: 8))

        let ellipsePath = CGMutablePath()
        ellipsePath.addEllipse(in: CGRect(x: 10, y: 20, width: 40, height: 60))
        let bounds = ellipsePath.boundingBoxOfPath
        #expect(bounds.origin.x.isApproximatelyEqual(to: 10, absoluteTolerance: 1e-6))
        #expect(bounds.origin.y.isApproximatelyEqual(to: 20, absoluteTolerance: 1e-6))
        #expect(bounds.size.width.isApproximatelyEqual(to: 40, absoluteTolerance: 1e-6))
        #expect(bounds.size.height.isApproximatelyEqual(to: 60, absoluteTolerance: 1e-6))
    }

    @Test
    func rectInitializerAndTransform() {
        let nullRect = CGPath(rect: .null, transform: nil)
        #expect(!nullRect.isEmpty)
        #expect(nullRect.boundingBoxOfPath == .null)
        #expect(CGPath(rect: CGRect(x: CGFloat.infinity, y: 2, width: 10, height: 20), transform: nil) == nullRect)

        let rect = CGRect(x: 10, y: 20, width: 30, height: 40)
        let mutableRect = CGMutablePath()
        mutableRect.addRect(rect)
        #expect(CGPath(rect: rect, transform: nil) == mutableRect)

        let negativeRect = CGPath(rect: CGRect(x: 10, y: 20, width: -6, height: -8), transform: nil)
        #expect(negativeRect == CGPath(rect: CGRect(x: 4, y: 12, width: 6, height: 8), transform: nil))
        #expect(negativeRect.boundingBoxOfPath == CGRect(x: 4, y: 12, width: 6, height: 8))

        var transform = CGAffineTransform(a: 2, b: 1, c: -1, d: 3, tx: 5, ty: 7)
        let transformedRect = CGPath(rect: rect, transform: &transform)
        let mutableTransformedRect = CGMutablePath()
        mutableTransformedRect.addRect(rect, transform: transform)
        #expect(transformedRect == mutableTransformedRect)
        #expect(transformedRect.boundingBoxOfPath == CGRect(x: -35, y: 77, width: 100, height: 150))
    }

    @Test
    func ellipseInitializerAndTransform() {
        let nullEllipse = CGPath(ellipseIn: .null, transform: nil)
        #expect(!nullEllipse.isEmpty)
        #expect(nullEllipse.boundingBoxOfPath == .null)

        let rect = CGRect(x: 10, y: 20, width: 40, height: 60)
        let mutableEllipse = CGMutablePath()
        mutableEllipse.addEllipse(in: rect)
        #expect(CGPath(ellipseIn: rect, transform: nil) == mutableEllipse)

        let negativeEllipse = CGPath(ellipseIn: CGRect(x: 10, y: 20, width: -40, height: -60), transform: nil)
        #expect(negativeEllipse == CGPath(ellipseIn: CGRect(x: -30, y: -40, width: 40, height: 60), transform: nil))
        let negativeBounds = negativeEllipse.boundingBoxOfPath
        #expect(negativeBounds.origin.x.isApproximatelyEqual(to: -30, absoluteTolerance: 1e-6))
        #expect(negativeBounds.origin.y.isApproximatelyEqual(to: -40, absoluteTolerance: 1e-6))
        #expect(negativeBounds.size.width.isApproximatelyEqual(to: 40, absoluteTolerance: 1e-6))
        #expect(negativeBounds.size.height.isApproximatelyEqual(to: 60, absoluteTolerance: 1e-6))

        var transform = CGAffineTransform(a: 2, b: 1, c: -1, d: 3, tx: 5, ty: 7)
        let transformedEllipse = CGPath(ellipseIn: rect, transform: &transform)
        let mutableTransformedEllipse = CGMutablePath()
        mutableTransformedEllipse.addEllipse(in: rect, transform: transform)
        #expect(transformedEllipse == mutableTransformedEllipse)
        let transformedBounds = transformedEllipse.boundingBoxOfPath
        #expect(transformedBounds.origin.x.isApproximatelyEqual(to: -35.0029425866, absoluteTolerance: 1e-6))
        #expect(transformedBounds.origin.y.isApproximatelyEqual(to: 94.7848067788, absoluteTolerance: 1e-6))
        #expect(transformedBounds.size.width.isApproximatelyEqual(to: 100.0058851731, absoluteTolerance: 1e-6))
        #expect(transformedBounds.size.height.isApproximatelyEqual(to: 184.4303864424, absoluteTolerance: 1e-6))
    }

    @Test
    func quadAndCubicCurveTightExtremaExcludeControlPoints() {
        let quad = CGMutablePath()
        quad.move(to: CGPoint(x: 0, y: 0))
        quad.addQuadCurve(to: CGPoint(x: 100, y: 0), control: CGPoint(x: 50, y: 100))
        let quadBounds = quad.boundingBoxOfPath
        #expect(quadBounds.origin.x.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-6))
        #expect(quadBounds.origin.y.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-6))
        #expect(quadBounds.size.width.isApproximatelyEqual(to: 100, absoluteTolerance: 1e-6))
        #expect(quadBounds.size.height.isApproximatelyEqual(to: 50, absoluteTolerance: 1e-6))

        let cubic = CGMutablePath()
        cubic.move(to: CGPoint(x: 0, y: 0))
        cubic.addCurve(
            to: CGPoint(x: 100, y: 0),
            control1: CGPoint(x: 0, y: 100),
            control2: CGPoint(x: 100, y: -100)
        )
        let cubicBounds = cubic.boundingBoxOfPath
        let expectedPeak = 50 / CGFloat(3).squareRoot()
        #expect(cubicBounds.origin.x.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-6))
        #expect(cubicBounds.origin.y.isApproximatelyEqual(to: -expectedPeak, absoluteTolerance: 1e-6))
        #expect(cubicBounds.size.width.isApproximatelyEqual(to: 100, absoluteTolerance: 1e-6))
        #expect(cubicBounds.size.height.isApproximatelyEqual(to: 2 * expectedPeak, absoluteTolerance: 1e-6))
    }

    @Test
    func applyWithBlockVisitsElementsInOrder() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 1, y: 2))
        path.addLine(to: CGPoint(x: 3, y: 4))
        path.addQuadCurve(to: CGPoint(x: 7, y: 8), control: CGPoint(x: 5, y: 6))
        path.addCurve(to: CGPoint(x: 13, y: 14), control1: CGPoint(x: 9, y: 10), control2: CGPoint(x: 11, y: 12))
        path.closeSubpath()

        var recorded: [(Int32, [CGPoint])] = []
        path.applyWithBlock { elementPtr in
            let element = elementPtr.pointee
            let count: Int
            switch element.type {
            case .moveToPoint, .addLineToPoint: count = 1
            case .addQuadCurveToPoint: count = 2
            case .addCurveToPoint: count = 3
            case .closeSubpath: count = 0
            @unknown default: count = 0
            }
            let points = (0..<count).map { element.points[$0] }
            recorded.append((element.type.rawValue, points))
        }

        #expect(recorded.count == 5)
        #expect(recorded[0].0 == 0 && recorded[0].1 == [CGPoint(x: 1, y: 2)])
        #expect(recorded[1].0 == 1 && recorded[1].1 == [CGPoint(x: 3, y: 4)])
        #expect(recorded[2].0 == 2 && recorded[2].1 == [CGPoint(x: 5, y: 6), CGPoint(x: 7, y: 8)])
        #expect(recorded[3].0 == 3 && recorded[3].1 == [CGPoint(x: 9, y: 10), CGPoint(x: 11, y: 12), CGPoint(x: 13, y: 14)])
        #expect(recorded[4].0 == 4 && recorded[4].1.isEmpty)
    }

    @Test
    func currentPointTracksSubpathsAndPrimitives() {
        let empty = CGMutablePath()
        #expect(empty.currentPoint == .zero)

        let lineWithoutMove = CGMutablePath()
        lineWithoutMove.addLine(to: CGPoint(x: 10, y: 20))
        #expect(lineWithoutMove.currentPoint == .zero)

        let closeWithoutMove = CGMutablePath()
        closeWithoutMove.closeSubpath()
        #expect(closeWithoutMove.currentPoint == .zero)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 10, y: 20))
        #expect(path.currentPoint == CGPoint(x: 10, y: 20))

        path.addLine(to: CGPoint(x: 30, y: 40))
        #expect(path.currentPoint == CGPoint(x: 30, y: 40))

        path.addQuadCurve(to: CGPoint(x: 50, y: 60), control: CGPoint(x: 35, y: 45))
        #expect(path.currentPoint == CGPoint(x: 50, y: 60))

        path.addCurve(to: CGPoint(x: 110, y: 120), control1: CGPoint(x: 70, y: 80), control2: CGPoint(x: 90, y: 100))
        #expect(path.currentPoint == CGPoint(x: 110, y: 120))

        path.closeSubpath()
        #expect(path.currentPoint == CGPoint(x: 10, y: 20))

        path.addLine(to: CGPoint(x: 200, y: 300))
        #expect(path.currentPoint == CGPoint(x: 200, y: 300))

        path.closeSubpath()
        #expect(path.currentPoint == CGPoint(x: 10, y: 20))

        path.move(to: CGPoint(x: 77, y: 88))
        #expect(path.currentPoint == CGPoint(x: 77, y: 88))
        path.addLine(to: CGPoint(x: 99, y: 111))
        path.closeSubpath()
        #expect(path.currentPoint == CGPoint(x: 77, y: 88))

        let rectPath = CGPath(rect: CGRect(x: 5, y: 6, width: 10, height: 20), transform: nil)
        #expect(rectPath.currentPoint == CGPoint(x: 5, y: 6))

        let nullRect = CGPath(rect: .null, transform: nil)
        #expect(nullRect.currentPoint == CGPoint(x: CGFloat.infinity, y: CGFloat.infinity))

        let ellipsePath = CGPath(ellipseIn: CGRect(x: 0, y: 0, width: 10, height: 20), transform: nil)
        #expect(ellipsePath.currentPoint == CGPoint(x: 10, y: 10))

        let nullEllipse = CGPath(ellipseIn: .null, transform: nil)
        #expect(nullEllipse.currentPoint == CGPoint(x: CGFloat.infinity, y: CGFloat.infinity))
    }

    @Test
    func roundedRectInitializerAndTransform() {
        let nullRounded = CGPath(roundedRect: .null, cornerWidth: 0, cornerHeight: 0, transform: nil)
        #expect(!nullRounded.isEmpty)
        #expect(nullRounded.boundingBoxOfPath == .null)

        let rect = CGRect(x: 5, y: 6, width: 100, height: 50)
        #expect(CGPath(roundedRect: rect, cornerWidth: 0, cornerHeight: 10, transform: nil) == CGPath(rect: rect, transform: nil))
        #expect(CGPath(roundedRect: rect, cornerWidth: 10, cornerHeight: 0, transform: nil) == CGPath(rect: rect, transform: nil))

        let rounded = CGPath(roundedRect: rect, cornerWidth: 10, cornerHeight: 20, transform: nil)
        let negativeRounded = CGPath(roundedRect: CGRect(x: 105, y: 56, width: -100, height: -50), cornerWidth: 10, cornerHeight: 20, transform: nil)
        let mutableRounded = CGMutablePath()
        mutableRounded.addRoundedRect(in: rect, cornerWidth: 10, cornerHeight: 20)

        let bounds = rounded.boundingBoxOfPath
        #expect(bounds.origin.x.isApproximatelyEqual(to: 5, absoluteTolerance: 1e-6))
        #expect(bounds.origin.y.isApproximatelyEqual(to: 6, absoluteTolerance: 1e-6))
        #expect(bounds.size.width.isApproximatelyEqual(to: 100, absoluteTolerance: 1e-6))
        #expect(bounds.size.height.isApproximatelyEqual(to: 50, absoluteTolerance: 1e-6))
        #expect(rounded.currentPoint.x.isApproximatelyEqual(to: 105, absoluteTolerance: 1e-6))
        #expect(rounded.currentPoint.y.isApproximatelyEqual(to: 31, absoluteTolerance: 1e-6))

        func elements(of path: CGPath) -> [(Int32, [CGPoint])] {
            var list: [(Int32, [CGPoint])] = []
            path.applyWithBlock { ptr in
                let e = ptr.pointee
                let count: Int
                switch e.type {
                case .moveToPoint, .addLineToPoint: count = 1
                case .addQuadCurveToPoint: count = 2
                case .addCurveToPoint: count = 3
                case .closeSubpath: count = 0
                @unknown default: count = 0
                }
                list.append((e.type.rawValue, (0..<count).map { e.points[$0] }))
            }
            return list
        }

        let roundedElems = elements(of: rounded)
        let negElems = elements(of: negativeRounded)
        let mutElems = elements(of: mutableRounded)
        #expect(roundedElems.count == 10)
        #expect(negElems.count == 10)
        #expect(mutElems.count == 10)
        for i in 0..<10 {
            #expect(roundedElems[i].0 == negElems[i].0)
            #expect(roundedElems[i].0 == mutElems[i].0)
            for j in roundedElems[i].1.indices {
                #expect(roundedElems[i].1[j].x.isApproximatelyEqual(to: negElems[i].1[j].x, absoluteTolerance: 1e-9))
                #expect(roundedElems[i].1[j].y.isApproximatelyEqual(to: negElems[i].1[j].y, absoluteTolerance: 1e-9))
                #expect(roundedElems[i].1[j].x.isApproximatelyEqual(to: mutElems[i].1[j].x, absoluteTolerance: 1e-9))
                #expect(roundedElems[i].1[j].y.isApproximatelyEqual(to: mutElems[i].1[j].y, absoluteTolerance: 1e-9))
            }
        }

        let halfRadii = CGPath(roundedRect: CGRect(x: 0, y: 0, width: 100, height: 50), cornerWidth: 50, cornerHeight: 25, transform: nil)
        let halfBounds = halfRadii.boundingBoxOfPath
        #expect(halfBounds.origin.x.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-6))
        #expect(halfBounds.origin.y.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-6))
        #expect(halfBounds.size.width.isApproximatelyEqual(to: 100, absoluteTolerance: 1e-6))
        #expect(halfBounds.size.height.isApproximatelyEqual(to: 50, absoluteTolerance: 1e-6))

        var transform = CGAffineTransform(translationX: 100, y: 200)
        let transformed = CGPath(roundedRect: CGRect(x: 0, y: 0, width: 40, height: 20), cornerWidth: 5, cornerHeight: 5, transform: &transform)
        let mutableTransformed = CGMutablePath()
        mutableTransformed.addRoundedRect(in: CGRect(x: 0, y: 0, width: 40, height: 20), cornerWidth: 5, cornerHeight: 5, transform: transform)
        let txBounds = transformed.boundingBoxOfPath
        let mutTxBounds = mutableTransformed.boundingBoxOfPath
        #expect(txBounds.origin.x.isApproximatelyEqual(to: 100, absoluteTolerance: 1e-6))
        #expect(txBounds.origin.y.isApproximatelyEqual(to: 200, absoluteTolerance: 1e-6))
        #expect(txBounds.size.width.isApproximatelyEqual(to: 40, absoluteTolerance: 1e-6))
        #expect(txBounds.size.height.isApproximatelyEqual(to: 20, absoluteTolerance: 1e-6))
        #expect(mutTxBounds.origin.x.isApproximatelyEqual(to: 100, absoluteTolerance: 1e-6))
        #expect(mutTxBounds.origin.y.isApproximatelyEqual(to: 200, absoluteTolerance: 1e-6))
    }
}
