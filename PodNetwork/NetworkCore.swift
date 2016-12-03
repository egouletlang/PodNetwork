//
//  NetworkCore.swift
//  Phoenix
//
//  Created by Etienne Goulet-Lang on 9/24/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation
import UIKit
import BaseUtils

open class NetworkCore {
    
    open static let instance = NetworkCore()
    
    private let defQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Network Queue"
        queue.qualityOfService = QualityOfService.background
        return queue
    }()
    private static let TIMEOUT_SECS: TimeInterval = 15
    
    
    public enum Errors: Error {
        case InvalidUrl
    }
    
    public enum ConnectionStatus {
        case connected
        case offline
        case checking
    }
    
    open func sendAsync(request: BaseHttpRequest,
                   queue: OperationQueue?,
                   callback: @escaping (_ response: BaseHttpResponse)->Void) {
        ThreadUtils.checkedExecuteOnBackgroundThread() {
            
            do {
                let urlReq = try self.buildURLRequest(request: request)
                urlReq.timeoutInterval = NetworkCore.TIMEOUT_SECS
                self.asyncRequest(request: urlReq as URLRequest, queue: queue ?? self.defQueue, showSpinner: request.showNetworkActivity(), callback: callback)
            } catch {
                callback(BaseHttpResponse.buildClientError(msg: "Error Building the HTTP Request."))
                return
            }
        }
    }
    open func sendSync(request: BaseHttpRequest,
                  queue: OperationQueue?,
                  callback: (_ response: BaseHttpResponse)->Void) {
        
    }
    
    private func buildURLRequest(request: BaseHttpRequest) throws -> NSMutableURLRequest {
        return try buildURLRequest(urlString: request.getUrl(),
                                   requestMethod: request.getHTTPMethod(),
                                   requestBody: request.getData(),
                                   headers: request.getHeaders())
    }
    private func buildURLRequest(urlString: String,
                                 requestMethod: String,
                                 requestBody: Data?,
                                 headers: [String: AnyObject]?) throws -> NSMutableURLRequest {
        
        guard let url = URL(string: urlString) else {
            throw Errors.InvalidUrl
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = requestMethod
        request.httpBody = requestBody as Data?
        
        if let headers = headers {
            for (key, value) in headers {
                
                // If header value is simple string, just set it as-is
                if let valueStr = value as? String {
                    request.setValue(valueStr, forHTTPHeaderField: key)
                } else {
                    // If header value is an array of strings, concatenate them all with "," according to RFC 2616
                    let values = value as! [String]
                    let singleValue = values.joined(separator: ";")
                    request.setValue(singleValue, forHTTPHeaderField: key)
                }
                
            }
        }
        return request
    }
    
    private func processURLResponse(response: URLResponse?, data: Data?, error: Error?) -> BaseHttpResponse {
        
        // The response should be an HTTP response
        if let httpResponse = response as? HTTPURLResponse {
            return BaseHttpResponse(response: httpResponse, data: data, error: error)
        } else {
            // If response is nil (or not expected type) we hopefully have an error that we can print.
            // Regardless, something bad happened and we have to bail
            if let e = error {
                return BaseHttpResponse.buildServerError(msg: e.localizedDescription)
            } else {
                return BaseHttpResponse.buildConnectivityError(msg: nil)
            }
        }
    }
    
    
    open func asyncRequest(request: URLRequest,
                      queue: OperationQueue,
                      showSpinner: Bool,
                      callback: @escaping (_ response: BaseHttpResponse) -> Void) {
        
        
        
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                   delegate: nil,
                                   delegateQueue: queue)
        
        
        
        let dataSize = (Double (request.httpBody?.count ?? 0))/1024.0/1024.0
        print ("data size - \(dataSize)")
        
        
        
        
        
        
        let task = session.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            let httpResponse = self.processURLResponse(response: response, data: data, error: error)
            
            print("task done")
            
            // Let the spinner continue
            callback(httpResponse)
            
        }
        task.resume()
    }
    
    open func syncRequest(request: URLRequest,
                     showSpinner: Bool) -> BaseHttpResponse {
        
        var urlResponse: URLResponse?
        var error: Error?
        var data: Data?
        
        do {
            data = try NSURLConnection.sendSynchronousRequest(request, returning: &urlResponse)
        } catch let error1 as NSError {
            error = error1
            data = nil
        } catch Errors.InvalidUrl {
            return BaseHttpResponse.buildClientError(msg: "Invalid URL: \(request.url?.absoluteURL.absoluteString ?? "")")
        }
        
        let httpResponse = processURLResponse(response: urlResponse, data: data, error: error)
        
        return httpResponse
    }
    
}
