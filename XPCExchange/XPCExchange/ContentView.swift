//
//  ContentView.swift
//  XPCExchange
//
//  Created by Khaos Tian on 1/20/24.
//

import SwiftUI

struct ContentView: View {

    private let viewModel = ContentViewModel()

    @State
    private var showFilePicker = false

    var body: some View {
        NavigationStack {
            List {
                if viewModel.service == nil {
                    Button(
                        action: {
                            showFilePicker = true
                        },
                        label: {
                            Text("Connect to start")
                        }
                    )
                } else {
                    Section("Registered Endpoints") {
                        let endpoints = viewModel.endpoints.keys.sorted()

                        ForEach(endpoints, id: \.self) { endpoint in
                            Text(endpoint)
                        }
                    }

                    Section("Text Service") {
                        Text(viewModel.textService.currentText)
                    }
                }
            }
            .navigationTitle("Overview")
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            viewModel.refreshEndpoints()
                        },
                        label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    )
                    .disabled(viewModel.service == nil)
                }
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
}
