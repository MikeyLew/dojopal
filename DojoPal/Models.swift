//
//  Models.swift
//  DojoPal
//
//  Data models for User, Student, and Grade
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    var id: String?
    var firstName: String = ""
    var lastName: String = ""
    var emailAddress: String = ""
    var clubName: String = ""
    var approved: Bool = false
    var students: [Student] = []
    var createdAt: Timestamp = Timestamp()
    var updatedAt: Timestamp = Timestamp()
    
    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
}

struct Student: Codable, Identifiable, Hashable {
    var id = UUID()
    
    enum CodingKeys: String, CodingKey {
        case address, agreedToMembershipTerms, agreedToPhotography, birthDate
        case clubName, dateJoined, emailAddress, firstName, lastName
        case licDate, licExpDate, occupation, phone, postcode
        case gradingHistory, licenseApplicationStatus
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Student, rhs: Student) -> Bool {
        lhs.id == rhs.id
    }
    var address: String = ""
    var agreedToMembershipTerms: Bool = false
    var agreedToPhotography: Bool = false
    var birthDate: String = ""
    var clubName: String = ""
    var dateJoined: Timestamp = Timestamp()
    var emailAddress: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var licDate: String = ""
    var licExpDate: String = ""
    var occupation: String = ""
    var phone: String = ""
    var postcode: String = ""
    var gradingHistory: [Grade] = []
    var licenseApplicationStatus: String? = nil
    
    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    var fullAddress: String {
        return "\(address), \(postcode)".trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: ","))
    }
    
    var highestGrade: Grade? {
        return gradingHistory.max(by: { $0.gradeOrder < $1.gradeOrder })
    }
    
    func isLicenseExpired() -> Bool {
        guard !licExpDate.isEmpty else { return false }
        
        let parts = licExpDate.split(separator: "/")
        guard parts.count == 3,
              let day = Int(parts[0]),
              let month = Int(parts[1]),
              let year = Int(parts[2]) else {
            return false
        }
        
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        
        if year < currentYear { return true }
        if year == currentYear && month < currentMonth { return true }
        if year == currentYear && month == currentMonth { return true }
        
        return false
    }
    
    func isLicenseApplicationPending() -> Bool {
        return licenseApplicationStatus == "pending"
    }
}

struct Grade: Codable, Identifiable, Hashable {
    var id = UUID()
    var datePassed: String = ""
    var examiner: String = ""
    var grade: String = ""
    var gradeId: String = ""
    var createdAt: Timestamp = Timestamp()
    
    var gradeOrder: Int {
        switch grade {
        case "10th Kyu": return 1
        case "9th Kyu": return 2
        case "8th Kyu": return 3
        case "7th Kyu": return 4
        case "6th Kyu": return 5
        case "5th Kyu": return 6
        case "4th Kyu": return 7
        case "3rd Kyu": return 8
        case "2nd Kyu": return 9
        case "1st Kyu": return 10
        case "1st Dan": return 11
        case "2nd Dan": return 12
        case "3rd Dan": return 13
        case "4th Dan": return 14
        case "5th Dan": return 15
        case "6th Dan": return 16
        case "7th Dan": return 17
        case "8th Dan": return 18
        case "9th Dan": return 19
        case "10th Dan": return 20
        default: return 0
        }
    }
    
    static let allGrades = [
        "10th Kyu", "9th Kyu", "8th Kyu", "7th Kyu", "6th Kyu",
        "5th Kyu", "4th Kyu", "3rd Kyu", "2nd Kyu", "1st Kyu",
        "1st Dan", "2nd Dan", "3rd Dan", "4th Dan", "5th Dan",
        "6th Dan", "7th Dan", "8th Dan", "9th Dan", "10th Dan"
    ]
}
