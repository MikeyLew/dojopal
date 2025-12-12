//
//  AddStudentView.swift
//  DojoPal
//
//  Add student screen with comprehensive form
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddStudentView: View {
    @Environment(\.dismiss) var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var emailAddress = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var postcode = ""
    @State private var occupation = ""
    @State private var birthDate = ""
    @State private var licDate = ""
    @State private var licExpDate = ""
    @State private var clubName = ""
    @State private var agreedToMembershipTerms = false
    @State private var agreedToPhotography = false
    @State private var isLoading = false
    
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
    @State private var licDateError = ""
    @State private var licExpDateError = ""
    @State private var termsError = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $firstName)
                        .onChange(of: firstName) { _ in validateFirstName() }
                    if !firstNameError.isEmpty {
                        Text(firstNameError).foregroundColor(.red).font(.caption)
                    }
                    
                    TextField("Last Name", text: $lastName)
                        .onChange(of: lastName) { _ in validateLastName() }
                    if !lastNameError.isEmpty {
                        Text(lastNameError).foregroundColor(.red).font(.caption)
                    }
                    
                    TextField("Email Address", text: $emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .onChange(of: emailAddress) { _ in validateEmail() }
                    if !emailError.isEmpty {
                        Text(emailError).foregroundColor(.red).font(.caption)
                    }
                    
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                        .onChange(of: phone) { _ in validatePhone() }
                    if !phoneError.isEmpty {
                        Text(phoneError).foregroundColor(.red).font(.caption)
                    }
                    
                    TextField("Birth Date (DD/MM/YYYY)", text: $birthDate)
                        .placeholder(when: birthDate.isEmpty) {
                            Text("e.g., 15/03/1990").foregroundColor(.gray)
                        }
                        .onChange(of: birthDate) { _ in validateBirthDate() }
                    if !birthDateError.isEmpty {
                        Text(birthDateError).foregroundColor(.red).font(.caption)
                    }
                    
                    TextField("Occupation", text: $occupation)
                        .onChange(of: occupation) { _ in validateOccupation() }
                    if !occupationError.isEmpty {
                        Text(occupationError).foregroundColor(.red).font(.caption)
                    }
                }
                
                Section("Address Information") {
                    TextField("Address", text: $address)
                        .onChange(of: address) { _ in validateAddress() }
                    if !addressError.isEmpty {
                        Text(addressError).foregroundColor(.red).font(.caption)
                    }
                    
                    TextField("Postcode", text: $postcode)
                        .placeholder(when: postcode.isEmpty) {
                            Text("e.g., SW1A 1AA").foregroundColor(.gray)
                        }
                        .onChange(of: postcode) { _ in validatePostcode() }
                    if !postcodeError.isEmpty {
                        Text(postcodeError).foregroundColor(.red).font(.caption)
                    }
                }
                
                Section("Club Information") {
                    TextField("Club Name", text: $clubName)
                        .onChange(of: clubName) { _ in validateClubName() }
                    if !clubNameError.isEmpty {
                        Text(clubNameError).foregroundColor(.red).font(.caption)
                    }
                    
                    TextField("License Date (DD/MM/YYYY)", text: $licDate)
                        .placeholder(when: licDate.isEmpty) {
                            Text("e.g., 01/01/2023").foregroundColor(.gray)
                        }
                        .onChange(of: licDate) { _ in validateLicDate() }
                    if !licDateError.isEmpty {
                        Text(licDateError).foregroundColor(.red).font(.caption)
                    }
                    
                    TextField("License Expiry Date (DD/MM/YYYY)", text: $licExpDate)
                        .placeholder(when: licExpDate.isEmpty) {
                            Text("e.g., 01/01/2024").foregroundColor(.gray)
                        }
                        .onChange(of: licExpDate) { _ in validateLicExpDate() }
                    if !licExpDateError.isEmpty {
                        Text(licExpDateError).foregroundColor(.red).font(.caption)
                    }
                }
                
                Section("Terms and Conditions") {
                    Toggle("Agreed to Membership Terms", isOn: $agreedToMembershipTerms)
                    if !termsError.isEmpty {
                        Text(termsError).foregroundColor(.red).font(.caption)
                    }
                    
                    Toggle("Agreed to Photography", isOn: $agreedToPhotography)
                }
                
                Section {
                    Button(action: addStudent) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Add Student")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isLoading || !isFormValid)
                }
            }
            .navigationTitle("Add Student")
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
        firstNameError.isEmpty && lastNameError.isEmpty && emailError.isEmpty &&
        phoneError.isEmpty && addressError.isEmpty && postcodeError.isEmpty &&
        occupationError.isEmpty && birthDateError.isEmpty && clubNameError.isEmpty &&
        agreedToMembershipTerms
    }
    
    private func validateFirstName() {
        firstNameError = firstName.isEmpty ? "First name is required" : ""
    }
    
    private func validateLastName() {
        lastNameError = lastName.isEmpty ? "Last name is required" : ""
    }
    
    private func validateEmail() {
        let emailRegex = "^[A-Za-z0-9+_.-]+@([A-Za-z0-9.-]+\\.[A-Za-z]{2,})$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if emailAddress.isEmpty {
            emailError = "Email is required"
        } else if !predicate.evaluate(with: emailAddress) {
            emailError = "Please enter a valid email address"
        } else {
            emailError = ""
        }
    }
    
    private func validatePhone() {
        let cleanPhone = phone.replacingOccurrences(of: "[\\s\\-\\(\\)]", with: "", options: .regularExpression)
        if phone.isEmpty {
            phoneError = "Phone number is required"
        } else if !cleanPhone.allSatisfy({ $0.isNumber }) || cleanPhone.count < 10 || cleanPhone.count > 15 {
            phoneError = "Please enter a valid phone number (10-15 digits)"
        } else {
            phoneError = ""
        }
    }
    
    private func validateAddress() {
        addressError = address.isEmpty ? "Address is required" : ""
    }
    
    private func validatePostcode() {
        let postcodeRegex = "^[A-Z]{1,2}[0-9R][0-9A-Z]? [0-9][A-Z]{2}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", postcodeRegex)
        if postcode.isEmpty {
            postcodeError = "Postcode is required"
        } else if !predicate.evaluate(with: postcode) {
            postcodeError = "Please enter a valid UK postcode (e.g., SW1A 1AA)"
        } else {
            postcodeError = ""
        }
    }
    
    private func validateOccupation() {
        occupationError = occupation.isEmpty ? "Occupation is required" : ""
    }
    
    private func validateBirthDate() {
        let dateRegex = "^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/(19|20)\\d{2}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", dateRegex)
        if birthDate.isEmpty {
            birthDateError = "Birth date is required"
        } else if !predicate.evaluate(with: birthDate) {
            birthDateError = "Please enter date in DD/MM/YYYY format"
        } else {
            birthDateError = ""
        }
    }
    
    private func validateClubName() {
        clubNameError = clubName.isEmpty ? "Club name is required" : ""
    }
    
    private func validateLicDate() {
        if licDate.isEmpty { return }
        let dateRegex = "^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/(19|20)\\d{2}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", dateRegex)
        licDateError = predicate.evaluate(with: licDate) ? "" : "Please enter date in DD/MM/YYYY format"
    }
    
    private func validateLicExpDate() {
        if licExpDate.isEmpty { return }
        let dateRegex = "^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/(19|20)\\d{2}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", dateRegex)
        licExpDateError = predicate.evaluate(with: licExpDate) ? "" : "Please enter date in DD/MM/YYYY format"
    }
    
    private func addStudent() {
        guard isFormValid, let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        FirestoreManager.shared.fetchUser(userId: userId) { user in
            guard var user = user else {
                isLoading = false
                return
            }
            
            let newStudent = Student(
                address: address.trimmingCharacters(in: .whitespaces),
                agreedToMembershipTerms: agreedToMembershipTerms,
                agreedToPhotography: agreedToPhotography,
                birthDate: birthDate.trimmingCharacters(in: .whitespaces),
                clubName: clubName.trimmingCharacters(in: .whitespaces),
                emailAddress: emailAddress.trimmingCharacters(in: .whitespaces),
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                licDate: licDate.trimmingCharacters(in: .whitespaces),
                licExpDate: licExpDate.trimmingCharacters(in: .whitespaces),
                occupation: occupation.trimmingCharacters(in: .whitespaces),
                phone: phone.trimmingCharacters(in: .whitespaces),
                postcode: postcode.trimmingCharacters(in: .whitespaces)
            )
            
            user.students.append(newStudent)
            
            FirestoreManager.shared.updateUser(user, userId: userId) { success in
                isLoading = false
                if success {
                    dismiss()
                }
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
