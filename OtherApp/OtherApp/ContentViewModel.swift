//
//  ContentViewModel.swift
//  OtherApp
//
//  Created by Khaos Tian on 1/20/24.
//

import Foundation
import Observation

@Observable
class ContentViewModel {

    private(set) var service: XPCEndpointsServiceProtocol?
    private(set) var textService: TextTransferServiceProtocol?
    private var lastEndpointURL: URL? {
        didSet {
            oldValue?.stopAccessingSecurityScopedResource()
        }
    }

    init() {
        if let data = UserDefaults.standard.value(forKey: "lastUrl") as? Data {
            let url = try! NSKeyedUnarchiver.unarchivedObject(ofClass: NSURL.self, from: data)!
            setupServiceWithEndpoint(url as URL, isInit: true)
        }
    }

    func connect() {
        guard let service else {
            return
        }

        service.getEndpoint(name: "text") { endpoint in
            guard let endpoint else {
                return
            }

            DispatchQueue.main.async {
                let connection = NSXPCConnection(listenerEndpoint: endpoint)
                connection.remoteObjectInterface = NSXPCInterface(with: TextTransferServiceProtocol.self)
                connection.invalidationHandler = { [weak self] in
                    NSLog("Invalidated")
                    self?.textService = nil
                }
                connection.interruptionHandler = { [weak self] in
                    NSLog("Interrupted")
                    self?.textService = nil
                }
                connection.resume()

                if let textService = connection.remoteObjectProxy as? TextTransferServiceProtocol {
                    self.textService = textService
                }
            }
        }
    }

    func sendTextUpdate(_ text: String) {
        textService?.textDidChange(text)
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
                            connection.remoteObjectInterface = NSXPCInterface(with: XPCEndpointsServiceProtocol.self)
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
                            }
                        }
                    }
                }
            }
        )
    }
}
