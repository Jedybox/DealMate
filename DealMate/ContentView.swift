//
//  ContentView.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var username: String = ""
    @State private var pass: String = ""
    
    var body: some View {
        NavigationStack {
            VStack{
                Spacer()
                Text("DealMate")
                    .fontWeight(.bold)
                    .font(.custom("Poppins", size: 42))
                    .foregroundColor(Color(red:28/255, green:139/255, blue:150/255))
                Spacer()
                
                TField(placeHolder: "Username or Email", val: $username)
                PField(placeHolder: "Enter password", val: $pass)
                
                Spacer()
                NavigationLink(destination: Home()) {
                    Text("Login")
                        .padding(10)
                        .font(.custom("Poppins", size: 22))
                        .frame(maxWidth: 300)
                        .foregroundColor(.white)
                        .background(Color(red:3/255, green:53/255, blue:56/255))
                }
                .cornerRadius(12)
                .padding()
                NavigationLink(destination: Signup()) {
                    Text("Sign-Up")
                        .font(.custom("Poppins", size: 16))
                        .foregroundColor(Color(red:3/255, green:53/255, blue:56/255))
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
