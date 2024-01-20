//
//  XPCEndpointsServiceListener.swift
//  CentralExchange
//
//  Created by Khaos Tian on 1/20/24.
//

import Foundation

class XPCEndpointsServiceListener {

    static let shared = XPCEndpointsServiceListener()

    private let listenerDelegate = XPCListenerDelegate()
    private let listener = NSXPCListener.anonymous()

    private let service = XPCEndpointsService()

    private init() {
        listenerDelegate.service = service

        listener.delegate = listenerDelegate
        listener.activate()
    }

    var endpoint: NSXPCListenerEndpoint {
        return listener.endpoint
    }

    class XPCListenerDelegate: NSObject, NSXPCListenerDelegate {

        weak var service: XPCEndpointsService?

        func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
            // TODO: Create something to track connections and clean up registered endpoints on interruption.
            
            newConnection.exportedObject = service
            newConnection.exportedInterface = NSXPCInterface(with: XPCEndpointsServiceProtocol.self)
            newConnection.interruptionHandler = {
                NSLog("Connection Interrupted")
            }
            newConnection.invalidationHandler = {
                NSLog("Connection Invalidated")
            }

            newConnection.resume()

            return true
        }
    }
}
