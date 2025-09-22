//
//  TField.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct TField: View {
    var placeHolder: String
    @Binding var val: String
    
    var body: some View {
        TextField(placeHolder, text: $val)
            .multilineTextAlignment(.center)
            .padding() // inner padding
            .frame(maxWidth: 300, maxHeight: 50) // size
            .cornerRadius(12) // rounded corners
            .overlay( // border
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red:3/255, green:53/255, blue:54/255),
                            lineWidth: 1)
            )
    }
}
