//
//  StudentDetailViewModel.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/TableExampleSwiftUI

import Foundation

@Observable
class StudentDetailViewModel {
    var student: Student
    
    init(student: Student) {
        self.student = student
    }
}
