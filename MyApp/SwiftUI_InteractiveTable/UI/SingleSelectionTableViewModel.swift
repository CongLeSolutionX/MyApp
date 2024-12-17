//
//  SingleSelectionTableViewModel.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//


import Foundation

@Observable
class SingleSelectionTableViewModel {
    var students: [Student] = []
    
    var selectedStudent: Student.ID?
    
    private let studentRepository: StudentRepository
    
    init() {
        studentRepository = StudentRepository()
    }
    
    func fetchStudents() async {
        
        let result = await studentRepository.getStudents()
        switch result {
        case .success(let students):
            self.students = students.students
        case .failure(let error):
            print("Error: \(error)")
        }
    }
}
