//
//  ContentView.swift
//  PracticeCombine
//
//  Created by Muhammad Abbas on 11/16/20.
//

import SwiftUI
import Combine

final class ViewModel: ObservableObject{
    @Published var time = ""
    private var anyCancelable: AnyCancellable?
    
    var formatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .medium
        return df
    }()
    
    init(){
        setupPublisher()
    }
    
    private func setupPublisher(){
        anyCancelable = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .receive(on: RunLoop.main)
            .sink{value in
                self.time = self.formatter.string(from: value)
            }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    var body: some View {
        Text(viewModel.time)
            .padding()
    }
}
