//
//  IOSurface.swift
//  OpenCoreGraphics
//
//  Created by Kyle on 1/17/26.

public class IOSurfaceRef: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func == (lhs: IOSurfaceRef, rhs: IOSurfaceRef) -> Bool {
        lhs === rhs
    }
}

extension IOSurfaceRef: @unchecked Sendable {}
