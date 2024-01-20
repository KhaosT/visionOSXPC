//
//  XPCEndpointsService.swift
//  CentralExchange
//
//  Created by Khaos Tian on 1/20/24.
//

import Foundation
import os

class XPCEndpointsService: NSObject, XPCEndpointsServiceProtocol {

    private let lock = OSAllocatedUnfairLock()
    private var endpointsMap: [String: NSXPCListenerEndpoint] = [:]

    func registerEndpoint(name: String, endpoint: NSXPCListenerEndpoint) {
        lock.withLock {
            endpointsMap[name] = endpoint
        }
    }
    
    func getEndpoint(name: String, completionHandler: @escaping (NSXPCListenerEndpoint?) -> Void) {
        let endpoint = lock.withLock {
            return endpointsMap[name]
        }

        completionHandler(endpoint)
    }

    func getAllEndpoints(completionHandler: @escaping (NSDictionary) -> Void) {
        let endpoints = lock.withLock {
            return endpointsMap
        }

        completionHandler(endpoints as NSDictionary)
    }
}
