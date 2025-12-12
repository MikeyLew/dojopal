//
//  ApplyLicenseView.swift
//  DojoPal
//
//  Apply for license screen
//

import SwiftUI
import FirebaseAuth

struct ApplyLicenseView: View {
    @Environment(\.dismiss) var dismiss
    let student: Student
    @State private var firstName: String
    @State private var lastName: String
    @State private var emailAddress: String
    @State private var phone: String
    @State private var address: String
    @State private var postcode: String
    @State private var occupation: String
    @State private var birthDate: String
    @State private var clubName: String
    @State private var agreedToMembershipTerms: Bool
    @State private var agreedToPhotography: Bool
    @State private var isLoading = false
    @State private var showPaymentAlert = false
    
    // Error states
    @State private var firstNameError = ""
    @State private var lastNameError = ""
    @State private var emailError = ""
    @State private var phoneError = ""
    @State private var addressError = ""
    @State private var postcodeError = ""
    @State private var occupationError = ""
    @State private var birthDateError = ""
    @State private var clubNameError = ""
    @State private var termsError = ""
    
    init(student: Student) {
        self.student = student
        _firstName = State(initialValue: student.firstName)
        _lastName = State(initialValue: student.lastName)
        _emailAddress = State(initialValue: student.emailAddress)
        _phone = State(initialValue: student.phone)
        _address = State(initialValue: student.address)
        _postcode = State(initialValue: student.postcode)
        _occupation = State(initialValue: student.occupation)
        _birthDate = State(initialValue: student.birthDate)
        _clubName = State(initialValue: student.clubName)
        _agreedToMembershipTerms = State(initialValue: student.agreedToMembershipTerms)
        _agreedToPhotography = State(initialValue: student.agreedToPhotography)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("License Application")
                            .font(.headline)
                        Text("Please review and update the student information below. License dates will be set upon approval of this application.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Personal Information") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email Address", text: $emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Birth Date (DD/MM/YYYY)", text: $birthDate)
                    TextField("Occupation", text: $occupation)
                }
                
                Section("Address Information") {
                    TextField("Address", text: $address)
                    TextField("Postcode", text: $postcode)
                }
                
                Section("Club Information") {
                    TextField("Club Name", text: $clubName)
                }
                
                Section("Terms and Conditions") {
                    Toggle("Agreed to Membership Terms", isOn: $agreedToMembershipTerms)
                    Toggle("Agreed to Photography", isOn: $agreedToPhotography)
                }
                
                Section {
                    Button(action: submitLicenseApplication) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Submit Application")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .navigationTitle("Apply for License")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Application Submitted", isPresented: $showPaymentAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("License application has been submitted successfully!")
                    Text("")
                    Text("⚠️ Important:")
                        .fontWeight(.bold)
                    Text("Please arrange payment with your club instructor to complete the license renewal process.")
                    Text("")
                    Text("Your license status is now set to 'Pending' until payment is received and processed.")
                        .font(.caption)
                }
            }
        }
    }
    
    private func submitLicenseApplication() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        FirestoreManager.shared.fetchUser(userId: userId) { user in
            guard var user = user else {
                isLoading = false
                return
            }
            
            if let index = user.students.firstIndex(where: { $0.id == student.id }) {
                var updatedStudent = student
                updatedStudent.firstName = firstName.trimmingCharacters(in: .whitespaces)
                updatedStudent.lastName = lastName.trimmingCharacters(in: .whitespaces)
                updatedStudent.emailAddress = emailAddress.trimmingCharacters(in: .whitespaces)
                updatedStudent.phone = phone.trimmingCharacters(in: .whitespaces)
                updatedStudent.address = address.trimmingCharacters(in: .whitespaces)
                updatedStudent.postcode = postcode.trimmingCharacters(in: .whitespaces)
                updatedStudent.occupation = occupation.trimmingCharacters(in: .whitespaces)
                updatedStudent.birthDate = birthDate.trimmingCharacters(in: .whitespaces)
                updatedStudent.clubName = clubName.trimmingCharacters(in: .whitespaces)
                updatedStudent.agreedToMembershipTerms = agreedToMembershipTerms
                updatedStudent.agreedToPhotography = agreedToPhotography
                updatedStudent.licenseApplicationStatus = "pending"
                // License dates and grading history are preserved
                
                user.students[index] = updatedStudent
                
                FirestoreManager.shared.updateUser(user, userId: userId) { success in
                    isLoading = false
                    if success {
                        showPaymentAlert = true
                    }
                }
            } else {
                isLoading = false
            }
        }
    }
}
