//
//  DeepLinkMacrosPlugin.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DeepLinkMacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    DeepLinkRouteMacro.self,
    DeepLinkDestinationMacro.self,
  ]
}
