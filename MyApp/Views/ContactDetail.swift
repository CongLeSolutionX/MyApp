//
//  ContactDetail.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//


import SwiftUI

struct ContactDetail: View {
    /// Indicates whether the person selected the contact from the contact access picker.
    let shouldHighlight: Bool
    let contact: Contact
    
    var body: some View {
        HStack {
            profileImage
            /*
                The formatted name of a contact. When a person selects a contact
                from the contact access picker, the app applies a yellow background
                to the contact's formatted name. Otherwise, the formatted name
                has a clear background.
            */
            Text(contact.fullName)
                .background(shouldHighlight ? Color.yellow : Color.clear)
        }
    }
    
    @ViewBuilder
    private var profileImage: some View {
        if let thumbnail = contact.thumbNail {
            if let image = UIImage(data: thumbnail) {
                ThumbnailImage(image: image)
            }
        } else {
            InitialsView(contact: contact)
        }
    }
}

#Preview("Highlighted") {
    ContactDetail(shouldHighlight: true, contact: Contact.sample)
}

#Preview("No Highlight") {
    ContactDetail(shouldHighlight: false, contact: Contact.sample)
}
