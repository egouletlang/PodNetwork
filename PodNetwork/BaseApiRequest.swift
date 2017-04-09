//
//  BaseApiRequest.swift
//  PodNetwork
//
//  Created by Etienne Goulet-Lang on 2/16/17.
//  Copyright © 2017 Etienne Goulet-Lang. All rights reserved.
//

import Foundation

open class BaseApiRequest: BaseHttpRequest {
    
    // MARK: Static HTTP Queue
    private static let apiQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "API Queue"
        queue.qualityOfService = QualityOfService.userInitiated
        return queue
    }()
    
    override open func getHTTPMethod() -> String {
        return self.body != nil ? "POST" : super.getHTTPMethod()
    }
    
    // MARK: - URL -
    override open func getUrl() -> String {
        let url = getHost() +
            getApiVersion() +
            getApiEndpoint() +
            (buildUrlEncodedParams() ?? "")
        print("\(getHTTPMethod())     \(url)")
        return url
    }
    open func buildUrlEncodedParams() -> String? {
        guard let params = getUrlParams() else {
            return nil
        }
        let customAllowedSet =  NSCharacterSet(charactersIn:"=\"#%/<>?@\\^`{|}").inverted
        
        var paramStr = ""
        for (key, val) in params {
            if  let k = key.addingPercentEncoding(withAllowedCharacters: customAllowedSet),
                let v = val.addingPercentEncoding(withAllowedCharacters: customAllowedSet) {
                paramStr += paramStr.isEmpty ? "?" : "&"
                paramStr += "\(k)=\(v)"
            }
        }
        
        return paramStr
    }
    
    // MARK: - Default Headers -
    override open func getHeaders() -> [String : AnyObject]? {
        var headers: [String: String] = getCustomHeaders()
        
        if self.body != nil {
            headers["Content-Type"] = "application/json"
        } else if self.getData() != nil {
            headers["Content-Type"] = "multipart/form-data"
        }
        
        return headers as [String : AnyObject]?
        
    }
    override open func getData() -> Data? {
        if let b = self.body , b.count > 0 {

            do {
                return try JSONSerialization.data(withJSONObject: b, options: JSONSerialization.WritingOptions.prettyPrinted)
            } catch {
            }
        }
        return nil
    }
    
    private func __send() {
        NetworkCore.instance.sendAsync(request: self, queue: BaseApiRequest.apiQueue, callback: __response)
    }
    
    open func send() {
        self.__send()
    }
    
    // Methods to Override
    open func getCustomHeaders() -> [String: String] {
        return [:]
    }
    
    open func getHost() -> String {
        return ""
    }
    open func getApiVersion() -> String {
        return ""
    }
    open func getApiEndpoint() -> String {
        return ""
    }
    open func getUrlParams() -> [String: AnyObject]? {
        return nil
    }
    
    open lazy var body: [String: AnyObject]? = {
       return self.getBody()
    }()
    open func getBody() -> [String: AnyObject]? {
        return nil
    }
    
    private func __response(resp: BaseHttpResponse) {
        
        if resp.isSuccess() {
            self.success(response: resp)
        }
        if resp.isConnectivityError() {
            self.err_connectivity(response: resp)
        }
        if resp.isUnauthorized() {
            if self.err_unauthorized(response: resp) {
                // This will get retried
                return
            }
        }
        if resp.isServerError() {
            self.err_server(response: resp)
        }
        // Handle
        
        self.callback?(resp)
    }
    
    open func success(response: BaseHttpResponse) {}
    open func err_connectivity(response: BaseHttpResponse) {
        print("connectivity error")
    }
    open func err_unauthorized(response: BaseHttpResponse) -> Bool {
        return false
    }
    open func err_server(response: BaseHttpResponse) {
        print("\(getApiEndpoint()) -- server error")
    }
    
    open var callback: ((BaseHttpResponse)->Void)?
    open func withCallback(callback: @escaping (BaseHttpResponse)->Void) -> BaseApiRequest {
        self.callback = callback
        return self
    }
    
}


