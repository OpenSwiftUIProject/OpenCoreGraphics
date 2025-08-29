//
//  Export.swift
//  OpenQuartzCoreShims

#if OPENGRAPHICS_COREGRAPHICS
@_exported import QuartzCore
#else
@_exported import OpenQuartzCore
@_exported import OpenGraphics // QuartzCore will export CoreGraphics
@_exported import CoreFoundation // CoreGraphics will export CoreFoundation
@_exported import Foundation // For non-Darwin platforms, CG_TYPES is defined on Foundation
#endif
