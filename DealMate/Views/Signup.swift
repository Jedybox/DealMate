//
//  Signup.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct Signup: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var code: String = ""
    @State private var username: String = ""
    @State private var pass: String = ""
    @State private var re_pass: String = ""
    @State private var count: Int = 1
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("DealMate")
                    .fontWeight(.bold)
                    .font(.custom("Poppins", size: 32))
                    .foregroundStyle(Color(red:28/255, green:139/255, blue:150/255))
                    .offset(x:-60)
                Spacer()
                
                if count == 1 {
                    Spacer()
                    ZStack {
                        TField(placeHolder: "Email", val: $email)
                    }.padding(.vertical)
                    Spacer()
                } else if count == 2 {
                    Spacer()
                    ZStack {
                        Text("Please check your email, we sent a code")
                            .foregroundColor(.black)
                            .offset(y: -40)
                        TField(placeHolder: "Code", val: $code)
                    }.padding(.vertical)
                    Spacer()
                } else if count == 3 {
                    TField(placeHolder: "Enter username", val: $username)
                    PField(placeHolder: "Password", val: $pass)
                    PField(placeHolder: "Code", val: $re_pass)
                }
                
                Spacer()
                Button(action:{
                    if count >= 3 {
                        dismiss()
                    } else {
                        count+=1
                    }
                }){
                    Text("Send Code")
                        .padding(10)
                        .font(.title2)
                        .frame(maxWidth: 300)
                        .foregroundStyle(.white)
                        .background(Color(red:3/255, green:53/255, blue:56/255))
                }
                .cornerRadius(12)
                .padding()
                Spacer()
                
            }.background(Color(red:254/255, green:254/255, blue: 254))
        }.navigationBarBackButtonHidden(true)
    }
    
}

#Preview {
    Signup()
}
