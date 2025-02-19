//
//  PaperViewCodeView.swift
//  MyApp
//
//  Created by Cong Le on 2/18/25.
//

import SwiftUI

// MARK: - Data Model

struct Paper: Codable, Identifiable {
    let id = UUID()
    let paper_url: String?
    let paper_title: String?
    let paper_arxiv_id: String?
    let paper_url_abs: String?
    let paper_url_pdf: String?
    let repo_url: String?
    let is_official: Bool?
    let mentioned_in_paper: Bool?
    let mentioned_in_github: Bool?
    let framework: String?
}

// MARK: - Card View

struct PaperCardView: View {
    let paper: Paper

    var body: some View {
        VStack(alignment: .leading) {
            // Title
            Text(paper.paper_title ?? "Unknown Title")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.bottom, 2)

            // Framework
            if let framework = paper.framework, framework != "none" {
                Text("Framework: \(framework.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }

            // Links (Conditionally Displayed)
            if let pdfURL = paper.paper_url_pdf, let url = URL(string: pdfURL) {
                Link(destination: url) {
                    Text("Read PDF")
                }
                .padding(.bottom, 2)
            }
            if let repoURL = paper.repo_url, let url = URL(string: repoURL) {
                Link(destination: url) {
                    Text("GitHub Repo")
                }
            }

            // Additional Details (Conditionally Displayed)

            if let arxivID = paper.paper_arxiv_id {
                Text("arXiv ID: \(arxivID)") // Display arXiv ID
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground)) // Use system background for dynamic theming
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Main View (that uses PaperCardView)

struct PaperViewCodeContentView: View {
    // Use static data directly
    let papers: [Paper] = [
        Paper(paper_url: "https://paperswithcode.com/paper/deep-sensing-active-sensing-using-multi", paper_title: "Deep Sensing: Active Sensing using Multi-directional Recurrent Neural Networks", paper_arxiv_id: nil, paper_url_abs: "https://openreview.net/forum?id=r1SnX5xCb", paper_url_pdf: "https://openreview.net/pdf?id=r1SnX5xCb", repo_url: "https://github.com/vanderschaarlab/mlforhealthlabpub/tree/main/alg/DeepSensing%20(MRNN)", is_official: true, mentioned_in_paper: false, mentioned_in_github: false, framework: "jax"),
        Paper(paper_url: "https://paperswithcode.com/paper/efficient-leave-one-out-cross-validation-for", paper_title: "Efficient leave-one-out cross-validation for Bayesian non-factorized normal and Student-t models", paper_arxiv_id: "1810.10559", paper_url_abs: "https://arxiv.org/abs/1810.10559v5", paper_url_pdf: "https://arxiv.org/pdf/1810.10559v5", repo_url: "https://github.com/paul-buerkner/psis-non-factorized-paper", is_official: true, mentioned_in_paper: true, mentioned_in_github: false, framework: "none")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(papers) { paper in
                        PaperCardView(paper: paper)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Research Papers")
        }
    }
}

// MARK: - Preview

struct PaperViewCodeContentView_Previews: PreviewProvider {
    static var previews: some View {
        PaperViewCodeContentView()
    }
}
