//
//  BaseHttpResponse.swift
//  Phoenix
//
//  Created by Etienne Goulet-Lang on 9/24/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

class BaseHttpResponse {
    
    static let CLIENT_ERROR = -100
    static let CONNECTIVITY_ERROR = -110
    static let INCORRECT_RESPONSE_ERROR = -120
    static let SERVER_ERROR = -130
    
    
    init (statusCode: Int) {
        self.statusCode = statusCode
    }
    
    init (response: HTTPURLResponse, data: Data?, error: Error?) {
        self.statusCode = response.statusCode
        self.headers = response.allHeaderFields as? [String: AnyObject]
        
        if let d = data {
            do {
                self.body = try JSONSerialization.jsonObject(with: d as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject]
            } catch {}
        }
        
        description = error?.localizedDescription
    }
    
    let statusCode: Int!
    var headers: [String: AnyObject]?
    var body: [String: AnyObject]?
    var description: String?
    
    func isSuccess() -> Bool {
        return (statusCode / 100 == 2)
    }
    func isConnectivityError() -> Bool {
        return (statusCode == BaseHttpResponse.CONNECTIVITY_ERROR)
    }
    func isUnauthorized() -> Bool {
        return (statusCode == 403 || statusCode == 401)
    }
    func isServerError() -> Bool {
        return (statusCode / 100 == 5 || statusCode == 404)
    }
    
    
    static func buildClientError(msg: String?) -> BaseHttpResponse {
        let resp = BaseHttpResponse(statusCode: CLIENT_ERROR)
        resp.description = msg
        return resp
    }
    static func buildConnectivityError(msg: String?) -> BaseHttpResponse {
        let resp = BaseHttpResponse(statusCode: CONNECTIVITY_ERROR)
        resp.description = msg
        return resp
    }
    static func buildServerError(msg: String?) -> BaseHttpResponse {
        let resp = BaseHttpResponse(statusCode: SERVER_ERROR)
        resp.description = msg
        return resp
    }
    
    // Mock Building
    func with(body: [String: AnyObject]?) -> BaseHttpResponse {
        self.body = body
        return self
    }
    
}
