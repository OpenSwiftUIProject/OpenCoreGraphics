//
//  CGColorConversionTests.swift
//  OpenCoreGraphicsShimsTests

import Foundation
import OpenCoreGraphicsShims
import Testing
#if OPENCOREGRAPHICS_COREGRAPHICS
import class CoreGraphics.CGColor
import class CoreGraphics.CGColorSpace
import enum CoreGraphics.CGColorRenderingIntent
#else
import class OpenCoreGraphics.CGColor
import class OpenCoreGraphics.CGColorSpace
import enum OpenCoreGraphics.CGColorRenderingIntent
#endif

@Suite
struct CGColorConversionTests {
    private func expectComponents(_ color: CGColor?, _ expected: [CGFloat], tolerance: CGFloat = 0.00001) throws {
        let components = try #require(color?.components)
        #expect(components.count == expected.count)
        for (actual, expected) in zip(components, expected) {
            #expect(abs(actual - expected) < tolerance)
        }
    }

    @Test
    func srgbTransferFunctions() throws {
        let srgb = try #require(CGColorSpace(name: CGColorSpace.extendedSRGB))
        let linear = try #require(CGColorSpace(name: CGColorSpace.extendedLinearSRGB))
        let color = try #require(CGColor(colorSpace: srgb, components: [0.25, 0.5, 0.75, 0.5]))
        let converted = try #require(color.converted(to: linear, intent: .defaultIntent, options: nil))
        #expect(converted.colorSpace == linear)
        try expectComponents(converted, [0.0508761, 0.2140411, 0.5225216, 0.5])
        try expectComponents(converted.converted(to: srgb, intent: .defaultIntent, options: nil), [0.25, 0.5, 0.75, 0.5])
    }

    @Test(arguments: [CGFloat(-1.25), -0.25, -0.02, 0, 0.02, 0.04045, 0.5, 1, 1.25])
    func extendedRoundTrip(value: CGFloat) throws {
        let srgb = try #require(CGColorSpace(name: CGColorSpace.extendedSRGB))
        let linear = try #require(CGColorSpace(name: CGColorSpace.extendedLinearSRGB))
        let color = try #require(CGColor(colorSpace: srgb, components: [value, value, value, 0.5]))
        let converted = try #require(color.converted(to: linear, intent: .defaultIntent, options: nil))
        try expectComponents(converted.converted(to: srgb, intent: .defaultIntent, options: nil), [value, value, value, 0.5])
    }

    @Test
    func extendedTransferPreservesSignAndRange() throws {
        let srgb = try #require(CGColorSpace(name: CGColorSpace.extendedSRGB))
        let linear = try #require(CGColorSpace(name: CGColorSpace.extendedLinearSRGB))
        let color = try #require(CGColor(colorSpace: srgb, components: [-0.25, -0.02, 1.25, 0.5]))
        try expectComponents(color.converted(to: linear, intent: .defaultIntent, options: nil), [-0.0508761, -0.00154799, 1.6659399, 0.5])
    }

    @Test
    func sameSpacePreservesUnclampedAlpha() throws {
        let srgb = try #require(CGColorSpace(name: CGColorSpace.extendedSRGB))
        let color = try #require(CGColor(colorSpace: srgb, components: [-0.25, 0.5, 1.25, 1]))
        let copy = try #require(color.copy(alpha: 1.5))
        let equalSpace = try #require(CGColorSpace(name: CGColorSpace.extendedSRGB))
        let converted = try #require(copy.converted(to: equalSpace, intent: .defaultIntent, options: nil))
        #expect(converted == copy)
        #expect(converted.components == [-0.25, 0.5, 1.25, 1.5])
    }

    @Test
    func conversionClampsToDestinationRange() throws {
        let extended = try #require(CGColorSpace(name: CGColorSpace.extendedSRGB))
        let srgb = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let linear = try #require(CGColorSpace(name: CGColorSpace.extendedLinearSRGB))
        let color = try #require(CGColor(colorSpace: extended, components: [-0.25, 0.5, 1.25, 1]))
        let copy = try #require(color.copy(alpha: 1.5))
        let bounded = try #require(copy.converted(to: srgb, intent: .defaultIntent, options: nil))
        #expect(bounded.components == [0, 0.5, 1, 1])
        try expectComponents(copy.converted(to: linear, intent: .defaultIntent, options: nil), [-0.0508761, 0.2140411, 1.6659399, 1])
    }

    @Test
    func displayP3Conversion() throws {
        let p3 = try #require(CGColorSpace(name: CGColorSpace.displayP3))
        let extended = try #require(CGColorSpace(name: CGColorSpace.extendedSRGB))
        let red = try #require(CGColor(colorSpace: p3, components: [1, 0, 0, 0.5]))
        // Native ICC profile rounding differs slightly from the standard matrix.
        try expectComponents(red.converted(to: extended, intent: .defaultIntent, options: nil), [1.0931, -0.2268, -0.1501, 0.5], tolerance: 0.0005)
        let color = try #require(CGColor(colorSpace: p3, components: [0.25, 0.5, 0.75, 0.5]))
        let converted = try #require(color.converted(to: extended, intent: .defaultIntent, options: nil))
        try expectComponents(converted, [0.12398, 0.50736, 0.77112, 0.5], tolerance: 0.0005)
        try expectComponents(converted.converted(to: p3, intent: .defaultIntent, options: nil), [0.25, 0.5, 0.75, 0.5], tolerance: 0.0005)
    }

    @Test(arguments: [CGColorRenderingIntent.defaultIntent, .absoluteColorimetric, .relativeColorimetric, .perceptual, .saturation])
    func boundedDisplayP3Conversion(intent: CGColorRenderingIntent) throws {
        let p3 = try #require(CGColorSpace(name: CGColorSpace.displayP3))
        let srgb = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let red = try #require(CGColor(colorSpace: p3, components: [1, 0, 0, 0.5]))
        let converted = try #require(red.converted(to: srgb, intent: intent, options: nil))
        #expect(converted.colorSpace == srgb)
        #expect(converted.components == [1, 0, 0, 0.5])
    }

    @Test
    func genericColorsConvertToRGB() throws {
        let linear = try #require(CGColorSpace(name: CGColorSpace.extendedLinearSRGB))
        let gray = CGColor(gray: 0.5, alpha: 0.25)
        try expectComponents(gray.converted(to: linear, intent: .defaultIntent, options: nil), [0.2871746, 0.2871746, 0.2871746, 0.25])
        let gammaGray = CGColor(genericGrayGamma2_2Gray: 0.5, alpha: 0.25)
        try expectComponents(gammaGray.converted(to: linear, intent: .defaultIntent, options: nil), [0.2140411, 0.2140411, 0.2140411, 0.25])
        let rgb = CGColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 0.5)
        let converted = try #require(rgb.converted(to: linear, intent: .defaultIntent, options: nil))
        try expectComponents(converted, [0.0777045, 0.2932618, 0.5971608, 0.5])
        let generic = try #require(rgb.colorSpace)
        try expectComponents(converted.converted(to: generic, intent: .defaultIntent, options: nil), [0.25, 0.5, 0.75, 0.5])
    }

    @Test(arguments: [CGFloat(0.003), 0.02, 0.03125])
    func genericTransferNearBlack(value: CGFloat) throws {
        let linear = try #require(CGColorSpace(name: CGColorSpace.extendedLinearSRGB))
        for color in [CGColor(gray: value, alpha: 0.5), CGColor(red: value, green: value, blue: value, alpha: 0.5)] {
            let converted = try #require(color.converted(to: linear, intent: .defaultIntent, options: nil))
            try expectComponents(converted, [value / 16, value / 16, value / 16, 0.5])
            let space = try #require(color.colorSpace)
            try expectComponents(converted.converted(to: space, intent: .defaultIntent, options: nil), color.components!)
        }
    }

    @Test
    func rgbConvertsToGray() throws {
        let linear = try #require(CGColorSpace(name: CGColorSpace.extendedLinearSRGB))
        let gray = try #require(CGColor(gray: 0, alpha: 1).colorSpace)
        let gammaGray = try #require(CGColorSpace(name: CGColorSpace.genericGrayGamma2_2))
        let color = try #require(CGColor(colorSpace: linear, components: [0.25, 0.5, 0.75, 0.5]))
        try expectComponents(color.converted(to: gray, intent: .defaultIntent, options: nil), [0.649226, 0.5])
        try expectComponents(color.converted(to: gammaGray, intent: .defaultIntent, options: nil), [0.708044, 0.5])
    }
}
