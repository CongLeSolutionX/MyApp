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

#if !os(macOS) && !os(iOS)
  #warning("Only iOS, macOS, and Catalyst targets are currently fully supported.")
#endif

/// Constants associated with the GenerativeAISwift SDK.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public enum GenerativeAISwift {
  /// String value of the SDK version
  public static let version = "0.5.6"
  /// The Google AI backend endpoint URL.
  static let baseURL = "https://generativelanguage.googleapis.com"
}
