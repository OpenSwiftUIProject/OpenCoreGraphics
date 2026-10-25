//
//  CGColorSpaceTests.swift
//  OpenCoreGraphicsShimsTests

import Foundation
import OpenCoreGraphicsShims
import Testing
#if OPENCOREGRAPHICS_COREGRAPHICS
import class CoreGraphics.CGColor
import class CoreGraphics.CGColorSpace
#else
import class OpenCoreGraphics.CGColor
import class OpenCoreGraphics.CGColorSpace
#endif

@Suite
struct CGColorSpaceTests {
    @Test
    func namedSpaces() throws {
        for name in [CGColorSpace.sRGB, CGColorSpace.extendedSRGB,
                     CGColorSpace.linearSRGB, CGColorSpace.extendedLinearSRGB,
                     CGColorSpace.displayP3] {
            let space = try #require(CGColorSpace(name: name))
            #expect(CFEqual(space.name, name))
            #expect(space.model == .rgb)
            #expect(space.numberOfComponents == 3)
        }
        let gray = try #require(CGColorSpace(name: CGColorSpace.genericGrayGamma2_2))
        #expect(gray.model == .monochrome)
        #expect(gray.numberOfComponents == 1)
    }

    @Test
    func unknownName() {
        let name = CFStringCreateWithCString(nil, "UnknownColorSpace", CFStringBuiltInEncodings.UTF8.rawValue)!
        #expect(CGColorSpace(name: name) == nil)
    }

    @Test
    func equalityAndHash() throws {
        let first = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let second = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        #expect(first == second)
        #expect(first.hashValue == second.hashValue)
        #expect(Set([first, second]).count == 1)
        #expect(first != CGColorSpace(name: CGColorSpace.extendedSRGB))
        #expect(first != CGColorSpace(name: CGColorSpace.linearSRGB))
    }

    @Test
    func convenienceColorSpaces() throws {
        let srgb = CGColor(srgbRed: 0.25, green: 0.5, blue: 0.75, alpha: 1)
        #expect(srgb.colorSpace == CGColorSpace(name: CGColorSpace.sRGB))
        #expect(CGColor.black.colorSpace == CGColorSpace(name: CGColorSpace.genericGrayGamma2_2))
        #expect(CGColor(red: 0, green: 0, blue: 0, alpha: 1).colorSpace?.model == .rgb)
        #expect(CGColor(gray: 0, alpha: 1).colorSpace?.model == .monochrome)
    }

    @Test
    func componentStorageAndCopy() throws {
        let space = try #require(CGColorSpace(name: CGColorSpace.extendedSRGB))
        var values: [CGFloat] = [-0.25, 0.5, 1.25, 1.5]
        let color = try #require(CGColor(colorSpace: space, components: &values))
        values[0] = 1
        #expect(color.components == [-0.25, 0.5, 1.25, 1])
        #expect(color.colorSpace == space)
        let copy = try #require(color.copy(alpha: 1.5))
        #expect(copy.colorSpace == space)
        #expect(copy.components == [-0.25, 0.5, 1.25, 1.5])
    }

    @Test
    func boundedAndExtendedComponents() throws {
        for name in [CGColorSpace.sRGB, CGColorSpace.linearSRGB, CGColorSpace.displayP3] {
            let space = try #require(CGColorSpace(name: name))
            let color = try #require(CGColor(colorSpace: space, components: [-0.25, 0.5, 1.25, -1]))
            #expect(color.components == [0, 0.5, 1, 0])
        }
        for name in [CGColorSpace.extendedSRGB, CGColorSpace.extendedLinearSRGB] {
            let space = try #require(CGColorSpace(name: name))
            let color = try #require(CGColor(colorSpace: space, components: [.nan, .infinity, -.infinity, .nan]))
            let components = try #require(color.components)
            #expect(components[0].isNaN)
            #expect(components[1] == .infinity)
            #expect(components[2] == -.infinity)
            #expect(color.alpha.isNaN)
        }
        let gray = try #require(CGColorSpace(name: CGColorSpace.genericGrayGamma2_2))
        let color = try #require(CGColor(colorSpace: gray, components: [0.25, 0.5]))
        #expect(color.components == [0.25, 0.5])
        #expect(color == CGColor(genericGrayGamma2_2Gray: 0.25, alpha: 0.5))
    }
}
