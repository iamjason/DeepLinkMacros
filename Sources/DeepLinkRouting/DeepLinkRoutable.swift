//
//  DeepLinkRoutable.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Protocol that destination enums conform to for automatic route discovery.
/// The @DeepLinkDestination macro generates the `allRoutes` implementation.
public protocol DeepLinkRoutable {
  /// All routes defined on this destination type.
  /// Generated automatically by the macro when at least one case has @DeepLinkRoute.
  static var allRoutes: [DeepLinkRouteDefinition<Self>] { get }
}
