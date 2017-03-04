//
//  BaseHttpResponse.swift
//  Phoenix
//
//  Created by Etienne Goulet-Lang on 9/24/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class BaseHttpResponse {
    
    open static let CLIENT_ERROR = -100
    open static let CONNECTIVITY_ERROR = -110
    open static let INCORRECT_RESPONSE_ERROR = -120
    open static let SERVER_ERROR = -130
    
    private func parseJson(top: String) {
        
        print(top)
        print(top.replacingOccurrences(of: "\\\"", with: "\""))
        
        var mod = top.replacingOccurrences(of: "\\\"", with: "\"")
//        mod = String(mod.characters.dropFirst())
//        mod = String(mod.characters.dropLast())
        
//        let parts = mod.characters.split{$0 == ";"}.map(String.init)
//        
//        var response = [String: AnyObject]()
//        
        do {
            self.body = try JSONSerialization.jsonObject(with: mod.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments)
        } catch let error {
            print(error.localizedDescription)
        }
        
        
    }
    
    
    public init (statusCode: Int) {
        self.statusCode = statusCode
    }
    
    public init (response: HTTPURLResponse, data: Data?, error: Error?) {
        self.statusCode = response.statusCode
        self.headers = response.allHeaderFields as? [String: AnyObject]
        
        let dataSize = (Double (data?.count ?? 0))/1024.0/1024.0
        print ("data size - \(data==nil) \(dataSize)")
        
        if let d = data {
            do {
                self.body = try JSONSerialization.jsonObject(with: d as Data, options: JSONSerialization.ReadingOptions.allowFragments)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        description = error?.localizedDescription
    }
    
    open let statusCode: Int!
    open var headers: [String: AnyObject]?
    open var body: Any?
    open var description: String?
    
    open func isSuccess() -> Bool {
        return (statusCode / 100 == 2)
    }
    open func isConnectivityError() -> Bool {
        return (statusCode == BaseHttpResponse.CONNECTIVITY_ERROR)
    }
    open func isUnauthorized() -> Bool {
        return (statusCode == 403 || statusCode == 401)
    }
    open func isServerError() -> Bool {
        return (statusCode / 100 == 5 || statusCode == 404)
    }
    
    
    open static func buildClientError(msg: String?) -> BaseHttpResponse {
        let resp = BaseHttpResponse(statusCode: CLIENT_ERROR)
        resp.description = msg
        return resp
    }
    open static func buildConnectivityError(msg: String?) -> BaseHttpResponse {
        let resp = BaseHttpResponse(statusCode: CONNECTIVITY_ERROR)
        resp.description = msg
        return resp
    }
    open static func buildServerError(msg: String?) -> BaseHttpResponse {
        let resp = BaseHttpResponse(statusCode: SERVER_ERROR)
        resp.description = msg
        return resp
    }
    
    // Mock Building
    open func with(body: [String: AnyObject]?) -> BaseHttpResponse {
        self.body = body
        return self
    }
    
}
