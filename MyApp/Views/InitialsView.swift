//
//  InitialsView.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//


import SwiftUI

struct InitialsView: View {
    let contact: Contact
    
    var body: some View {
        Text(contact.initials)
            .frame(width: 40, height: 40)
            .background(Color.gray)
            .clipShape(Circle())
    }
}

#Preview {
    InitialsView(contact: Contact.sample)
}
