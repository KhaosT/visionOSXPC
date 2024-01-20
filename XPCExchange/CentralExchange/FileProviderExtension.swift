//
//  FileProviderExtension.swift
//  CentralExchange
//
//  Created by Khaos Tian on 1/20/24.
//

import FileProvider

class FileProviderExtension: NSFileProviderExtension {

    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        return FileProviderItem(identifier: identifier)
    }

    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        let item = FileProviderItem(identifier: identifier)
        return item.storageURL
    }

    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        let storageURL = NSFileProviderManager.default.documentStorageURL

        if url == storageURL {
            return .rootContainer
        } else {
            var file = url.lastPathComponent
            if file.hasSuffix("/") {
                file.removeFirst()
            }
            return NSFileProviderItemIdentifier(file)
        }
    }

    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        var file = url.lastPathComponent
        if file.hasSuffix("/") {
            file.removeFirst()
        }

        if file.isEmpty {
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }

        let targetURL = NSFileProviderManager.placeholderURL(for: url)
        do {
            try NSFileProviderManager.writePlaceholder(
                at: targetURL,
                withMetadata: FileProviderItem(
                    identifier: NSFileProviderItemIdentifier(file)
                )
            )
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }

    override func startProvidingItem(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        var file = url.lastPathComponent
        if file.hasSuffix("/") {
            file.removeFirst()
        }

        if file.isEmpty {
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }

        let data = Data()
        try? data.write(to: url)
        completionHandler(nil)
    }

    override func stopProvidingItem(at url: URL) {}

    override func itemChanged(at url: URL) {}

    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        return FileProviderEnumerator(enumeratedItemIdentifier: containerItemIdentifier)
    }

    override func supportedServiceSources(for itemIdentifier: NSFileProviderItemIdentifier) throws -> [NSFileProviderServiceSource] {
        guard itemIdentifier == .endpoints else {
            return []
        }

        return [
            XPCEndpointsServiceSource(),
        ]
    }
}
