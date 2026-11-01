//
//  CGRectTests.swift
//  OpenCoreGraphicsShimsTests

import OpenCoreGraphicsShims
import Testing

struct CGRectTests {
    @Test
    func negativeSizeBounds() {
        let rect = CGRect(x: 11, y: 22, width: -10, height: -20)
        #expect(rect.width == 10)
        #expect(rect.height == 20)
        #expect(rect.minX == 1)
        #expect(rect.midX == 6)
        #expect(rect.maxX == 11)
        #expect(rect.minY == 2)
        #expect(rect.midY == 12)
        #expect(rect.maxY == 22)
        #expect(rect.standardized == CGRect(x: 1, y: 2, width: 10, height: 20))
    }

    @Test
    func nullRectangles() {
        #expect(CGRect.null.isNull)
        #expect(!CGRect.zero.isNull)
        #expect(CGRect.null.standardized == .null)
        let rect = CGRect(x: CGFloat.infinity, y: 2, width: 10, height: 20)
        #expect(rect.isNull)
        #expect(rect.standardized == .null)
        #expect(!CGRect(x: -CGFloat.infinity, y: 2, width: 10, height: 20).isNull)
    }

    @Test(arguments: [
        (CGPoint(x: 0, y: 0), true),
        (CGPoint(x: 5, y: 5), true),
        (CGPoint(x: 10, y: 5), false),
        (CGPoint(x: 5, y: 10), false),
        (CGPoint(x: -1, y: 5), false),
    ])
    func containsPoint(point: CGPoint, expected: Bool) {
        let rect = CGRect(x: 10, y: 10, width: -10, height: -10)
        #expect(rect.contains(point) == expected)
        #expect(!CGRect.null.contains(point))
        #expect(!CGRect.zero.contains(point))
    }

    @Test(arguments: [
        (CGRect(x: 5, y: 5, width: 10, height: 10), true),
        (CGRect(x: 10, y: 0, width: 10, height: 10), false),
        (CGRect(x: 5, y: 5, width: 0, height: 0), true),
        (CGRect(x: 5, y: 5, width: 0, height: 2), true),
        (CGRect(x: 10, y: 5, width: 0, height: 0), false),
        (CGRect.zero, true),
        (CGRect.null, false),
    ])
    func intersectionBounds(other: CGRect, expected: Bool) {
        let rect = CGRect(x: 10, y: 10, width: -10, height: -10)
        #expect(rect.intersects(other) == expected)
        #expect(other.intersects(rect) == expected)
        #expect(!CGRect.null.intersects(other))
    }

    @Test
    func unionIncludesDegenerateBounds() {
        let rect = CGRect(x: 10, y: 10, width: -10, height: -10)
        #expect(rect.union(.null) == rect)
        #expect(CGRect.null.union(rect) == rect)
        #expect(CGRect.null.union(.null) == .null)
        let point = CGRect(x: 15, y: 20, width: 0, height: 0)
        #expect(CGRect.zero.union(point) == CGRect(x: 0, y: 0, width: 15, height: 20))
        #expect(rect.union(point) == CGRect(x: 0, y: 0, width: 15, height: 20))
    }

    @Test
    func coincidentDegenerateIntersections() {
        #expect(CGRect.zero.intersects(.zero))
        let line = CGRect(x: 0, y: 0, width: 0, height: 10)
        #expect(line.intersects(CGRect(x: 0, y: 2, width: 0, height: 4)))
        #expect(!line.intersects(CGRect(x: 1, y: 2, width: 0, height: 4)))
    }
}
