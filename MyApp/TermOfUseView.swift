//
//  TermOfUseView.swift
//  MyApp
//
//  Created by Cong Le on 4/7/25.
//

import SwiftUI

// Model for each term item
struct TermItem: Identifiable {
    let id = UUID()
    let heading: String
    let body: String
}

// Data Source (Populated with the text from the screenshot)
// Note: The full text is quite long, so this is truncated for brevity.
// In a real app, this might come from a file or API.
let termsData: [TermItem] = [
    TermItem(heading: "Adding Your Chase Card.",
             body: "You can add an eligible Chase Card to a Wallet by either following our instructions as they appear on a Chase proprietary platform (e.g., Chase Mobile® app or chase.com) or by following the instructions of the Wallet provider. Only Chase Cards that we determine are eligible can be added to the Wallet. If your Chase Card or underlying account is not in good standing, that Chase Card will not be eligible to be added to or enrolled in the Wallet. We may determine other eligibility criteria in our sole discretion. When you add a Chase Card to a Wallet, the Wallet may allow you to (a) use the Chase Card to (i) enable transfers of money between you and others who are enrolled with the Wallet provider or a partner of such Wallet provider, and/or (ii) enter into transactions where the Wallet is accepted, including the ability to use the Chase Card to complete transactions at participating merchants' physical locations, e-commerce locations, and at ATMs; and (b) use other services that are described in the Wallet provider's agreement or that they may offer from time to time. The Wallet may not be accepted at all places where your Chase Card is accepted. We reserve the right to terminate our participation in a Wallet or with a Wallet provider at any time and the right to designate a maximum number of Chase Cards that may be added to a Wallet."),
    TermItem(heading: "Your Chase Card Terms Do Not Change.",
             body: "The terms and agreement that govern your Chase Card do not change when you add your Chase Card to the Wallet. The applicable CardMember Agreement or account agreement that governs the Chase Card, as amended from time to time, are incorporated by reference as part of these Terms. Please review those agreements, as applicable, for important information on your rights and responsibilities when making transactions through a Wallet. The Wallet simply provides another way for you to make purchases or other transactions with the Chase Card."),
    TermItem(heading: "Applicable Fees.",
             body: "Any applicable interest, fees, and charges that apply to your Chase Card or underlying account will also apply when you use a Wallet to access your Chase Card. Chase does not charge you any additional fees for adding your Chase Card to the Wallet or using your Chase Card in the Wallet. The Wallet provider and other third parties such as wireless companies or data service providers may charge you fees. You are solely responsible for reporting and paying any applicable taxes arising from transactions originated using your Chase Card information transmitted by a Wallet and you shall comply with any and all applicable tax laws in connection therewith"),
    TermItem(heading: "Chase Is Not Responsible for the Wallet.",
             body: "Chase is not the provider of the Wallet, and we are not responsible for providing the Wallet service to you. We are only responsible for supplying information securely to the Wallet provider to allow usage of the Chase Card in the Wallet. We are not responsible for any failure of the Wallet, for any errors, delays caused by or the inability to use the Wallet for any transaction. We are not responsible for the performance or non-performance of the Wallet provider or any other third parties regarding any agreement you enter into with the Wallet provider or associated third-party relationships that may impact your use of the Wallet."),
    TermItem(heading: "Transaction History.",
             body: "You agree and acknowledge that the transaction history displayed in the Wallet solely represents our authorization of your Wallet transaction and may not reflect complete information about the transaction, nor any post-authorization activity, including but not limited to clearing, settlement, foreign currency exchange, reversals, returns or chargebacks. Accordingly, the purchase amount, currency, and other details for the Wallet provider's transaction history in connection with use of your Card in the Wallet may be preliminary and/or incomplete, and may not match the transaction amount that ultimately clears, settles, and posts to your Card's billing or monthly statement, which shall be deemed the prevailing document."),
    TermItem(heading: "Contacting You Electronically and by Email or through Your Mobile Device.",
              body: "You consent to receive electronic communications and disclosures from us in connection with your Chase Card and the Wallet. You agree that we can contact you by email at any email address you provide to us in connection with any Chase product, service or account, or through the mobile device on which you have downloaded the Chase Mobile app. It may include contact from companies working on our behalf to service your accounts. You agree to update your contact information with us when it changes."),
    TermItem(heading: "Removing Your Chase Card from the Wallet.",
             body: "You should contact the Wallet provider on how to remove a Chase Card from the Wallet. We can also block a Chase Card in the Wallet from certain transactions or purchases at any time."),
    TermItem(heading: "Governing Law and Disputes.",
             body: "These Terms are governed by federal law and, to the extent that state law applies, the laws of the state that apply to the agreement under which your Chase Card is covered. Disputes arising out of or relating to these Terms will be subject to any dispute resolution procedures in your Chase Card agreement."),
    TermItem(heading: "Ending or Changing these Terms; Assignments.",
              body: "We can terminate these Terms at any time. We can also change these Terms, or add or delete any items in these Terms, at any time. Your use of a Chase Card in a Wallet after we have made such changes available will be considered your agreement to the changes. We will provide notice if required by law. We can also assign these Terms. Furthermore, subject to applicable law, at any time we may (i) terminate your use of any Chase Card in connection with a Wallet, (ii) modify or suspend the type or dollar amounts of transactions allowed using Chase Cards in connection with a Wallet, (iii) change a Chase Card's eligibility for use with a Wallet and/or (iv) change the Chase Card authentication process. You cannot change these terms, but you can terminate these Terms at any time by removing all Chase Cards from the Wallet. You may not assign these Terms."),
    TermItem(heading: "Privacy.",
             body: "Your privacy and the security of your information are important to us. Our Online Privacy Policy and, where appropriate, our U.S. Consumer Privacy Notice (available online at: https://www.chase.com/), as amended from time to time, applies to your use of your Chase Card in the Wallet. You may be provided with the ability to share your Chase Card number with Wallet providers or a payment network, and you agree that we may share certain of your other information with the Wallet providers, merchants, a payment network, and others in order to provide the services you have requested, to make information available to you about your Chase Card transactions, and to improve our ability to offer these services. This information helps us to add your Chase Card to the Wallet and to maintain the Wallet. We do not control the privacy and security of your information that may be held by the Wallet provider and that is governed by the privacy policy given to you by the Wallet provider."),
    TermItem(heading: "Notices.",
             body: "We can provide notices to you concerning these Terms and your use of a Chase Card in the Wallet by posting the material on our website, through electronic notice given to any electronic mailbox we maintain for you or to any other email address or telephone number you provide to us, or by contacting you at the current address we have on file for you. You may contact us at: 1-888-364-7250."),
    TermItem(heading: "Limitation of Liability; No Warranties.",
              body: "WE ARE NOT AND SHALL NOT BE LIABLE FOR ANY LOSS, DAMAGE OR INJURY OR FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING FROM OR RELATED TO YOUR ADDING A CHASE CARD TO A WALLET, OR YOUR ACCESS OR USE OF A WALLET. TO THE FULLEST EXTENT PERMITTED BY LAW, WE DISCLAIM ALL REPRESENTATIONS, WARRANTIES AND CONDITIONS OF ANY KIND (EXPRESS, IMPLIED, STATUTORY OR OTHERWISE, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT OF PROPRIETARY RIGHTS) AS TO ANY AND ALL WALLETS AND ALL INFORMATION, PRODUCTS AND OTHER CONTENT INCLUDED IN OR ACCESSIBLE FROM THE WALLETS."),
    TermItem(heading: "Questions.",
             body: "If you have any questions, disputes, or complaints about the Wallet, contact the Wallet provider using the information given to you by the provider. If your question, dispute, or complaint is about your Chase Card, then contact us at: 1-888-364-7250. Esta página contiene información acerca del uso de su tarjeta Chase Visa® en billeteras digitales. Si tiene alguna pregunta, por favor, llame al número que aparece en el reverso de su tarjeta.")
]

// SwiftUI View
struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) { // Add spacing between elements

                // --- Title ---
                Text("Terms for Adding Your Chase Card to a Third Party Digital Wallet")
                    .font(.title2) // Slightly smaller than largeTitle, more typical for in-view titles
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10) // Space below title
                    .frame(maxWidth: .infinity) // Ensure it centers correctly

                // --- Introductory Paragraph ---
                Text("These Terms for Adding Your Chase Card to a Third Party Digital Wallet (the \"Terms\") apply when you choose to add a Chase credit card, prepaid card or debit card (\"Chase Card\") to a digital wallet or other payment service managed or owned by a third party (\"Wallet\"). In these Terms, \"you\" and \"your\" refer to the cardholder of the Chase Card, and \"we,\" \"us,\" \"our,\" and \"Chase\" refer to the issuer of your Chase Card, JPMorgan Chase Bank, N.A.")
                    .font(.body)

                Text("When you add a Chase Card to a Wallet, you agree to these Terms:")
                    .font(.body)
                    .padding(.top, 5) // Slight space before the list starts

                // --- Numbered List ---
                ForEach(termsData.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 5) { // Spacing within a list item
                        // Heading (Number + Bold Text)
                        // Using Markdown for easy bolding
                        Text("**\(index + 1). \(termsData[index].heading)**")
                            .font(.body) // Headings seem same size as body, just bold

                        // Body Text
                        Text(termsData[index].body)
                            .font(.body)
                    }
                    .padding(.bottom, 10) // Space between list items
                }

                // --- Footer ---
                 // Add divider for visual separation if desired
                 Divider().padding(.vertical, 10)

                 Text("Credit and debit card products are provided by JPMorgan Chase Bank, N.A. Member FDIC")
                     .font(.footnote) // Smaller font for footer
                     .foregroundColor(.secondary) // Often slightly greyed out
                     .multilineTextAlignment(.center)
                     .frame(maxWidth: .infinity)


            }
            .padding() // Add overall padding around the VStack content
        }
        // Optional: Add a Navigation Bar Title if used within a NavigationView
        // .navigationTitle("Terms and Conditions")
        // .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview Provider
struct TermsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsView()
    }
}
