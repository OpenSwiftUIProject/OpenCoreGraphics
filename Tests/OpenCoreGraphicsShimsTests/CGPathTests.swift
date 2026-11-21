//
//  CGPathTests.swift
//  OpenCoreGraphicsShimsTests

import Numerics
import OpenCoreGraphicsShims
import Testing

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
}
