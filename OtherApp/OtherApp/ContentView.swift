//
//  ContentView.swift
//  OtherApp
//
//  Created by Khaos Tian on 1/20/24.
//

import SwiftUI

struct ContentView: View {

    private let viewModel = ContentViewModel()

    @State
    private var showFilePicker = false

    @State
    private var text = ""

    var body: some View {
        NavigationStack {
            List {
                if viewModel.service == nil {
                    Button(
                        action: {
                            showFilePicker = true
                        },
                        label: {
                            Text("Select endpoint to start")
                        }
                    )
                } else if viewModel.textService == nil {
                    Button(
                        action: {
                            viewModel.connect()
                        },
                        label: {
                            Text("Connect to text service")
                        }
                    )
                } else {
                    TextField("Type something...", text: $text)
                }
            }
            .navigationTitle("Text Input XPC")
            .listStyle(.insetGrouped)
        }
        .onChange(of: text) {
            viewModel.sendTextUpdate(text)
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.data],
            onCompletion: { result in
                switch result {
                case .success(let url):
                    viewModel.setupServiceWithEndpoint(url)
                case .failure(let error):
                    NSLog("Error: %@", error as NSObject)
                }
            }
        )
    }
}
