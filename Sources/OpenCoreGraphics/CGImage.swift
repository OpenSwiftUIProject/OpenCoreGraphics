//
//  CGImage.swift
//  OpenCoreGraphics
//
//  Created by Kyle on 1/11/26.

public class CGImage: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func == (lhs: CGImage, rhs: CGImage) -> Bool {
        lhs === rhs
    }
}

extension CGImage: @unchecked Sendable {}
