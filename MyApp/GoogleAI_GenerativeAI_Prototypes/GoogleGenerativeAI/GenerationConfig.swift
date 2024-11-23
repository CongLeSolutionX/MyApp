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

/// A struct defining model parameters to be used when sending generative AI
/// requests to the backend model.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct GenerationConfig {
  /// A parameter controlling the degree of randomness in token selection. A
  /// temperature of zero is deterministic, always choosing the
  /// highest-probability response. Typical values are between 0 and 1
  /// inclusive. Defaults to 0 if unspecified.
  public let temperature: Float?

  /// The `topP` parameter changes how the model selects tokens for output.
  /// Tokens are selected from the most to least probable until the sum of
  /// their probabilities equals the `topP` value. For example, if tokens A, B,
  /// and C have probabilities of 0.3, 0.2, and 0.1 respectively and the topP
  /// value is 0.5, then the model will select either A or B as the next token
  /// by using the `temperature` and exclude C as a candidate.
  /// Defaults to 0.95 if unset.
  public let topP: Float?

  /// The `topK` parameter changes how the model selects tokens for output. A
  /// `topK` of 1 means the selected token is the most probable among all the
  /// tokens in the model's vocabulary, while a `topK` of 3 means that the next
  /// token is selected from among the 3 most probable using the `temperature`.
  /// For each token selection step, the `topK` tokens with the highest
  /// probabilities are sampled. Tokens are then further filtered based on
  /// `topP` with the final token selected using `temperature` sampling.
  /// Defaults to 40 if unspecified.
  public let topK: Int?

  /// The maximum number of generated response messages to return. This value
  /// must be between [1, 8], inclusive. If unset, this will default to 1.
  ///
  /// - Note: Only unique candidates are returned. Higher temperatures are more
  ///     likely to produce unique candidates. Setting `temperature` to 0 will
  ///     always produce exactly one candidate regardless of the
  ///     `candidateCount`.
  public let candidateCount: Int?

  /// Specifies the maximum number of tokens that can be generated in the
  /// response. The number of tokens per word varies depending on the
  /// language outputted. The maximum value is capped at 1024. Defaults to 0
  /// (unbounded).
  public let maxOutputTokens: Int?

  /// A set of up to 5 `String`s that will stop output generation. If
  /// specified, the API will stop at the first appearance of a stop sequence.
  /// The stop sequence will not be included as part of the response.
  public let stopSequences: [String]?

  /// Output response MIME type of the generated candidate text.
  ///
  /// Supported MIME types:
  /// - `text/plain`: Text output; the default behavior if unspecified.
  /// - `application/json`: JSON response in the candidates.
  public let responseMIMEType: String?

  /// Output response schema of the generated candidate text.
  ///
  /// - Note: This only applies when the specified ``responseMIMEType`` supports a schema; currently
  ///   this is limited to `application/json`.
  public let responseSchema: Schema?

  /// Creates a new `GenerationConfig` value.
  ///
  /// - Parameters:
  ///   - temperature: See ``temperature``.
  ///   - topP: See ``topP``.
  ///   - topK: See ``topK``.
  ///   - candidateCount: See ``candidateCount``.
  ///   - maxOutputTokens: See ``maxOutputTokens``.
  ///   - stopSequences: See ``stopSequences``.
  ///   - responseMIMEType: See ``responseMIMEType``.
  ///   - responseSchema: See ``responseSchema``.
  public init(temperature: Float? = nil, topP: Float? = nil, topK: Int? = nil,
              candidateCount: Int? = nil, maxOutputTokens: Int? = nil,
              stopSequences: [String]? = nil, responseMIMEType: String? = nil,
              responseSchema: Schema? = nil) {
    // Explicit init because otherwise if we re-arrange the above variables it changes the API
    // surface.
    self.temperature = temperature
    self.topP = topP
    self.topK = topK
    self.candidateCount = candidateCount
    self.maxOutputTokens = maxOutputTokens
    self.stopSequences = stopSequences
    self.responseMIMEType = responseMIMEType
    self.responseSchema = responseSchema
  }
}

// MARK: - Codable Conformances

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
extension GenerationConfig: Encodable {}
