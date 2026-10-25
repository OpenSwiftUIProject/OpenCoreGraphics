//
//  CGBlendMode.swift
//  OpenCoreGraphics

public enum CGBlendMode: Int32, @unchecked Sendable {
    case normal = 0
    case multiply = 1
    case screen = 2
    case overlay = 3
    case darken = 4
    case lighten = 5
    case colorDodge = 6
    case colorBurn = 7
    case softLight = 8
    case hardLight = 9
    case difference = 10
    case exclusion = 11
    case hue = 12
    case saturation = 13
    case color = 14
    case luminosity = 15
    case clear = 16
    case copy = 17
    case sourceIn = 18
    case sourceOut = 19
    case sourceAtop = 20
    case destinationOver = 21
    case destinationIn = 22
    case destinationOut = 23
    case destinationAtop = 24
    case xor = 25
    case plusDarker = 26
    case plusLighter = 27
}
