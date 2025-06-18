//
//  LoginView1.swift
//  DriveQuest
//
//  Created by Aarin Karamchandani on 6/17/25.
//


import SwiftUI

struct LoginView1: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var userType: String = ""
    @State private var isLoading: Bool = false
    @State private var showPassword: Bool = false
    @State private var showForgotPasswordForm: Bool = false
    @State private var forgotEmail: String = ""
    @State private var linkSent: Bool = false
    @State private var showSignUpForm: Bool = false
    @State private var signUpName: String = ""
    @State private var signUpEmail: String = ""
    @State private var signUpPassword: String = ""
    @State private var signUpComplete: Bool = false
    
    // Define deep blue color from the color scheme
    private let deepBlue = Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1))
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 16) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .padding(.top, 40)
                        
                        Text("Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Sign in to continue to DriveQuest")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 40)
                    
                    // Login Form
                    VStack(spacing: 20) {
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 20)
                                
                                TextField("Enter your username", text: $username)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(username.isEmpty ? Color.clear : Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 20)
                                
                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                        .foregroundColor(.white)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(password.isEmpty ? Color.clear : Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Login Button
                        Button(action: authenticate) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Text("Sign In")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                        .disabled(username.isEmpty || password.isEmpty || isLoading)
                        .opacity((username.isEmpty || password.isEmpty || isLoading) ? 0.6 : 1.0)
                        .padding(.top, 10)
                        
                        // Forgot Password Link
                        Button(action: {
                            showForgotPasswordForm = true
                        }) {
                            Text("Forgot Password?")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Don't have an account?")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Button(action: {
                            showSignUpForm = true
                        }) {
                            Text("Create Account")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
            .background(deepBlue)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Login Failed"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Try Again"))
                )
            }
            // FORGOT PASSWORD FORM
            .sheet(isPresented: $showForgotPasswordForm) {
                NavigationView {
                    VStack(spacing: 20) {
                        Text("Reset Password")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        TextField("Enter your Gmail", text: $forgotEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        
                        Button(action: {
                            linkSent = true
                        }) {
                            Text("Send Reset Link")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        if linkSent {
                            Text("Link sent to your email.")
                                .foregroundColor(.green)
                                .padding(.top, 10)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(deepBlue)
                    .navigationTitle("Reset Password")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showForgotPasswordForm = false
                                forgotEmail = ""
                                linkSent = false
                            }
                            .foregroundColor(.white)
                        }
                    }
                }
            }
            // SIGN UP FORM
            .sheet(isPresented: $showSignUpForm) {
                NavigationView {
                    VStack(spacing: 20) {
                        Text(signUpComplete ? "Account Created!" : "Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        if !signUpComplete {
                            TextField("Name", text: $signUpName)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                            
                            TextField("Gmail", text: $signUpEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                            
                            SecureField("Password", text: $signUpPassword)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                            
                            Button(action: {
                                signUpComplete = true
                            }) {
                                Text("Sign Up")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        } else {
                            Text("Your account has been created successfully! Please return to the login screen to sign in.")
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button("Done") {
                                showSignUpForm = false
                                signUpName = ""
                                signUpEmail = ""
                                signUpPassword = ""
                                signUpComplete = false
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(deepBlue)
                    .navigationTitle(signUpComplete ? "Success" : "Create Account")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Close") {
                                showSignUpForm = false
                                signUpName = ""
                                signUpEmail = ""
                                signUpPassword = ""
                                signUpComplete = false
                            }
                            .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $isLoggedIn) {
            destinationView()
        }
    }
    
    private func authenticate() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let teenCredentials = (username: "TeenLogin", password: "aa123")
            let parentCredentials = (username: "ParentLogin", password: "aa1234")
            
            if username == teenCredentials.username && password == teenCredentials.password {
                userType = "student"
                isLoggedIn = true
            } else if username == parentCredentials.username && password == parentCredentials.password {
                userType = "parent"
                isLoggedIn = true
            } else {
                alertMessage = "Invalid username or password. Please check your credentials and try again."
                showAlert = true
            }
            
            isLoading = false
        }
    }
    
    @ViewBuilder
    private func destinationView() -> some View {
        if userType == "student" {
            StudentDashboardView(username: username)
        } else if userType == "parent" {
            ParentMainTabView(username: username)
        } else {
            EmptyView()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView1()
    }
}
