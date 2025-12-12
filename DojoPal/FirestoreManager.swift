//
//  FirestoreManager.swift
//  DojoPal
//
//  Manages Firestore operations
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchUser(userId: String, completion: @escaping (User?) -> Void) {
        db.collection("accounts").document(userId).getDocument { [self] document, error in
            if let error = error {
                print("Error fetching user: \(error)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                completion(nil)
                return
            }
            
            do {
                var user = try Firestore.Decoder().decode(User.self, from: data)
                user.id = document.documentID
                // Decode students array
                if let studentsData = data["students"] as? [[String: Any]] {
                    user.students = try studentsData.map { studentData in
                        try decodeStudent(from: studentData)
                    }
                }
                completion(user)
            } catch {
                print("Error decoding user: \(error)")
                completion(nil)
            }
        }
    }
    
    func saveUser(_ user: User, userId: String, completion: @escaping (Bool) -> Void) {
        var data: [String: Any] = [:]
        data["firstName"] = user.firstName
        data["lastName"] = user.lastName
        data["emailAddress"] = user.emailAddress
        data["clubName"] = user.clubName
        data["approved"] = user.approved
        data["createdAt"] = user.createdAt
        data["updatedAt"] = Timestamp()
        
        // Encode students array
        do {
            let studentsData = try user.students.map { student in
                try encodeStudent(student)
            }
            data["students"] = studentsData
        } catch {
            print("Error encoding students: \(error)")
        }
        
        db.collection("accounts").document(userId).setData(data) { error in
            completion(error == nil)
        }
    }
    
    func updateUser(_ user: User, userId: String, completion: @escaping (Bool) -> Void) {
        var data: [String: Any] = [:]
        data["firstName"] = user.firstName
        data["lastName"] = user.lastName
        data["emailAddress"] = user.emailAddress
        data["clubName"] = user.clubName
        data["approved"] = user.approved
        data["updatedAt"] = Timestamp()
        
        // Encode students array
        do {
            let studentsData = try user.students.map { student in
                try encodeStudent(student)
            }
            data["students"] = studentsData
        } catch {
            print("Error encoding students: \(error)")
        }
        
        db.collection("accounts").document(userId).setData(data, merge: false) { error in
            completion(error == nil)
        }
    }
    
    private func encodeStudent(_ student: Student) throws -> [String: Any] {
        var data: [String: Any] = [:]
        data["address"] = student.address
        data["agreedToMembershipTerms"] = student.agreedToMembershipTerms
        data["agreedToPhotography"] = student.agreedToPhotography
        data["birthDate"] = student.birthDate
        data["clubName"] = student.clubName
        data["dateJoined"] = student.dateJoined
        data["emailAddress"] = student.emailAddress
        data["firstName"] = student.firstName
        data["lastName"] = student.lastName
        data["licDate"] = student.licDate
        data["licExpDate"] = student.licExpDate
        data["occupation"] = student.occupation
        data["phone"] = student.phone
        data["postcode"] = student.postcode
        data["licenseApplicationStatus"] = student.licenseApplicationStatus as Any
        
        // Encode grading history
        data["gradingHistory"] = try student.gradingHistory.map { grade in
            try encodeGrade(grade)
        }
        
        return data
    }
    
    private func encodeGrade(_ grade: Grade) throws -> [String: Any] {
        var data: [String: Any] = [:]
        data["datePassed"] = grade.datePassed
        data["examiner"] = grade.examiner
        data["grade"] = grade.grade
        data["gradeId"] = grade.gradeId
        data["createdAt"] = grade.createdAt
        return data
    }
    
    private func decodeStudent(from data: [String: Any]) throws -> Student {
        var student = Student()
        student.address = data["address"] as? String ?? ""
        student.agreedToMembershipTerms = data["agreedToMembershipTerms"] as? Bool ?? false
        student.agreedToPhotography = data["agreedToPhotography"] as? Bool ?? false
        student.birthDate = data["birthDate"] as? String ?? ""
        student.clubName = data["clubName"] as? String ?? ""
        student.dateJoined = data["dateJoined"] as? Timestamp ?? Timestamp()
        student.emailAddress = data["emailAddress"] as? String ?? ""
        student.firstName = data["firstName"] as? String ?? ""
        student.lastName = data["lastName"] as? String ?? ""
        student.licDate = data["licDate"] as? String ?? ""
        student.licExpDate = data["licExpDate"] as? String ?? ""
        student.occupation = data["occupation"] as? String ?? ""
        student.phone = data["phone"] as? String ?? ""
        student.postcode = data["postcode"] as? String ?? ""
        student.licenseApplicationStatus = data["licenseApplicationStatus"] as? String
        
        // Decode grading history
        if let gradesData = data["gradingHistory"] as? [[String: Any]] {
            student.gradingHistory = try gradesData.map { gradeData in
                try decodeGrade(from: gradeData)
            }
        }
        
        return student
    }
    
    private func decodeGrade(from data: [String: Any]) throws -> Grade {
        var grade = Grade()
        grade.datePassed = data["datePassed"] as? String ?? ""
        grade.examiner = data["examiner"] as? String ?? ""
        grade.grade = data["grade"] as? String ?? ""
        grade.gradeId = data["gradeId"] as? String ?? ""
        grade.createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
        return grade
    }
}
