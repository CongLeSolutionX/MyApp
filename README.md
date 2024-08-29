# MyApp README

## Introduction

Welcome to the Interactive Swift Demo Application! This application is designed to demonstrate the differences between `inout` parameters and computed properties in Swift. By interacting with the UI, you can observe how these concepts modify data and encapsulate logic.

## Features

- **Dynamic UI:** Enter first and last names to see real-time updates.
- **Inout Parameters:** Experience how function parameters can modify external variables.
- **Computed Properties:** Observe how properties can dynamically compute and update values.

## Getting Started

### Prerequisites

- **Xcode:** Ensure you have the latest version of Xcode installed.
- **Swift:** The application is built using Swift, so familiarity with the language is helpful.

### Installation

1. **Clone the branch below of this repository:**

   ```bash
   git clone https://github.com/CongLeSolutionX/MyApp/tree/inout_parameters_vs_computed_properties
   ```

2. **Open the Project:**
   - Navigate to the project directory and open the `.xcodeproj` or `.xcworkspace` file with Xcode.
3. **Build and Run:**
   - Select a simulator or connect a device, then build and run the project.

## Test Cases

We encourage you to try out the following test cases to explore the application's functionality and learn more about `inout` parameters and computed properties:

### Inout Parameters

Here are detailed test cases that focus on the effects of changing input parameters in the context of both `inout` parameters and computed properties. These test cases will help ensure that the application reacts correctly when the user modifies the input values:


#### Test Case 1: Basic Functionality with Inout Parameters
- **Purpose:** Verify that the `inout` parameter function correctly capitalizes the input names.
- **Steps:**
  1. Enter "john" in the first name text field.
  2. Enter "doe" in the last name text field.
  3. Click the "Use Inout" button.
- **Expected Result:** 
  - The original input label displays "First Name: john" and "Last Name: doe".
  - The result label displays "Inout Result: John Doe", showing that both names have been capitalized.

#### Test Case 2: Change First Name with Inout Parameters
- **Purpose:** Verify that changing the first name input affects the result.
- **Steps:**
  1. Enter "mike" in the first name text field and "doe" in the last name text field.
  2. Click the "Use Inout" button.
- **Expected Result:**
  - The original input label displays "First Name: mike" and "Last Name: doe".
  - The result label displays "Inout Result: Mike Doe".

#### Test Case 3: Change Last Name with Inout Parameters
- **Purpose:** Verify that changing the last name input affects the result.
- **Steps:**
  1. Enter "john" in the first name text field and "smith" in the last name text field.
  2. Click the "Use Inout" button.
- **Expected Result:**
  - The original input label displays "First Name: john" and "Last Name: smith".
  - The result label displays "Inout Result: John Smith".

#### Test Case 4: Modify First Name and Use Inout Parameters
- **Purpose:** Verify that changing the first name input affects the result when using inout parameters.
- **Steps:**
  1. Enter "john" in the first name text field.
  2. Enter "doe" in the last name text field.
  3. Click the "Use Inout" button.
  4. Change the first name to "mike" while keeping the last name as "doe".
  5. Click the "Use Inout" button again.
- **Expected Result:**
  - After step 3, the result label displays "Inout Result: John Doe".
  - After step 5, the result label updates to "Inout Result: Mike Doe", reflecting the change in the first name.

#### Test Case 5: Modify Last Name and Use Inout Parameters
- **Purpose:** Verify that changing the last name input affects the result when using inout parameters.
- **Steps:**
  1. Enter "john" in the first name text field.
  2. Enter "doe" in the last name text field.
  3. Click the "Use Inout" button.
  4. Change the last name to "smith" while keeping the first name as "john".
  5. Click the "Use Inout" button again.
- **Expected Result:**
  - After step 3, the result label displays "Inout Result: John Doe".
  - After step 5, the result label updates to "Inout Result: John Smith", reflecting the change in the last name.

#### Test Case 6: Modify Both Names and Use Inout Parameters
- **Purpose:** Verify that changing both the first and last names affects the result when using inout parameters.
- **Steps:**
  1. Enter "anna" in the first name text field.
  2. Enter "lee" in the last name text field.
  3. Click the "Use Inout" button.
  4. Change the first name to "lucas" and the last name to "brown".
  5. Click the "Use Inout" button again.
- **Expected Result:**
  - After step 3, the result label displays "Inout Result: Anna Lee".
  - After step 5, the result label updates to "Inout Result: Lucas Brown", reflecting the changes in both names.

#### Test Case 7: Modify First Name and Use Computed Properties
- **Purpose:** Verify that changing the first name input affects the computed property result.
- **Steps:**
  1. Enter "john" in the first name text field.
  2. Enter "doe" in the last name text field.
  3. Click the "Use Computed Property" button.
  4. Change the first name to "mike" while keeping the last name as "doe".
  5. Click the "Use Computed Property" button again.
- **Expected Result:**
  - After step 3, the result label shows "Computed Property Result: John Doe" and updates to "Updated to: Jane Smith".
  - After step 5, the result label shows "Computed Property Result: Mike Doe" and updates to "Updated to: Jane Smith", reflecting the change in the first name.

#### Test Case 8: Modify Last Name and Use Computed Properties
- **Purpose:** Verify that changing the last name input affects the computed property result.
- **Steps:**
  1. Enter "john" in the first name text field.
  2. Enter "doe" in the last name text field.
  3. Click the "Use Computed Property" button.
  4. Change the last name to "smith" while keeping the first name as "john".
  5. Click the "Use Computed Property" button again.
- **Expected Result:**
  - After step 3, the result label shows "Computed Property Result: John Doe" and updates to "Updated to: Jane Smith".
  - After step 5, the result label shows "Computed Property Result: John Smith" and updates to "Updated to: Jane Smith", reflecting the change in the last name.

#### Test Case 9: Modify Both Names and Use Computed Properties
- **Purpose:** Verify that changing both the first and last names affects the computed property result.
- **Steps:**
  1. Enter "anna" in the first name text field.
  2. Enter "lee" in the last name text field.
  3. Click the "Use Computed Property" button.
  4. Change the first name to "lucas" and the last name to "brown".
  5. Click the "Use Computed Property" button again.
- **Expected Result:**
  - After step 3, the result label shows "Computed Property Result: Anna Lee" and updates to "Updated to: Jane Smith".
  - After step 5, the result label shows "Computed Property Result: Lucas Brown" and updates to "Updated to: Jane Smith", reflecting the changes in both names.

These test cases focus on ensuring that the application correctly processes changes to the input parameters and that the results displayed in the UI accurately reflect these changes.


### Computed Properties

Below are test cases with clear descriptions and expected results for testing the effects of computed properties:


#### Test Case 10: Basic Functionality with Computed Properties
- **Purpose:** Verify that the computed property correctly generates the full name and updates when changed.
- **Steps:**
  1. Enter "john" in the first name text field.
  2. Enter "doe" in the last name text field.
  3. Click the "Use Computed Property" button.
- **Expected Result:** 
  - The original input label displays "First Name: john" and "Last Name: doe".
  - The result label initially displays "Computed Property Result: John Doe".
  - The result label then updates to "Updated to: Jane Smith", showing that the computed property's setter updated the internal state.

#### Test Case 11: Change First Name with Computed Properties
- **Purpose:** Verify that changing the first name input affects the computed property result.
- **Steps:**
  1. Enter "mike" in the first name text field and "doe" in the last name text field.
  2. Click the "Use Computed Property" button.
- **Expected Result:**
  - The original input label displays "First Name: mike" and "Last Name: doe".
  - The result label initially displays "Computed Property Result: Mike Doe".
  - The result label then updates to "Updated to: Jane Smith".

#### Test Case 12: Change Last Name with Computed Properties
- **Purpose:** Verify that changing the last name input affects the computed property result.
- **Steps:**
  1. Enter "john" in the first name text field and "smith" in the last name text field.
  2. Click the "Use Computed Property" button.
- **Expected Result:**
  - The original input label displays "First Name: john" and "Last Name: smith".
  - The result label initially displays "Computed Property Result: John Smith".
  - The result label then updates to "Updated to: Jane Smith".

### Additional Considerations
- **Edge Cases:** Test with empty inputs or single name inputs to ensure graceful handling.
- **Performance:** Rapidly change inputs and press buttons to ensure the app remains responsive.

These test cases are designed to confirm that the application behaves as expected, demonstrating both the immediate effects and the dynamic capabilities of computed properties.


## Observations

- **Inout Parameters:** Notice how the function modifies the input strings directly, showing immediate effects.
- **Computed Properties:** Observe how the property dynamically computes values and updates internal state.

## Conclusion

These test cases provide hands-on experience with key Swift programming concepts. By following the outlined steps, you'll gain a deeper understanding of how `inout` parameters and computed properties operate within Swift applications.

## Participate and Share

We invite you to join the **Discussions** section of our GitHub repository. Share your opinions, ideas, and insights on these topics, and engage with other developers. Your participation helps us all learn and grow together!

## Feedback

We welcome your feedback! If you have any questions or suggestions, feel free to reach out or open an issue in the repository.
