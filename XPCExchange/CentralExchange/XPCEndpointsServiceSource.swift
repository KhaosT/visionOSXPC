//
//  XPCEndpointsServiceSource.swift
//  CentralExchange
//
//  Created by Khaos Tian on 1/20/24.
//

import Foundation
import FileProvider

class XPCEndpointsServiceSource: NSObject, NSFileProviderServiceSource {

    let serviceName = NSFileProviderServiceName("app.cerio.XPCExchange.endpoints")

    func makeListenerEndpoint() throws -> NSXPCListenerEndpoint {
        return XPCEndpointsServiceListener.shared.endpoint
    }
}
