//
//  CGContext.swift
//  OpenCoreGraphics
//
//  Created by Kyle on 1/11/26.
//  Status: Empty

public class CGContext: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func == (lhs: CGContext, rhs: CGContext) -> Bool {
        lhs === rhs
    }
}
