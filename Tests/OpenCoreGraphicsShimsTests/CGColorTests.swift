//
//  CGColorTests.swift
//  OpenCoreGraphicsShimsTests

import Foundation
import OpenCoreGraphicsShims
import Testing
#if OPENCOREGRAPHICS_COREGRAPHICS
import class CoreGraphics.CGColor
#else
import class OpenCoreGraphics.CGColor
#endif

@Suite
struct CGColorTests {
    @Test
    func rgbaComponents() {
        let color = CGColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 0.5)
        #expect(color.components == [0.25, 0.5, 0.75, 0.5])
        #expect(color.numberOfComponents == 4)
        #expect(color.alpha == 0.5)
    }

    @Test
    func srgbComponents() {
        let color = CGColor(srgbRed: 0.25, green: 0.5, blue: 0.75, alpha: 0.5)
        #expect(color.components == [0.25, 0.5, 0.75, 0.5])
        #expect(color.numberOfComponents == 4)
        #expect(color.alpha == 0.5)
    }

    @Test(arguments: [CGFloat(-1), 0, 0.25, 1, 2, .infinity, -.infinity])
    func initializersClampComponents(value: CGFloat) {
        let expected = min(max(value, 0), 1)
        let rgb = CGColor(red: value, green: value, blue: value, alpha: value)
        let srgb = CGColor(srgbRed: value, green: value, blue: value, alpha: value)
        let gray = CGColor(gray: value, alpha: value)
        let gammaGray = CGColor(genericGrayGamma2_2Gray: value, alpha: value)
        #expect(rgb.components == Array(repeating: expected, count: 4))
        #expect(srgb.components == rgb.components)
        #expect(gray.components == [expected, expected])
        #expect(gammaGray.components == gray.components)
    }

    @Test
    func initializersPreserveNaN() throws {
        let color = CGColor(red: .nan, green: 0.5, blue: 0.75, alpha: .nan)
        let components = try #require(color.components)
        #expect(components[0].isNaN)
        #expect(color.alpha.isNaN)
    }

    @Test
    func grayComponents() {
        let color = CGColor(gray: 0.25, alpha: 0.5)
        #expect(color.components == [0.25, 0.5])
        #expect(color.numberOfComponents == 2)
        #expect(color.alpha == 0.5)
    }

    @Test
    func constantColors() {
        #expect(CGColor.black.components == [0, 1])
        #expect(CGColor.white.components == [1, 1])
        #expect(CGColor.clear.components == [0, 0])
        #expect(CGColor.black == CGColor(genericGrayGamma2_2Gray: 0, alpha: 1))
        #expect(CGColor.white == CGColor(genericGrayGamma2_2Gray: 1, alpha: 1))
        #expect(CGColor.clear == CGColor(genericGrayGamma2_2Gray: 0, alpha: 0))
    }

    @Test
    func copyPreservesColor() throws {
        let color = CGColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 0.5)
        let copy = try #require(color.copy())
        #expect(copy == color)
        #expect(copy.components == color.components)
    }

    @Test(arguments: [CGFloat(-1), 0, 0.25, 1, 2, .infinity, -.infinity])
    func copyReplacesAlphaWithoutClamping(alpha: CGFloat) throws {
        let color = CGColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 0.5)
        let copy = try #require(color.copy(alpha: alpha))
        #expect(copy.components == [0.25, 0.5, 0.75, alpha])
        #expect(copy.alpha == alpha)
        #expect(color.alpha == 0.5)
    }

    @Test
    func copyPreservesGrayAndNaNAlpha() throws {
        let color = CGColor(gray: 0.25, alpha: 0.5)
        let copy = try #require(color.copy(alpha: .nan))
        #expect(copy.numberOfComponents == 2)
        #expect(copy.components?.first == 0.25)
        #expect(copy.alpha.isNaN)
        #expect(color.alpha == 0.5)
    }

    @Test
    func copyPreservesColorKind() throws {
        let color = CGColor(srgbRed: 0.25, green: 0.5, blue: 0.75, alpha: 0.5)
        let copy = try #require(color.copy(alpha: 0.75))
        #expect(copy == CGColor(srgbRed: 0.25, green: 0.5, blue: 0.75, alpha: 0.75))
        #expect(copy != CGColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 0.75))
    }

    @Test
    func returnedComponentsDoNotMutateColor() throws {
        let color = CGColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 0.5)
        var components = try #require(color.components)
        components[0] = 1
        #expect(color.components == [0.25, 0.5, 0.75, 0.5])
    }

    @Test
    func equalityAndHashUseColorValues() {
        let color = CGColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 0.5)
        let equal = CGColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 0.5)
        #expect(color == equal)
        #expect(color.hashValue == equal.hashValue)
        #expect(Set([color, equal]).count == 1)
        #expect(color != CGColor(red: 1, green: 0.5, blue: 0.75, alpha: 0.5))
        #expect(color != CGColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 1))
    }

    @Test
    func differentColorKindsAreNotEqual() {
        #expect(CGColor(red: 0, green: 0, blue: 0, alpha: 1) != CGColor(gray: 0, alpha: 1))
        #expect(CGColor(red: 0, green: 0, blue: 0, alpha: 1) != CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1))
        #expect(CGColor(gray: 0, alpha: 1) != CGColor.black)
    }

}
