//
//  FlickerRequest.swift
//  MyTripDiary
//
//  Created by Man Wai  Law on 2019-05-05.
//  Copyright © 2019 Rita's company. All rights reserved.

import Foundation
struct FlickrAPI {
    static let key = "b6717100c12e0bec49e0b9dcbec347fb"
    let secret = "dca01acfc8e0a8ab"
    let methodName = "flickr.photos.search"
    let baseURL = "api.flickr.com"
    let path = "/services/rest/"
    
    func getURLComponents() -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = baseURL
        urlComponents.path = path
        return urlComponents
    }
}

struct PhotoSearch:Codable {
    var lat:Double
    var lon:Double
    var api_key:String
    var in_gallery:Bool?=false
    var per_page:Int=100
    var page:Int=1
}
