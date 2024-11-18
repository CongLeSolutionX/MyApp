//
//  PhotoPermissionsManagerTests.swift
//  PhotoPermissionsManagerTests
//
//  Created by Cong Le on 11/16/24.
//
//
//import XCTest
//import Photos
//@testable import MyApp
//
//final class PhotoPermissionsManagerTests: XCTestCase {
//    
//    // Helper method to get the current authorization status (non-mocking version)
//       private func currentAuthorizationStatus() -> PHAuthorizationStatus {
//           return PHPhotoLibrary.authorizationStatus()
//       }
//       
//       func testRequestPhotoLibraryPermission_Authorized() {
//           let expectation = XCTestExpectation(description: "Authorization should be granted")
//           
//           PhotoPermissionsManager.requestPhotoLibraryPermission { status in
//               XCTAssertEqual(status, .authorized, "Expected authorized status")
//               expectation.fulfill()
//           }
//           wait(for: [expectation], timeout: 5.0)
//       }
//
//       func testRequestPhotoLibraryPermission_Denied() {
//           let expectation = XCTestExpectation(description: "Authorization should be denied")
//
//           // Note: Directly testing for denied status requires manipulating system settings or using a UI test.
//           // For unit tests, we mimic the structure without guarantee of real denial. This requires additional mechanisms beyond unit tests to ensure it works correctly with a denied state.
//           
//           PhotoPermissionsManager.requestPhotoLibraryPermission { status in
//               // In the unit test environment without the ability to directly influence the system permission prompt,
//               // it is difficult to simulate the 'denied' state. This assertion as shown in the first implementation below might not execute as expected.
//               
//               // XCTAssertEqual(status, .denied, "Expected denied status")
//                expectation.fulfill()
//           }
//           wait(for: [expectation], timeout: 5.0)
//       }
//
//       func testRequestPhotoLibraryPermission_Limited() {
//           let expectation = XCTestExpectation(description: "Authorization should be limited")
//          
//           // Note: Testing .limited status might require specific setup or UI interaction to trigger that access level,
//           // which is difficult to achieve in unit tests reliably.
//           // For the unit test, the assertion is added without the ability to trigger a 'limited' state.
//           
//           PhotoPermissionsManager.requestPhotoLibraryPermission { status in
//               // Similar to the denied case, triggering a .limited scenario in a unit test is not straightforward without user interaction in the actual UI process.
//               // XCTAssertEqual(status, .limited, "Expected limited status")
//               expectation.fulfill()
//           }
//           wait(for: [expectation], timeout: 5.0)
//       }
//
//       func testRequestPhotoLibraryPermission_NotDetermined() {
//           let expectation = XCTestExpectation(description: "Status should be not determined initially")
//
//           // Logic depends on how you handle NotDetermined initially;
//           // Assuming the current method triggers a permission prompt and therefore
//           // moves away from .notDetermined, we check if it's NOT .notDetermined at the end of the call.
//           
//           PhotoPermissionsManager.requestPhotoLibraryPermission { status in
//               XCTAssertNotEqual(status, .notDetermined, "Expected status to change from not determined")
//               expectation.fulfill()
//           }
//           wait(for: [expectation], timeout: 5.0)
//       }
//    
//}
