//
//  CGColorSpace.swift
//  OpenCoreGraphics

public import CoreFoundation
public import Foundation

public enum CGColorRenderingIntent: Int32, Sendable {
    case defaultIntent = 0
    case absoluteColorimetric = 1
    case relativeColorimetric = 2
    case perceptual = 3
    case saturation = 4
}

public enum CGColorSpaceModel: Int32, Sendable {
    case unknown = -1
    case monochrome = 0
    case rgb = 1
    case cmyk = 2
    case lab = 3
    case deviceN = 4
    case indexed = 5
    case pattern = 6
    case XYZ = 7
}

public final class CGColorSpace: Foundation.NSObject, @unchecked Sendable {
    enum Kind: String, CaseIterable {
        case genericRGB = "kCGColorSpaceGenericRGB"
        case genericGray = "kCGColorSpaceGenericGray"
        case genericGrayGamma2_2 = "kCGColorSpaceGenericGrayGamma2_2"
        case sRGB = "kCGColorSpaceSRGB"
        case extendedSRGB = "kCGColorSpaceExtendedSRGB"
        case linearSRGB = "kCGColorSpaceLinearSRGB"
        case extendedLinearSRGB = "kCGColorSpaceExtendedLinearSRGB"
        case displayP3 = "kCGColorSpaceDisplayP3"

        var name: CFString {
            CFStringCreateWithCString(nil, rawValue, CFStringBuiltInEncodings.UTF8.rawValue)!
        }
    }

    private let kind: Kind

    init(_ kind: Kind) {
        self.kind = kind
        super.init()
    }

    public convenience init?(name: CFString) {
        guard let kind = Kind.allCases.first(where: { CFEqual($0.name, name) }) else {
            return nil
        }
        self.init(kind)
    }

    public static var sRGB: CFString { Kind.sRGB.name }
    public static var extendedSRGB: CFString { Kind.extendedSRGB.name }
    public static var linearSRGB: CFString { Kind.linearSRGB.name }
    public static var extendedLinearSRGB: CFString { Kind.extendedLinearSRGB.name }
    public static var displayP3: CFString { Kind.displayP3.name }
    public static var genericGrayGamma2_2: CFString { Kind.genericGrayGamma2_2.name }

    public var name: CFString? { kind.name }

    public var model: CGColorSpaceModel {
        switch kind {
        case .genericGray, .genericGrayGamma2_2: .monochrome
        default: .rgb
        }
    }

    public var numberOfComponents: Int {
        model == .monochrome ? 1 : 3
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CGColorSpace else { return false }
        return kind == other.kind
    }

    public override var hash: Int { kind.hashValue }

    var usesExtendedRange: Bool {
        kind == .extendedSRGB || kind == .extendedLinearSRGB
    }

    private enum TransferFunction {
        case linear
        case sRGB
        case gamma1_8

        func decode(_ value: CGFloat) -> CGFloat {
            switch self {
            case .linear:
                return value
            case .sRGB:
                let magnitude = abs(value)
                if magnitude <= 0.04045 { return value / 12.92 }
                return copysign(pow((magnitude + 0.055) / 1.055, 2.4), value)
            case .gamma1_8:
                if abs(value) <= 0.03125 { return value / 16 }
                return copysign(pow(abs(value), 1.8), value)
            }
        }

        func encode(_ value: CGFloat) -> CGFloat {
            switch self {
            case .linear:
                return value
            case .sRGB:
                let magnitude = abs(value)
                if magnitude <= 0.0031308 { return value * 12.92 }
                return copysign(1.055 * pow(magnitude, 1 / 2.4) - 0.055, value)
            case .gamma1_8:
                if abs(value) <= 0.001953125 { return value * 16 }
                return copysign(pow(abs(value), 1 / 1.8), value)
            }
        }
    }

    private var transferFunction: TransferFunction {
        switch kind {
        case .linearSRGB, .extendedLinearSRGB: .linear
        case .genericRGB, .genericGray: .gamma1_8
        // Generic Gray Gamma 2.2 uses the sRGB transfer curve.
        default: .sRGB
        }
    }

    private enum Primaries {
        case sRGB
        case displayP3
        case genericRGB
        case gray
    }

    private var primaries: Primaries {
        switch kind {
        case .displayP3: .displayP3
        case .genericRGB: .genericRGB
        case .genericGray, .genericGrayGamma2_2: .gray
        default: .sRGB
        }
    }

    func convert(_ components: [CGFloat], to destination: CGColorSpace) -> [CGFloat] {
        if primaries == destination.primaries {
            guard transferFunction != destination.transferFunction else {
                return Array(components.prefix(numberOfComponents))
            }
            return components.prefix(numberOfComponents).map {
                destination.transferFunction.encode(transferFunction.decode($0))
            }
        }
        let linear = components.prefix(numberOfComponents).map(transferFunction.decode)
        let rgb: (CGFloat, CGFloat, CGFloat)
        switch primaries {
        case .sRGB:
            rgb = (linear[0], linear[1], linear[2])
        case .gray:
            rgb = (linear[0], linear[0], linear[0])
        case .displayP3:
            // D65 Display P3 to linear sRGB, from the standard RGB/XYZ matrices.
            rgb = (
                1.2249401763 * linear[0] - 0.2249401763 * linear[1],
                -0.0420569547 * linear[0] + 1.0420569547 * linear[1],
                -0.0196375546 * linear[0] - 0.0786360456 * linear[1] + 1.0982736002 * linear[2]
            )
        case .genericRGB:
            // Generic RGB profile primaries, adapted to linear sRGB.
            rgb = (
                1.0252417326 * linear[0] - 0.0265452433 * linear[1] + 0.0013035525 * linear[2],
                0.0194007643 * linear[0] + 0.9480088353 * linear[1] + 0.0325903520 * linear[2],
                -0.0017621303 * linear[0] - 0.0014344937 * linear[1] + 1.0031965971 * linear[2]
            )
        }
        let result: [CGFloat]
        switch destination.primaries {
        case .sRGB:
            result = [rgb.0, rgb.1, rgb.2]
        case .gray:
            // Normalized D50 luminance of the sRGB profile.
            result = [0.2224952 * rgb.0 + 0.7168951 * rgb.1 + 0.0606097 * rgb.2]
        case .displayP3:
            result = [
                0.8224619687 * rgb.0 + 0.1775380313 * rgb.1,
                0.0331941989 * rgb.0 + 0.9668058011 * rgb.1,
                0.0170826307 * rgb.0 + 0.0723974407 * rgb.1 + 0.9105199286 * rgb.2,
            ]
        case .genericRGB:
            result = [
                0.9748595404 * rgb.0 + 0.0272938328 * rgb.1 - 0.0021534126 * rgb.2,
                -0.0200081405 * rgb.0 + 1.0542304567 * rgb.1 - 0.0342222652 * rgb.2,
                0.0016837457 * rgb.0 + 0.0015554102 * rgb.1 + 0.9967608709 * rgb.2,
            ]
        }
        return result.map(destination.transferFunction.encode)
    }
}
