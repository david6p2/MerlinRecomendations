//
//  VenueImage.swift
//  MerlinRecomendations
//
//  Created by David A Cespedes R on 6/13/19.
//  Copyright © 2019 David A Cespedes R. All rights reserved.
//

import Foundation

struct VenueImage {
  let prefix: String
  let suffix: String
  let size: Int
  
  func createIconURL(withPrefix prefix:String, size:Int, suffix:String) -> URL {
    return URL(string: prefix + "\(size)" + suffix)!
  }
}
