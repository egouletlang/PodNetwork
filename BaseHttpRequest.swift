//
//  BaseHttpRequest.swift
//  Phoenix
//
//  Created by Etienne Goulet-Lang on 9/24/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

class BaseHttpRequest: NSObject {
    
    func showNetworkActivity() -> Bool {
        return false
    }
    
    func getUrl() -> String {
        return ""
    }
    
    func getHTTPMethod() -> String {
        return "GET"
    }
    
    func getHeaders() -> [String: AnyObject]? {
        return nil
    }
    
    func getData() -> Data? {
        return nil
    }
    
}
