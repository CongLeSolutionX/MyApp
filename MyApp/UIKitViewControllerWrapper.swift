//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

// Step 1a: UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class MyUIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
      
        demoSlidingWindowAlgorithmExample()
    }
    
    // MARK: - Sliding Window
    
    func demoSlidingWindowAlgorithmExample() {
        
        // Sliding Window - Example 1
        demoSlidingWindowAlgorithm()
        demoPrintOutallSubstringsWithKDistinctCharacters()
        
        // Sliding Window - Example 2
        demoSlicingWindow3()
        demoSlicingWindow3Details()
        
        // Sliding Window - Example 3
        demoSlicingWindow2()
        demoSlicingWindow2Details()
    }
    
    // Sliding Window - Example 1
    func demoSlidingWindowAlgorithm() {
        let s = "araaci"
        let k = 2
        print("Length of the longest substring with \(k) distinct characters: \(longestSubstringWithKDistinct(s, k))")
    }
    
    func demoPrintOutallSubstringsWithKDistinctCharacters() {
        
        // Example usage
        let s = "araaci"
        let k = 2
        print("Substrings with \(k) distinct characters:")
        substringsWithKDistinct(s, k)
    }
    
    func longestSubstringWithKDistinct(_ s: String, _ k: Int) -> Int {
        var maxLength = 0
        var windowStart = 0
        var charFrequency = [Character: Int]()
        
        for (windowEnd, char) in s.enumerated() {
            // Add the current character to the dictionary
            charFrequency[char, default: 0] += 1
            
            // Shrink the sliding window until we have 'k' distinct characters in the frequency dictionary
            while charFrequency.count > k {
                let startChar = s[s.index(s.startIndex, offsetBy: windowStart)]
                charFrequency[startChar]! -= 1
                
                if charFrequency[startChar] == 0 {
                    charFrequency.removeValue(forKey: startChar)
                }
                
                windowStart += 1
            }
            
            // Update the maximum length of the substring found so far
            maxLength = max(maxLength, windowEnd - windowStart + 1)
        }
        
        return maxLength
    }
    
    func substringsWithKDistinct(_ s: String, _ k: Int) {
        var windowStart = 0
        var charFrequency = [Character: Int]()
        
        for (windowEnd, char) in s.enumerated() {
            // Add the current character to the dictionary
            charFrequency[char, default: 0] += 1
            
            // Shrink the sliding window until we have 'k' distinct characters
            while charFrequency.count > k {
                let startChar = s[s.index(s.startIndex, offsetBy: windowStart)]
                charFrequency[startChar]! -= 1
                
                if charFrequency[startChar] == 0 {
                    charFrequency.removeValue(forKey: startChar)
                }
                
                windowStart += 1
            }
            
            // If we have exactly 'k' distinct characters, print the substring
            if charFrequency.count == k {
                let startIdx = s.index(s.startIndex, offsetBy: windowStart)
                let endIdx = s.index(s.startIndex, offsetBy: windowEnd)
                print(String(s[startIdx...endIdx]))
            }
        }
    }
    
    // Sliding Window - Example 2
    
    
    func demoSlicingWindow2() {
        
        // Example usage
        let arr = [2, 1, 5, 1, 3, 2]
        let k = 3
        let maxSum = maxSumSubarray(arr: arr, k: k)
        print("Maximum sum of subarray of size \(k) is \(maxSum)")
    }
    
    func demoSlicingWindow2Details() {
        
        // Example usage
        let arr = [2, 1, 5, 1, 3, 2]
        let k = 3
        print("All subarrays of size \(k):")
        printAllSubarrays(arr: arr, k: k)
    }
    
    func maxSumSubarray(arr: [Int], k: Int) -> Int {
        // Handle edge cases
        if arr.isEmpty || k <= 0 || k > arr.count {
            return 0
        }
        
        var maxSum = 0
        var windowSum = 0
        var windowStart = 0
        
        // Calculate initial window sum
        for windowEnd in 0..<k {
            windowSum += arr[windowEnd]
        }
        
        maxSum = windowSum
        
        // Slide the window through the array
        for windowEnd in k..<arr.count {
            windowSum += arr[windowEnd] - arr[windowStart]
            windowStart += 1
            maxSum = max(maxSum, windowSum)
        }
        
        return maxSum
    }
    
    func printAllSubarrays(arr: [Int], k: Int) {
        // Handle edge cases
        if arr.isEmpty || k <= 0 || k > arr.count {
            print("Invalid input")
            return
        }
        
        for start in 0...(arr.count - k) {
            let subarray = arr[start..<(start + k)]
            print(Array(subarray))
        }
    }
    
    
    // Sliding Window - - Example 3
    
    func demoSlicingWindow3() {
        if let result = maxSumSubarray(ofSize: 3, in: [2, 1, 5, 1, 3, 2]) {
            print("Maximum sum of subarray of size 3 is \(result).")
        } else {
            print("The array is smaller than the subarray size.")
        }
    }
    
    func demoSlicingWindow3Details() {
        substrings(ofSize: 3, in: "abcdef")
    }
    
    func maxSumSubarray(ofSize k: Int, in array: [Int]) -> Int? {
        guard array.count >= k else { return nil }
        
        var maxSum = 0
        var windowSum = 0
        
        // Calculate the sum of the first window
        for i in 0..<k {
            windowSum += array[i]
        }
        
        maxSum = windowSum
        
        // Slide the window across the array
        for i in k..<array.count {
            windowSum += array[i] - array[i - k]
            maxSum = max(maxSum, windowSum)
        }
        
        return maxSum
    }
    
    func substrings(ofSize k: Int, in str: String) {
        guard str.count >= k else {
            print("The string is smaller than the substring size.")
            return
        }

        let characters = Array(str)

        for i in 0...(characters.count - k) {
            let substring = characters[i..<(i + k)]
            print(String(substring))
        }
    }
}
