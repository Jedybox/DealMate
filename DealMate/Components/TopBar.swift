//
//  TopBar.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/23/25.
//

import SwiftUI

struct TopBar: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var page_name: String
    
    var body: some View {
        HStack {
            Button(action: {dismiss()}) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color(red: 28/255, green: 139/255, blue: 150/255))
            }
            
            Text(page_name)
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundStyle(Color(red: 28/255, green: 139/255, blue: 150/255))
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
}
