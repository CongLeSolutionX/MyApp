//
//  StudentRepository.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/TableExampleSwiftUI

import SwiftUI

class StudentRepository {
    
    init(){
    }
    
    func getStudents() async -> Result<Students, Error> {
        var students: Students = Students(students: [])
        
        do {
            students = try await JSONHelper
                .readJSONFromFile(
                    fileName: JSONHelper.templateName,
                    type: Students.self)
            return Result.success(students)
        } catch {
            return Result.failure(error)
        }
    }
}
