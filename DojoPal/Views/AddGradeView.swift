//
//  AddGradeView.swift
//  DojoPal
//
//  Add grade screen with grade selection
//

import SwiftUI
import FirebaseAuth

struct AddGradeView: View {
    @Environment(\.dismiss) var dismiss
    let student: Student
    @State private var datePassed = ""
    @State private var examiner = ""
    @State private var selectedGrade = ""
    @State private var gradeId = ""
    @State private var isLoading = false
    
    @State private var datePassedError = ""
    @State private var examinerError = ""
    @State private var gradeError = ""
    @State private var gradeIdError = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Grade Details") {
                    TextField("Date Passed (DD/MM/YYYY)", text: $datePassed)
                        .placeholder(when: datePassed.isEmpty) {
                            Text("e.g., 15/03/2024").foregroundColor(.gray)
                        }
                        .onChange(of: datePassed) { _ in validateDatePassed() }
                    if !datePassedError.isEmpty {
                        Text(datePassedError).foregroundColor(.red).font(.caption)
                    }
                    
                    TextField("Examiner", text: $examiner)
                        .onChange(of: examiner) { _ in validateExaminer() }
                    if !examinerError.isEmpty {
                        Text(examinerError).foregroundColor(.red).font(.caption)
                    }
                    
                    Picker("Grade", selection: $selectedGrade) {
                        Text("Select Grade").tag("")
                        ForEach(Grade.allGrades, id: \.self) { grade in
                            Text(grade).tag(grade)
                        }
                    }
                    .onChange(of: selectedGrade) { _ in validateGrade() }
                    if !gradeError.isEmpty {
                        Text(gradeError).foregroundColor(.red).font(.caption)
                    }
                    
                    TextField("Grade ID", text: $gradeId)
                        .placeholder(when: gradeId.isEmpty) {
                            Text("e.g., GRD-2024-001").foregroundColor(.gray)
                        }
                        .onChange(of: gradeId) { _ in validateGradeId() }
                    if !gradeIdError.isEmpty {
                        Text(gradeIdError).foregroundColor(.red).font(.caption)
                    }
                }
                
                Section {
                    Button(action: addGrade) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Add Grade")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isLoading || !isFormValid)
                }
            }
            .navigationTitle("Add Grade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        datePassedError.isEmpty && examinerError.isEmpty && gradeError.isEmpty &&
        gradeIdError.isEmpty && !datePassed.isEmpty && !examiner.isEmpty &&
        !selectedGrade.isEmpty && !gradeId.isEmpty
    }
    
    private func validateDatePassed() {
        let dateRegex = "^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/(19|20)\\d{2}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", dateRegex)
        if datePassed.isEmpty {
            datePassedError = "Date passed is required"
        } else if !predicate.evaluate(with: datePassed) {
            datePassedError = "Please enter date in DD/MM/YYYY format"
        } else {
            datePassedError = ""
        }
    }
    
    private func validateExaminer() {
        examinerError = examiner.isEmpty ? "Examiner name is required" : ""
    }
    
    private func validateGrade() {
        gradeError = selectedGrade.isEmpty ? "Grade is required" : ""
    }
    
    private func validateGradeId() {
        gradeIdError = gradeId.isEmpty ? "Grade ID is required" : ""
    }
    
    private func addGrade() {
        guard isFormValid, let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        FirestoreManager.shared.fetchUser(userId: userId) { user in
            guard var user = user else {
                isLoading = false
                return
            }
            
            if let index = user.students.firstIndex(where: { $0.id == student.id }) {
                let newGrade = Grade(
                    datePassed: datePassed.trimmingCharacters(in: .whitespaces),
                    examiner: examiner.trimmingCharacters(in: .whitespaces),
                    grade: selectedGrade.trimmingCharacters(in: .whitespaces),
                    gradeId: gradeId.trimmingCharacters(in: .whitespaces)
                )
                
                user.students[index].gradingHistory.append(newGrade)
                
                FirestoreManager.shared.updateUser(user, userId: userId) { success in
                    isLoading = false
                    if success {
                        dismiss()
                    }
                }
            } else {
                isLoading = false
            }
        }
    }
}
