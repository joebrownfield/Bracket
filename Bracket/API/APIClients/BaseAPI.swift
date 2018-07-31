//
//  BaseAPI.swift
//  Bracket
//
//  Created by Joseph Brownfield on 6/5/18.
//  Copyright © 2018 Joseph Brownfield. All rights reserved.
//

import Foundation

protocol HTTPRequirements {
    var baseURL: String { get }
    var httpMethod: HTTPMethod { get }
    var authActive: Bool { get }
}

class BaseAPI: HTTPRequirements {
    init(baseURL: String, httpMethod: HTTPMethod, authActive: Bool) {
        self.baseURL = baseURL
        self.httpMethod = httpMethod
        self.authActive = authActive
    }
    
    var authActive: Bool
    
    var baseURL: String
    
    var httpMethod: HTTPMethod
    
    var endpoint: String?
    
    var args: String?
    
    let nonce = UInt64(floor(NSDate().timeIntervalSince1970 * 1000))
    
    var url: URL {
        return URL(string: (baseURL + (endpoint ?? "") + (args ?? "")))!
    }
    
    var request: URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = httpMethod.rawValue
        req.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        return req
    }
    
    var session: URLSession {
        return URLSession.shared
    }
    
}

func httpRequest<response : Codable>(req: BaseAPI, type: response.Type, completion: @escaping (response?, String?) -> Void ) {
    let task = req.session.dataTask(with: req.request) { (data, urlResponse, error) in
        guard let data = data else {
            if let error = error {
                completion(nil, error.localizedDescription)
            } else {
                completion(nil,"")
            }
            return
        }
        do {
//            let json = try? JSONSerialization.jsonObject(with: data, options: [])
//            print(json)
            let decoder = JSONDecoder()
            let decodedJson = try decoder.decode(response.self, from: data)
            //print(decodedJson)
            completion(decodedJson, nil)
        }
        catch let error {
            print(error)
            print(error.localizedDescription)
            completion(nil, error.localizedDescription)
        }
    }
    task.resume()
}
