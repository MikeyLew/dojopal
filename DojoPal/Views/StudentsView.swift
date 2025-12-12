//
//  StudentsView.swift
//  DojoPal
//
//  Student management screen
//

import SwiftUI
import FirebaseAuth

struct StudentsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var userData: User?
    @State private var isLoading = true
    @State private var showAddStudent = false
    @State private var showEditStudent: Student?
    @State private var showAddGrade: Student?
    @State private var studentToDelete: Student?
    @State private var showDeleteAlert = false
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if userData?.students.isEmpty ?? true {
                VStack(spacing: 16) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No students yet")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Tap the + button to add your first student")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                List {
                    ForEach(userData?.students ?? []) { student in
                        StudentCardView(
                            student: student,
                            onEdit: { showEditStudent = student },
                            onAddGrade: { showAddGrade = student },
                            onDelete: {
                                studentToDelete = student
                                showDeleteAlert = true
                            },
                            onApplyLicense: {
                                if !student.isLicenseApplicationPending() && student.isLicenseExpired() {
                                    showEditStudent = student // Navigate to apply license
                                }
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle("Students")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddStudent = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $showEditStudent) { student in
            if student.isLicenseExpired() && !student.isLicenseApplicationPending() {
                ApplyLicenseView(student: student)
                    .onDisappear {
                        loadUserData()
                    }
            } else {
                EditStudentView(student: student)
                    .onDisappear {
                        loadUserData()
                    }
            }
        }
        .sheet(item: $showAddGrade) { student in
            AddGradeView(student: student)
                .onDisappear {
                    loadUserData()
                }
        }
        .sheet(isPresented: $showAddStudent) {
            AddStudentView()
                .onDisappear {
                    loadUserData()
                }
        }
        .alert("Remove Student", isPresented: $showDeleteAlert, presenting: studentToDelete) { student in
            Button("Remove", role: .destructive) {
                deleteStudent(student)
            }
            Button("Cancel", role: .cancel) { }
        } message: { student in
            Text("Are you sure you want to remove \(student.fullName) from your students?")
        }
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        FirestoreManager.shared.fetchUser(userId: userId) { user in
            self.userData = user
            self.isLoading = false
        }
    }
    
    private func deleteStudent(_ student: Student) {
        guard let userId = Auth.auth().currentUser?.uid,
              var user = userData else { return }
        
        user.students.removeAll { $0.id == student.id }
        
        FirestoreManager.shared.updateUser(user, userId: userId) { success in
            if success {
                loadUserData() // Reload to get fresh data
            }
        }
    }
}

struct StudentCardView: View {
    let student: Student
    let onEdit: () -> Void
    let onAddGrade: () -> Void
    let onDelete: () -> Void
    let onApplyLicense: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(student.fullName)
                        .font(.headline)
                    
                    Text(student.emailAddress)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if !student.phone.isEmpty {
                        Text(student.phone)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let highestGrade = student.highestGrade {
                        Text("Highest Grade: \(highestGrade.grade)")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                HStack {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: onAddGrade) {
                        Image(systemName: "graduationcap")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
            // License status
            if student.isLicenseApplicationPending() {
                Button(action: {}) {
                    HStack {
                        Text("⏳ License Application Pending - Arrange payment with instructor")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                .disabled(true)
            } else if student.isLicenseExpired() {
                Button(action: onApplyLicense) {
                    HStack {
                        Text("⚠️ License Expired - Tap to Apply")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
            } else if !student.licExpDate.isEmpty {
                Text("License valid until: \(student.licExpDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !student.fullAddress.isEmpty {
                Text(student.fullAddress)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !student.occupation.isEmpty {
                Text("Occupation: \(student.occupation)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
