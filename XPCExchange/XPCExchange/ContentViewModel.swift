//
//  ContentViewModel.swift
//  XPCExchange
//
//  Created by Khaos Tian on 1/20/24.
//

import Foundation
import Observation

@Observable
class ContentViewModel {

    private(set) var service: XPCEndpointsServiceProtocol?
    private(set) var endpoints: [String: NSXPCListenerEndpoint] = [:]
    private var lastEndpointURL: URL? {
        didSet {
            oldValue?.stopAccessingSecurityScopedResource()
        }
    }

    let textService = TextTransferService()

    init() {
        if let data = UserDefaults.standard.value(forKey: "lastUrl") as? Data {
            let url = try! NSKeyedUnarchiver.unarchivedObject(ofClass: NSURL.self, from: data)!
            setupServiceWithEndpoint(url as URL, isInit: true)
        }
    }

    func refreshEndpoints() {
        guard let service else {
            return
        }

        NSLog("Refreshing endpoints")
        service.getAllEndpoints { endpoints in
            NSLog("Handler invoked")

            DispatchQueue.main.async {
                if let endpoints = endpoints as? [String: NSXPCListenerEndpoint] {
                    self.endpoints = endpoints
                }
            }
        }
    }

    func setupServiceWithEndpoint(_ url: URL, isInit: Bool = false) {
        if !isInit {
            let data = try! NSKeyedArchiver.archivedData(withRootObject: url, requiringSecureCoding: true)
            UserDefaults.standard.setValue(data, forKey: "lastUrl")
        }

        lastEndpointURL = url
        _ = url.startAccessingSecurityScopedResource()

        FileManager.default.getFileProviderServicesForItem(
            at: url,
            completionHandler: { sources, error in
                if let error {
                    NSLog("Error: %@", error as NSError)
                }

                if let sources,
                   let source = sources[NSFileProviderServiceName(rawValue: "app.cerio.XPCExchange.endpoints")] {
                    source.getFileProviderConnection { connection, error in
                        if let error {
                            NSLog("Error: %@", error as NSError)
                        }

                        if let connection {
                            let interface = NSXPCInterface(with: XPCEndpointsServiceProtocol.self)

                            /// Here since we are putting `NSXPCListenerEndpoint` in a dictionary, we have to set it as allowed class.
                            interface.setClasses(
                                NSSet(
                                    objects: NSString.self, NSXPCListenerEndpoint.self, NSDictionary.self
                                ) as Set,
                                for: #selector(XPCEndpointsServiceProtocol.getAllEndpoints(completionHandler:)),
                                argumentIndex: 0,
                                ofReply: true
                            )

                            connection.remoteObjectInterface = interface
                            connection.interruptionHandler = { [weak self] in
                                NSLog("Interruption happened")
                                self?.service = nil
                            }
                            connection.invalidationHandler = { [weak self] in
                                NSLog("Invalidation happened")
                                self?.service = nil
                            }
                            connection.resume()

                            if let proxy = connection.remoteObjectProxy as? XPCEndpointsServiceProtocol {
                                self.service = proxy
                                proxy.registerEndpoint(name: "text", endpoint: self.textService.listener.endpoint)
                                self.refreshEndpoints()
                            }
                        }
                    }
                }
            }
        )
    }
}
