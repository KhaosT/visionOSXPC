//
//  FileProviderItem.swift
//  CentralExchange
//
//  Created by Khaos Tian on 1/20/24.
//

import FileProvider
import UniformTypeIdentifiers

class FileProviderItem: NSObject, NSFileProviderItem {

    private let identifier: NSFileProviderItemIdentifier
    
    init(identifier: NSFileProviderItemIdentifier) {
        self.identifier = identifier
    }
    
    var itemIdentifier: NSFileProviderItemIdentifier {
        return identifier
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return .rootContainer
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        return [
            .allowsReading,
        ]
    }
    
    var itemVersion: NSFileProviderItemVersion {
        NSFileProviderItemVersion(
            contentVersion: Data("1".utf8),
            metadataVersion: Data("1".utf8)
        )
    }
    
    var filename: String {
        return identifier.rawValue
    }

    var documentSize: NSNumber? {
        return 0
    }

    var contentType: UTType {
        return identifier == NSFileProviderItemIdentifier.rootContainer ? .folder : .data
    }

    var storageURL: URL {
        if identifier == .rootContainer {
            return NSFileProviderManager.default.documentStorageURL
        } else {
            return NSFileProviderManager.default.documentStorageURL.appending(
                path: filename,
                directoryHint: .notDirectory
            )
        }
    }
}
