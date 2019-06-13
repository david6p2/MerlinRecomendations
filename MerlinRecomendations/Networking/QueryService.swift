//
//  QueryService.swift
//  MerlinRecomendations
//
//  Created by David A Cespedes R on 6/13/19.
//  Copyright © 2019 David A Cespedes R. All rights reserved.
//

import Foundation


// Runs query data task, and stores results in array of Tracks
class QueryService {
  
  typealias JSONDictionary = [String: Any]
  typealias QueryResult = ([Venue]?, String) -> ()
  
  // 1
  let defaultSession = URLSession(configuration: .default)
  // 2
  var dataTask: URLSessionDataTask?
  var venues: [Venue] = []
  var errorMessage = ""
  
  func getVenuesResults(completion: @escaping QueryResult) {
    // 1
    dataTask?.cancel()
    // 2
    if var urlComponents = URLComponents(string: "https://api.foursquare.com/v2/venues/explore") {
      let client_id = "client_id=THIZC0VI0JOVPHJJJW1JIJNX5HWCTP1DCMQ1RJFE22IFL0OX"
      let client_secret = "client_secret=VBYPUXJL044KXSUY2RYYRAVY4DRKJR4XFL3AKMD5VB1EYSJQ"
      let v = "v=20180405"
      let near = "near=New York"
      urlComponents.query = client_id+"&"+client_secret+"&"+v+"&"+near
      // 3
      guard let url = urlComponents.url else { return }
      // 4
      dataTask = defaultSession.dataTask(with: url) { data, response, error in
        defer { self.dataTask = nil }
        // 5
        if let error = error {
          self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
        } else if let data = data,
          let response = response as? HTTPURLResponse,
          response.statusCode == 200 {
          self.updateSearchResults(data)
          // 6
          DispatchQueue.main.async {
            completion(self.venues, self.errorMessage)
          }
        }
      }
      // 7
      dataTask?.resume()
    }
  }
  
  fileprivate func updateSearchResults(_ data: Data) {
    var response: JSONDictionary?
    venues.removeAll()
    
    do {
      response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
    } catch let parseError as NSError {
      errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
      return
    }
    
    guard let responseDict = response!["response"]/*["groups"][0]["items"]*/ as? [String:Any] else {
      errorMessage += "Dictionary does not contain results key\n"
      return
    }
    guard let groupsArray = responseDict["groups"] as? [Any] else {
      errorMessage += "Array does not contain results key\n"
      return
    }
    guard let group = groupsArray.first as? [String:Any] else {
      errorMessage += "Dictionary does not contain results key\n"
      return
    }
    guard let itemsArray = group["items"] as? [[String:Any]] else {
      errorMessage += "Array does not contain results key\n"
      return
    }
    for item in itemsArray {
      guard let venueDictionary = item["venue"] as? [String:Any] else {
        errorMessage += "Dictionary does not contain results key\n"
        return
      }
      print(venueDictionary)
      
      
      guard let categories = venueDictionary["categories"] as? [[String:Any]] else {
        errorMessage += "Dictionary does not contain results key\n"
        return
      }
      
      guard let locationDict = venueDictionary["location"] as? [String:Any] else {
        errorMessage += "Dictionary does not contain results key\n"
        return
      }
      
      if let name = venueDictionary["name"] as? String,
        let categoryDict = categories.first,
        let categoryName = categoryDict["name"] as? String,
        let categoryIcon = categoryDict["icon"] as? [String:String],
        let iconPrefix = categoryIcon["prefix"],
        let iconSuffix = categoryIcon["suffix"],
        let latitude = locationDict["lat"] as? Double,
        let longitude = locationDict["lng"] as? Double {
        let icon = VenueImage(prefix:iconPrefix, suffix:iconSuffix, size: 100)
        let location = Location(latitude:latitude,longitude:longitude)
        venues.append(Venue(name:name, category:categoryName, location: location, icon: icon))
      }
    }
  }

}
