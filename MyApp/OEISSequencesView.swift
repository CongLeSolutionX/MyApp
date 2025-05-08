//
//  OEISSequencesView.swift
//  MyApp

//  Created by Developer on 2024-05-06.
//

import SwiftUI

// MARK: - OEISSequence Data Model

struct OEISSequence: Codable, Identifiable {
    // Use OEIS "id" field if present, otherwise fallback to UUID (won't break Identifiable).
    var id: String { idField ?? UUID().uuidString }

    let number: Int?
    let idField: String?
    let data: String?
    let name: String?
    let reference: [String]?
    let link: [String]?
    let formula: [String]?
    let example: [String]?
    let mathematica: [String]?
    let xref: [String]?
    let keyword: String?
    let offset: String?
    let author: String?
    let ext: [String]?
    let comment: [String]?
    let references: Int?
    let revision: Int?
    let time: String?
    let created: String?

    enum CodingKeys: String, CodingKey {
        case number
        case idField = "id"
        case data, name, reference, link, formula, example, mathematica, xref, keyword, offset, author, ext, comment, references, revision, time, created
    }
}

// MARK: - ViewModel

@MainActor
class OEISViewModel: ObservableObject {
    @Published var sequences: [OEISSequence] = []
    @Published var errorMessage: String?

    func fetchSequences(for query: String) async {
        guard let url = URL(string: "https://oeis.org/search?q=\(query)&fmt=json") else {
            errorMessage = "Invalid URL"
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([OEISSequence].self, from: data)
            self.sequences = decoded
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            self.sequences = []
        }
    }
}

// MARK: - Main SwiftUI View

struct OEISSequencesView: View {
    @StateObject private var viewModel = OEISViewModel()
    @State private var query = "A001011"

    var body: some View {
        NavigationView {
            VStack {
                searchBar
                if let error = viewModel.errorMessage {
                    Text("Error: \(error)").foregroundColor(.red)
                }
                List(viewModel.sequences, id: \.id) { sequence in
                    SequenceCell(sequence: sequence)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 6)
                }
            }
            .navigationTitle("OEIS Sequences")
        }
        .task {
            await viewModel.fetchSequences(for: query)
        }
    }

    private var searchBar: some View {
        HStack {
            TextField("OEIS Query", text: $query)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .autocapitalization(.none)
            Button("Fetch") {
                Task { await viewModel.fetchSequences(for: query) }
            }
        }
        .padding([.horizontal, .top])
    }
}

// MARK: - Row Cell Rendering

struct SequenceCell: View {
    let sequence: OEISSequence

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let name = sequence.name {
                Text(name)
                    .font(.headline)
            }
            if let terms = sequence.data {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text("Terms: \(terms)")
                        .font(.callout)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.primary)
                        .padding(.bottom, 3)
                }
            }
            if let descs = sequence.comment {
                ForEach(descs, id: \.self) { desc in
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            if let refs = sequence.reference, !refs.isEmpty {
                Text("References:")
                    .font(.subheadline).bold()
                ForEach(refs, id: \.self) { ref in
                    Text(ref)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            if let links = sequence.link, !links.isEmpty {
                Text("Links:")
                    .font(.subheadline)
                    .bold()
                ForEach(links, id: \.self) { link in
                    Text(link)
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .lineLimit(2)
                }
            }
            if let formulae = sequence.formula, !formulae.isEmpty {
                Text("Formulae:")
                    .font(.subheadline).bold()
                ForEach(formulae, id: \.self) { form in
                    Text(form)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            if let examples = sequence.example, !examples.isEmpty {
                Text("Examples:")
                    .font(.subheadline).bold()
                ForEach(examples, id: \.self) { ex in
                    Text(ex)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            if let author = sequence.author {
                Text("Author: \(author)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            if let time = sequence.time {
                Text("Updated: \(time)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

// MARK: - Preview

struct OEISSequencesView_Previews: PreviewProvider {
    static var previews: some View {
        OEISSequencesView()
    }
}
