//
//  BaseHttpRequest.swift
//  Phoenix
//
//  Created by Etienne Goulet-Lang on 9/24/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class BaseHttpRequest: NSObject {
    
    open func showNetworkActivity() -> Bool {
        return false
    }
    
    open func getUrl() -> String {
        return ""
    }
    
    open func getHTTPMethod() -> String {
        return "GET"
    }
    
    open func getHeaders() -> [String: AnyObject]? {
        return nil
    }
    
    open func getData() -> Data? {
        return nil
    }
    
}
