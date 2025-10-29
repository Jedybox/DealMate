//
//  Home.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct Home: View {
    @Binding var isLoggedIn: Bool
    @Binding var navPath: NavigationPath
    
    @State private var username: String = "Jhon"
    
    var body: some View {
            VStack {
                HStack {
                    NavigationLink(destination: ProfileSettings(isLoggedIn: $isLoggedIn)) {
                        Image("pfp")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    }

                    Text("Welcome, \(username)")
                        .font(.custom("Poppins", size: 16))
                        .foregroundStyle(Color(red:28/255, green:139/255, blue:150/255))

                    Spacer()

                    NavigationLink(destination: Chats()) {
                        Image("chatlogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                CardStack()
                    .padding()
                Spacer()

                NavigationLink(destination: MyItems()) {
                    Text("My Items")
                        .font(.custom("Montserrat", size: 20)) // ✅ check real name
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .background(Color(red: 3/255, green: 53/255, blue: 56/255))
                        .offset(y:10)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        
    
    func loadItems() {
        let endpoint = "https://dealmatebackend.vercel.app/api/auth/login"
        
        
    }

}


