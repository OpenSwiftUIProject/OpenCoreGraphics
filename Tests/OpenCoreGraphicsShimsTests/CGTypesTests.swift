//
//  CGTypesTests.swift
//  OpenCoreGraphics

import OpenCoreGraphicsShims
import Testing

struct CGTypesTests {
    @Test
    func description() {
        let point = CGPoint(x: 1.0, y: 2.0)
        #expect(point.debugDescription == "(1.0, 2.0)")

        let size = CGSize(width: 3.0, height: 4.0)
        #expect(size.debugDescription == "(3.0, 4.0)")

        let rect = CGRect(x: 5.0, y: 6.0, width: 7.0, height: 8.0)
        #expect(rect.debugDescription == "(5.0, 6.0, 7.0, 8.0)")
    }
}
