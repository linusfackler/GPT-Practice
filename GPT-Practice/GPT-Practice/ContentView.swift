//
//  ContentView.swift
//  GPT-Practice
//
//  Created by Linus Fackler on 6/23/23.
//

import SwiftUI
import OpenAISwift
import OpenAIKit

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAIKit?
    
    let apiToken: String = "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"
    let organizationName: String = "Fackler IT"
    
    func setup() {
        client = OpenAIKit(apiToken: apiToken, organization: organizationName)
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(prompt: text, model: .gptV3_5(.davinciText003), maxTokens: 2048) { [weak self] result in
            switch result {
            case .success(let aiResult):
                if let text = aiResult.choices.first?.text {
                    completion(text)
                }
            case failure(let error):
                completion(error)
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    
    var body: some View {
        VStack (alignment: .leading) {
            ForEach(models, id: \.self) { string in
                Text(string)
            }
            
            Spacer()
            
            HStack {
                TextField("Type here...", text: $text)
                Button("Send") {
                    send()
                }
            }
        }
        .onAppear {
            viewModel.setup()
        }
        .padding()
    }
    
    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        models.append("Me: \(text)")
        viewModel.send(text: text) { response in
            DispatchQueue.main.async {
                self.models.append("ChatGPT: " + response)
                self.text = ""
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
