//
//  ProfileSettings.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct ProfileSettings: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Top bar
            HStack {
                Button(action: {
                    // go back
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(red: 28/255, green: 139/255, blue: 150/255))
                }
                
                Text("My Items")
                    .font(.custom("Poppins-Bold", size: 20))
                    .foregroundColor(Color(red: 28/255, green: 139/255, blue: 150/255))
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Spacer()
            
        }
    }
}

#Preview {
    ProfileSettings()
}
