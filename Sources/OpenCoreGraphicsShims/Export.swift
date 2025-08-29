//
//  Export.swift
//  OpenCoreGraphicsShims

#if OPENCOREGRAPHICS_COREGRAPHICS
@_exported import CoreGraphics
#else
@_exported import OpenCoreGraphics
@_exported import CoreFoundation // CoreGraphics will export CoreFoundation
@_exported import Foundation // For non-Darwin platforms, CG_TYPES is defined on Foundation
#endif
