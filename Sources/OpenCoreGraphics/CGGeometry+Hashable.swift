//
//  CGGeometry+Hashable.swift
//  OpenCoreGraphics

#if !canImport(Darwin)
// Foundation does not provide Hashable conformance for CG types yet.
// See https://github.com/swiftlang/swift-corelibs-foundation/issues/5275
extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension CGSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin)
        hasher.combine(size)
    }
}
#endif
