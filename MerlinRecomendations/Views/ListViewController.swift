//
//  ListViewController.swift
//  MerlinRecomendations
//
//  Created by David A Cespedes R on 6/13/19.
//  Copyright © 2019 David A Cespedes R. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
  
  var venuesResult: [Venue] = []
  let queryService = QueryService()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    queryService.getVenuesResults() { results, errorMessage in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      if let results = results {
        print(results)
//        self.venuesResult = results
//        self.tableView.reloadData()
//        self.tableView.setContentOffset(CGPoint.zero, animated: false)
      }
      if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
    }
  }


}

