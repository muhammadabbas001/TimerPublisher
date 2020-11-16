//
//  ContentView.swift
//  PracticeCombine
//
//  Created by Muhammad Abbas on 11/16/20.
//

import SwiftUI

//Model
struct User: Decodable, Identifiable{
    let id: Int
    let name: String
}

//ViewModels
import Combine

final class ViewModel: ObservableObject{
    @Published var time = ""
    @Published var users = [User]()
    
    private var cancelable = Set<AnyCancellable>()
    
    var formatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .medium
        return df
    }()
    
    init(){
        setupPublisher()
        setupDataTaskPublisher()
    }
    
    private func setupDataTaskPublisher(){
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap{(data, response) in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else{
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [User].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }){users in
                self.users.append(contentsOf: users)
            }
            .store(in: &cancelable)
    }
    
    //Publisher
    private func setupPublisher(){
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .receive(on: RunLoop.main)
            .sink{value in
                self.time = self.formatter.string(from: value)
            }
            .store(in: &cancelable)
    }
}

//Views
struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    var body: some View {
        Text(viewModel.time)
            .padding()
        List(viewModel.users){user in
            Text("\(user.name)")
        }
    }
}
