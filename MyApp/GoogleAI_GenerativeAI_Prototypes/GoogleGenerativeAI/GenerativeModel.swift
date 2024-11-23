// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// A type that represents a remote multimodal model (like Gemini), with the ability to generate
/// content based on various input types.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public final class GenerativeModel {
  // The prefix for a model resource in the Gemini API.
  private static let modelResourcePrefix = "models/"

  /// The resource name of the model in the backend; has the format "models/model-name".
  let modelResourceName: String

  /// The backing service responsible for sending and receiving model requests to the backend.
  let generativeAIService: GenerativeAIService

  /// Configuration parameters used for the MultiModalModel.
  let generationConfig: GenerationConfig?

  /// The safety settings to be used for prompts.
  let safetySettings: [SafetySetting]?

  /// A list of tools the model may use to generate the next response.
  let tools: [Tool]?

  /// Tool configuration for any `Tool` specified in the request.
  let toolConfig: ToolConfig?

  /// Instructions that direct the model to behave a certain way.
  let systemInstruction: ModelContent?

  /// Configuration parameters for sending requests to the backend.
  let requestOptions: RequestOptions

  /// Initializes a new remote model with the given parameters.
  ///
  /// - Parameters:
  ///   - name: The name of the model to use, for example `"gemini-1.5-pro-latest"`; see
  ///     [Gemini models](https://ai.google.dev/models/gemini) for a list of supported model names.
  ///   - apiKey: The API key for your project.
  ///   - generationConfig: The content generation parameters your model should use.
  ///   - safetySettings: A value describing what types of harmful content your model should allow.
  ///   - tools: A list of ``Tool`` objects  that the model may use to generate the next response.
  ///   - systemInstruction: Instructions that direct the model to behave a certain way; currently
  ///     only text content is supported, for example
  ///     `ModelContent(role: "system", parts: "You are a cat. Your name is Neko.")`.
  ///   - toolConfig: Tool configuration for any `Tool` specified in the request.
  ///   - requestOptions Configuration parameters for sending requests to the backend.
  public convenience init(name: String,
                          apiKey: String,
                          generationConfig: GenerationConfig? = nil,
                          safetySettings: [SafetySetting]? = nil,
                          tools: [Tool]? = nil,
                          toolConfig: ToolConfig? = nil,
                          systemInstruction: ModelContent? = nil,
                          requestOptions: RequestOptions = RequestOptions()) {
    self.init(
      name: name,
      apiKey: apiKey,
      generationConfig: generationConfig,
      safetySettings: safetySettings,
      tools: tools,
      toolConfig: toolConfig,
      systemInstruction: systemInstruction,
      requestOptions: requestOptions,
      urlSession: .shared
    )
  }

  /// Initializes a new remote model with the given parameters.
  ///
  /// - Parameters:
  ///   - name: The name of the model to use, e.g., `"gemini-1.5-pro-latest"`; see
  ///     [Gemini models](https://ai.google.dev/models/gemini) for a list of supported model names.
  ///   - apiKey: The API key for your project.
  ///   - generationConfig: The content generation parameters your model should use.
  ///   - safetySettings: A value describing what types of harmful content your model should allow.
  ///   - tools: A list of ``Tool`` objects  that the model may use to generate the next response.
  ///   - systemInstruction: Instructions that direct the model to behave a certain way; currently
  ///     only text content is supported, e.g., "You are a cat. Your name is Neko."
  ///   - toolConfig: Tool configuration for any `Tool` specified in the request.
  ///   - requestOptions Configuration parameters for sending requests to the backend.
  public convenience init(name: String,
                          apiKey: String,
                          generationConfig: GenerationConfig? = nil,
                          safetySettings: [SafetySetting]? = nil,
                          tools: [Tool]? = nil,
                          toolConfig: ToolConfig? = nil,
                          systemInstruction: String...,
                          requestOptions: RequestOptions = RequestOptions()) {
    self.init(
      name: name,
      apiKey: apiKey,
      generationConfig: generationConfig,
      safetySettings: safetySettings,
      tools: tools,
      toolConfig: toolConfig,
      systemInstruction: ModelContent(
        role: "system",
        parts: systemInstruction.map { ModelContent.Part.text($0) }
      ),
      requestOptions: requestOptions,
      urlSession: .shared
    )
  }

  /// The designated initializer for this class.
  init(name: String,
       apiKey: String,
       generationConfig: GenerationConfig? = nil,
       safetySettings: [SafetySetting]? = nil,
       tools: [Tool]? = nil,
       toolConfig: ToolConfig? = nil,
       systemInstruction: ModelContent? = nil,
       requestOptions: RequestOptions = RequestOptions(),
       urlSession: URLSession) {
    modelResourceName = GenerativeModel.modelResourceName(name: name)
    generativeAIService = GenerativeAIService(apiKey: apiKey, urlSession: urlSession)
    self.generationConfig = generationConfig
    self.safetySettings = safetySettings
    self.tools = tools
    self.toolConfig = toolConfig
    self.systemInstruction = systemInstruction
    self.requestOptions = requestOptions

    Logging.default.info("""
    [GoogleGenerativeAI] Model \(
      name,
      privacy: .public
    ) initialized. To enable additional logging, add \
    `\(Logging.enableArgumentKey, privacy: .public)` as a launch argument in Xcode.
    """)
    Logging.verbose.debug("[GoogleGenerativeAI] Verbose logging enabled.")
  }

  /// Generates content from String and/or image inputs, given to the model as a prompt, that are
  /// representable as one or more ``ModelContent/Part``s.
  ///
  /// Since ``ModelContent/Part``s do not specify a role, this method is intended for generating
  /// content from
  /// [zero-shot](https://developers.google.com/machine-learning/glossary/generative#zero-shot-prompting)
  /// or "direct" prompts. For
  /// [few-shot](https://developers.google.com/machine-learning/glossary/generative#few-shot-prompting)
  /// prompts, see `generateContent(_ content: @autoclosure () throws -> [ModelContent])`.
  ///
  /// - Parameter content: The input(s) given to the model as a prompt (see
  /// ``ThrowingPartsRepresentable``
  /// for conforming types).
  /// - Returns: The content generated by the model.
  /// - Throws: A ``GenerateContentError`` if the request failed.
  public func generateContent(_ parts: any ThrowingPartsRepresentable...)
    async throws -> GenerateContentResponse {
    return try await generateContent([ModelContent(parts: parts)])
  }

  /// Generates new content from input content given to the model as a prompt.
  ///
  /// - Parameter content: The input(s) given to the model as a prompt.
  /// - Returns: The generated content response from the model.
  /// - Throws: A ``GenerateContentError`` if the request failed.
  public func generateContent(_ content: @autoclosure () throws -> [ModelContent]) async throws
    -> GenerateContentResponse {
    let response: GenerateContentResponse
    do {
      let generateContentRequest = try GenerateContentRequest(model: modelResourceName,
                                                              contents: content(),
                                                              generationConfig: generationConfig,
                                                              safetySettings: safetySettings,
                                                              tools: tools,
                                                              toolConfig: toolConfig,
                                                              systemInstruction: systemInstruction,
                                                              isStreaming: false,
                                                              options: requestOptions)
      response = try await generativeAIService.loadRequest(request: generateContentRequest)
    } catch {
      if let imageError = error as? ImageConversionError {
        throw GenerateContentError.promptImageContentError(underlying: imageError)
      }
      throw GenerativeModel.generateContentError(from: error)
    }

    // Check the prompt feedback to see if the prompt was blocked.
    if response.promptFeedback?.blockReason != nil {
      throw GenerateContentError.promptBlocked(response: response)
    }

    // Check to see if an error should be thrown for stop reason.
    if let reason = response.candidates.first?.finishReason, reason != .stop {
      throw GenerateContentError.responseStoppedEarly(reason: reason, response: response)
    }

    return response
  }

  /// Generates content from String and/or image inputs, given to the model as a prompt, that are
  /// representable as one or more ``ModelContent/Part``s.
  ///
  /// Since ``ModelContent/Part``s do not specify a role, this method is intended for generating
  /// content from
  /// [zero-shot](https://developers.google.com/machine-learning/glossary/generative#zero-shot-prompting)
  /// or "direct" prompts. For
  /// [few-shot](https://developers.google.com/machine-learning/glossary/generative#few-shot-prompting)
  /// prompts, see `generateContent(_ content: @autoclosure () throws -> [ModelContent])`.
  ///
  /// - Parameter content: The input(s) given to the model as a prompt (see
  /// ``ThrowingPartsRepresentable``
  /// for conforming types).
  /// - Returns: A stream wrapping content generated by the model or a ``GenerateContentError``
  ///     error if an error occurred.
  @available(macOS 12.0, *)
  public func generateContentStream(_ parts: any ThrowingPartsRepresentable...)
    -> AsyncThrowingStream<GenerateContentResponse, Error> {
    return try generateContentStream([ModelContent(parts: parts)])
  }

  /// Generates new content from input content given to the model as a prompt.
  ///
  /// - Parameter content: The input(s) given to the model as a prompt.
  /// - Returns: A stream wrapping content generated by the model or a ``GenerateContentError``
  ///     error if an error occurred.
  @available(macOS 12.0, *)
  public func generateContentStream(_ content: @autoclosure () throws -> [ModelContent])
    -> AsyncThrowingStream<GenerateContentResponse, Error> {
    let evaluatedContent: [ModelContent]
    do {
      evaluatedContent = try content()
    } catch let underlying {
      return AsyncThrowingStream { continuation in
        let error: Error
        if let contentError = underlying as? ImageConversionError {
          error = GenerateContentError.promptImageContentError(underlying: contentError)
        } else {
          error = GenerateContentError.internalError(underlying: underlying)
        }
        continuation.finish(throwing: error)
      }
    }

    let generateContentRequest = GenerateContentRequest(model: modelResourceName,
                                                        contents: evaluatedContent,
                                                        generationConfig: generationConfig,
                                                        safetySettings: safetySettings,
                                                        tools: tools,
                                                        toolConfig: toolConfig,
                                                        systemInstruction: systemInstruction,
                                                        isStreaming: true,
                                                        options: requestOptions)

    var responseIterator = generativeAIService.loadRequestStream(request: generateContentRequest)
      .makeAsyncIterator()
    return AsyncThrowingStream {
      let response: GenerateContentResponse?
      do {
        response = try await responseIterator.next()
      } catch {
        throw GenerativeModel.generateContentError(from: error)
      }

      // The responseIterator will return `nil` when it's done.
      guard let response = response else {
        // This is the end of the stream! Signal it by sending `nil`.
        return nil
      }

      // Check the prompt feedback to see if the prompt was blocked.
      if response.promptFeedback?.blockReason != nil {
        throw GenerateContentError.promptBlocked(response: response)
      }

      // If the stream ended early unexpectedly, throw an error.
      if let finishReason = response.candidates.first?.finishReason, finishReason != .stop {
        throw GenerateContentError.responseStoppedEarly(reason: finishReason, response: response)
      } else {
        // Response was valid content, pass it along and continue.
        return response
      }
    }
  }

  /// Creates a new chat conversation using this model with the provided history.
  public func startChat(history: [ModelContent] = []) -> Chat {
    return Chat(model: self, history: history)
  }

  /// Runs the model's tokenizer on String and/or image inputs that are representable as one or more
  /// ``ModelContent/Part``s.
  ///
  /// Since ``ModelContent/Part``s do not specify a role, this method is intended for tokenizing
  /// [zero-shot](https://developers.google.com/machine-learning/glossary/generative#zero-shot-prompting)
  /// or "direct" prompts. For
  /// [few-shot](https://developers.google.com/machine-learning/glossary/generative#few-shot-prompting)
  /// input, see `countTokens(_ content: @autoclosure () throws -> [ModelContent])`.
  ///
  /// - Parameter content: The input(s) given to the model as a prompt (see
  /// ``ThrowingPartsRepresentable``
  /// for conforming types).
  /// - Returns: The results of running the model's tokenizer on the input; contains
  /// ``CountTokensResponse/totalTokens``.
  /// - Throws: A ``CountTokensError`` if the tokenization request failed.
  public func countTokens(_ parts: any ThrowingPartsRepresentable...) async throws
    -> CountTokensResponse {
    return try await countTokens([ModelContent(parts: parts)])
  }

  /// Runs the model's tokenizer on the input content and returns the token count.
  ///
  /// - Parameter content: The input given to the model as a prompt.
  /// - Returns: The results of running the model's tokenizer on the input; contains
  /// ``CountTokensResponse/totalTokens``.
  /// - Throws: A ``CountTokensError`` if the tokenization request failed or the input content was
  /// invalid.
  public func countTokens(_ content: @autoclosure () throws -> [ModelContent]) async throws
    -> CountTokensResponse {
    do {
      let generateContentRequest = try GenerateContentRequest(model: modelResourceName,
                                                              contents: content(),
                                                              generationConfig: generationConfig,
                                                              safetySettings: safetySettings,
                                                              tools: tools,
                                                              toolConfig: toolConfig,
                                                              systemInstruction: systemInstruction,
                                                              isStreaming: false,
                                                              options: requestOptions)
      let countTokensRequest = CountTokensRequest(
        model: modelResourceName,
        generateContentRequest: generateContentRequest,
        options: requestOptions
      )
      return try await generativeAIService.loadRequest(request: countTokensRequest)
    } catch {
      throw CountTokensError.internalError(underlying: error)
    }
  }

  /// Returns a model resource name of the form "models/model-name" based on `name`.
  private static func modelResourceName(name: String) -> String {
    if name.contains("/") {
      return name
    } else {
      return modelResourcePrefix + name
    }
  }

  /// Returns a `GenerateContentError` (for public consumption) from an internal error.
  ///
  /// If `error` is already a `GenerateContentError` the error is returned unchanged.
  private static func generateContentError(from error: Error) -> GenerateContentError {
    if let error = error as? GenerateContentError {
      return error
    } else if let error = error as? RPCError, error.isInvalidAPIKeyError() {
      return GenerateContentError.invalidAPIKey(message: error.message)
    } else if let error = error as? RPCError, error.isUnsupportedUserLocationError() {
      return GenerateContentError.unsupportedUserLocation
    }
    return GenerateContentError.internalError(underlying: error)
  }
}

/// An error thrown in `GenerativeModel.countTokens(_:)`.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public enum CountTokensError: Error {
  case internalError(underlying: Error)
}
