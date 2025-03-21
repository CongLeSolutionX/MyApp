//
//  Phi4_Model_View.swift
//  MyApp
//
//  Created by Cong Le on 3/21/25.
//
import SwiftUI
import AVFoundation

struct MultimodalView: View {
    @State private var responseText: String = ""
    @State private var isProcessing: Bool = false
    // Assuming you have a way to select images and record audio.
    // These would typically be handled by some UI elements, and the resulting data stored in State variables.
    @State private var selectedImage: UIImage? = nil
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVPlayer?
    @State private var audioData: Data?
    @State private var isShowingImagePicker = false // Control the image picker presentation

    // Replace with your actual API key as needed for testing, but remove before production!
    // Ideally, API key should be loaded from environment config or securely stored, not hardcoded.
    let apiKey = "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"
    let invokeURLString = "https://integrate.api.nvidia.com/v1/chat/completions"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Multimodal Interaction")
                    .font(.largeTitle)
                    .padding(.bottom)

                // Image Picker Placeholder (Replace with actual image picker)
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .border(Color.gray, width: 1)
                } else {
                    Button("Select Image") {
                        // Trigger image selection (implementation below)
                        isShowingImagePicker = true //Set true to show the sheet
                    }
                    .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $isShowingImagePicker) {  // Present ImagePicker as a sheet
                           ImagePicker { image in
                               self.selectedImage = image
                               self.isShowingImagePicker = false // Dismiss the picker
                           }
                    }

                }

                // Audio Recording Placeholder (Replace with actual audio recorder & controls)
                HStack {

                    Button(action: {
                        if audioRecorder != nil {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    }) {
                        Image(systemName: audioRecorder == nil ? "mic.circle.fill" : "stop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 44)
                            .foregroundColor(audioRecorder == nil ? .blue : .red)
                    }

                    if let audioData = audioData, let audioURL = temporaryAudioFileURL(from: audioData) {
                        Button(action: { playAudio(url: audioURL) }) {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.vertical)

                 // Display Response
                Text("Response:")
                    .font(.headline)

                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                     Text(responseText.isEmpty ? "Awaiting response..." : responseText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .border(Color.gray, width: 1)
                        .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                }

                // Submit Button
                Button("Submit") {
                    Task {
                        await submitRequest()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing || selectedImage == nil || audioData == nil )  // Disable button if processing/no image/no audio
                .padding(.top)
            }
            .padding()
        } .onDisappear {
            //Ensure stop recording and other clear up on disappear
            stopRecording()
            audioPlayer?.pause()
            audioPlayer = nil
            audioData = nil

        }
    }

    func startRecording() {
           let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")

           let settings: [String: Any] = [
               AVFormatIDKey: Int(kAudioFormatLinearPCM),
               AVSampleRateKey: 16000, // Standard rate for speech-to-text
               AVNumberOfChannelsKey: 1, // Mono
               AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
           ]

        do {
               audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
               audioRecorder?.delegate =  Coordinator(parent: self)  // Delegate to the helper method
               audioRecorder?.record()
           } catch {
               print("Failed to start recording: \(error)")
               responseText = "Failed to start recording: \(error.localizedDescription)"

               // Handle the error appropriately (e.g., display an alert to the user)
           }
       }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil // Release the recorder

        // Read the audio data.  IMPORTANT to use @State for audioData
        if let audioFileURL = getDocumentsDirectory().appendingPathComponent("recording.wav").path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let fileURL = URL(string: audioFileURL){
            do {
                audioData = try Data(contentsOf: fileURL) // Assign to @State
            } catch {
                responseText = "Error reading audio file after recording: \(error.localizedDescription)"
                return
            }
        }

    }

     func playAudio(url: URL) {
           do {
                // Set up the audio session for playback and allow mixing with other audio
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true) // Activate audio session

               audioPlayer = AVPlayer(url: url)
               audioPlayer?.play()
           } catch {
               print("Audio playback failed: \(error)")
               responseText = "Audio playback failed: \(error.localizedDescription)"
               // presentAlert(title: "Audio Error", message: "Audio playback failed: \(error.localizedDescription)")
           }
       }

     func temporaryAudioFileURL(from data: Data) -> URL? {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        //Create specific URL in temp directory.
        let uniqueFileName = UUID().uuidString + ".wav"
        let tempFileURL = tempDirectoryURL.appendingPathComponent(uniqueFileName)

        do {
            // Data.write the data to file on disk
            try data.write(to: tempFileURL)

        } catch {
            print("Failed to write temporary audio file: \(error) at file \(tempFileURL.absoluteString)")

            responseText = "Failed to write temporary audio file: \(error.localizedDescription)"
            isProcessing = false
            //   presentAlert(title: "File Error", message: "Failed to write temporary audio file: \(error.localizedDescription)")
            return nil // Early exit if we can't write to file
        }
        return tempFileURL
    }

     func getDocumentsDirectory() -> URL {
          let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
          return paths[0]
      }

    func submitRequest() async {
        guard let url = URL(string: invokeURLString) else {
            responseText = "Invalid URL"
            return
        }

        guard let image = selectedImage, let imageData = image.pngData() else {
            responseText = "Invalid Image"
            return
        }
        let imageBase64 = imageData.base64EncodedString()

         guard let audio = audioData else {
            responseText = "Invalid audio data."
            return
        }

        let audioBase64 = audio.base64EncodedString()

        //Assertion
         guard imageBase64.utf8.count + audioBase64.utf8.count < 180_000 else {
             responseText = "Image and/or audio too large. Use the assets API for larger files."
             //      presentAlert(title: "Data Size Limit", message: "Image/Audio is too large. Max combined size is 180KB for this API.")
             return
         }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")  // Not streaming
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "model": "microsoft/phi-4-multimodal-instruct",
            "messages": [
                [
                    "role": "user",
                    "content": "Answer the spoken query about the image.<img src=\"data:image/png;base64,\(imageBase64)\" /><audio src=\"data:audio/wav;base64,\(audioBase64)\" />"
                ]
            ],
            "max_tokens": 512,
            "temperature": 0.10,
            "top_p": 0.70,
            "stream": false // Not streaming
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            responseText = "Error encoding payload: \(error.localizedDescription)"
            return
        }

        isProcessing = true // Set processing state before starting the request
        responseText = ""   // Clear previous response

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            isProcessing = false // Finished processing

               guard let httpResponse = response as? HTTPURLResponse else {
                   responseText = "Invalid server response"
                   print("Error: Invalid HTTP response") // More descriptive error
                   return
               }

            if httpResponse.statusCode == 200 {
                // Success, process response
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {

                    responseText = content
                }
            } else {  //Handles different error codes
                let errorData = String(data: data, encoding: .utf8) ?? "No error details"
                print("HTTP Error \(httpResponse.statusCode): \(errorData)")
                responseText = "Server Error \(httpResponse.statusCode): \(errorData)" //Display error
            }

        } catch {
            isProcessing = false
            responseText = "Network request failed: \(error.localizedDescription)"
        }
    }

    //Custom UIKit integration helper structs for image picker in SwiftUI.

    struct ImagePicker: UIViewControllerRepresentable {
        // Nested Coordinator class to handle the image picker delegate methods
          class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
              var parent: ImagePicker  // Reference back to containing ImagePicker struct

              init(parent: ImagePicker) {
                  self.parent = parent
              }

              func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                  if let uiImage = info[.originalImage] as? UIImage {
                      parent.onImagePicked(uiImage)   //Call the closure
                  }
                  picker.dismiss(animated: true)
              }

              func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                  picker.dismiss(animated: true)
              }

          }

        var onImagePicked: (UIImage) -> Void  // Closure to pass selected image

        //Creates and returns the coordinator
        func makeCoordinator() -> Coordinator {
            return Coordinator(parent: self)
        }

        // Creates the UIImagePickerController instance
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator // Set the coordinator as the delegate
            picker.sourceType = .photoLibrary // Choose the source type to use the photo library
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
            // No updates needed when the view updates.
        }

    }

    //AVAudioRecorderDelegate helper class
    class Coordinator: NSObject, AVAudioRecorderDelegate {
        var parent: MultimodalView

        init(parent: MultimodalView) {
            self.parent = parent
        }

        func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
            if !flag {
                print("Recording failed")
                parent.responseText = "Recording Failed."
                // Handle UI updates on the main thread
            }
        }
    }
}

#Preview {
    MultimodalView()
}
