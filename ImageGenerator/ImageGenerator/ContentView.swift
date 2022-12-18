//
//  ContentView.swift
//  ImageGenerator
//
//  Created by Jhonathan Matos on 18/12/22.
//

import SwiftUI
import OpenAIKit

final class ViewModel: ObservableObject {
    private var openAI: OpenAI?
    private var apiKey: String = "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"
    private var organization: String = "jhonnMAB"
    
    func setup() {
        openAI = OpenAI(Configuration(organization: organization, apiKey: apiKey))
    }
    
    func generateImage(prompt: String) async -> UIImage? {
        guard let openAI = openAI else {
            return nil
        }
        do {
            let params = ImageParameters(
                prompt: prompt,
                resolution: .medium,
                responseFormat: .base64Json
            )
            let result = try await  openAI.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openAI.decodeBase64Image(data)
            return image
        }
        catch {
            print(String(describing: error))
            return nil
        }
    }
}


struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Type prompt to generate image!")
                }
                Spacer()
                TextField("Type prompt here...", text: $text)
                    .padding()
                Button("Generate") {
                    Task {
                        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                            let result = await  viewModel.generateImage(prompt: text)
                            if result != nil {
                                self.image = result
                            }
                        }
                    }
                }
                .padding()
                .symbolVariant(.fill)
                .foregroundColor(.red)
            }
            .navigationTitle("ALL-E Image Generator")
            .bold()
            .onAppear {
                viewModel.setup()
            }
            .padding()
        }
        .background(Color(hue: 0.656, saturation: 1.0, brightness: 0.461))
        .preferredColorScheme(.dark)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
