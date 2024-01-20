//
//  FileProviderEnumerator.swift
//  CentralExchange
//
//  Created by Khaos Tian on 1/20/24.
//

import FileProvider

class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    
    private let enumeratedItemIdentifier: NSFileProviderItemIdentifier

    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier) {
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        super.init()
    }

    func invalidate() {}

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        guard enumeratedItemIdentifier == .rootContainer else {
            observer.finishEnumerating(upTo: nil)
            return
        }

        observer.didEnumerate(
            [
                FileProviderItem(identifier: .endpoints),
            ]
        )
        observer.finishEnumerating(upTo: nil)
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
    }

    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        completionHandler(
            NSFileProviderSyncAnchor(Data([0x01]))
        )
    }
}
