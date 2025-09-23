//
//  Chats.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct Chats: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                TopBar(page_name: "Chats")
                
                Spacer()
                Text("No chats yet")
                    .font(.custom("Poppins", size: 16))
                    .foregroundStyle(Color(red:28/255, green:139/255, blue:150/255))
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    Chats()
}
