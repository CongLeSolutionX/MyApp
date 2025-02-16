//
//  ParsingXML.swift
//  MyApp
//
//  Created by Cong Le on 2/16/25.
//

import SwiftUI
import Foundation

// MARK: - Data Models

struct RSSChannel {
    var title: String = ""
    var link: String = ""
    var description: String = ""
    var year: String = ""
    var month: String = ""
    var items: [RSSItem] = []
}

struct RSSItem: Identifiable {
    let id = UUID()
    var title: String = ""
    var link: String = ""
    var description: String = ""
    var pubDate: String = ""
    var volume: String = ""
    var issue: String = ""
    var startPage: String = ""
    var endPage: String = ""
    var fileSize: String = ""
    var authors: String = ""
}

// MARK: - RSS Parser

class RSSParser: NSObject, XMLParserDelegate, ObservableObject {
    @Published var channel = RSSChannel()
    
    // Internal state
    private var currentElement = ""
    private var currentValue = ""
    private var currentItem: RSSItem?
    private var isInsideChannel = false
    private var isInsideItem = false
    
    func parse(xmlString: String) {
        guard let data = xmlString.data(using: .utf8) else { return }
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName: String?, attributes: [String : String] = [:]) {
        currentElement = elementName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch currentElement {
        case "channel":
            isInsideChannel = true
        case "item":
            isInsideItem = true
            currentItem = RSSItem()
        default:
            break
        }
        
        currentValue = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Accumulate parsed text
        currentValue += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName: String?) {
        
        let trimmedValue = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isInsideItem {
            // Handle item elements
            switch elementName {
            case "title":
                currentItem?.title = trimmedValue
            case "link":
                currentItem?.link = trimmedValue
            case "description":
                currentItem?.description = trimmedValue
            case "pubDate":
                currentItem?.pubDate = trimmedValue
            case "volume":
                currentItem?.volume = trimmedValue
            case "issue":
                currentItem?.issue = trimmedValue
            case "startPage":
                currentItem?.startPage = trimmedValue
            case "endPage":
                currentItem?.endPage = trimmedValue
            case "fileSize":
                currentItem?.fileSize = trimmedValue
            case "authors":
                currentItem?.authors = trimmedValue
            case "item":
                if let item = currentItem {
                    channel.items.append(item)
                }
                currentItem = nil
                isInsideItem = false
            default:
                break
            }
        } else if isInsideChannel {
            // Handle channel elements
            switch elementName {
            case "title":
                channel.title = trimmedValue
            case "link":
                channel.link = trimmedValue
            case "description":
                channel.description = trimmedValue
            case "year":
                channel.year = trimmedValue
            case "month":
                channel.month = trimmedValue
            case "channel":
                isInsideChannel = false
            default:
                break
            }
        }
        
        currentElement = ""
        currentValue = ""
    }
}

// MARK: - RSSContentView

struct RSSContentView: View {
    @StateObject private var parser = RSSParser()
    
    // The entire XML snippet from the prompt, placed here as a raw string for demonstration.
    // In practice, you might load this from a file or network request.
    private let xmlSnippet = """
    <?xml version="1.0" encoding="utf-8"?>
    <rss version="2.0">
    <script src="chrome-extension://hoklmmgfnpapgjgcpechhaamimifchmp/frame_ant/frame_ant.js"/>
    <channel>
    <title><![CDATA[ IEEE Transactions on Pattern Analysis and Machine Intelligence - Popular ]]></title>
    <link>http://ieeexplore.ieee.org</link>
    <description>Popular Articles Alert for this Publication# 34 </description>
    <year>2025</year>
    <month>January </month>
    
    <item>
    <title><![CDATA[ End-to-End Autonomous Driving: Challenges and Frontiers ]]></title>
    <link><![CDATA[ http://ieeexplore.ieee.org/document/10614862 ]]></link>
    <description><![CDATA[
     The autonomous driving community has witnessed a rapid growth in approaches that embrace an end-to-end algorithm framework, utilizing raw sensor input to generate vehicle motion plans, instead of concentrating on individual tasks such as detection and motion prediction. End-to-end systems, in comparison to modular pipelines, benefit from joint feature optimization for perception and planning. This field has flourished due to the availability of large-scale datasets, closed-loop evaluation, and the increasing need for autonomous driving algorithms to perform effectively in challenging scenarios. In this survey, we provide a comprehensive analysis of more than 270 papers, covering the motivation, roadmap, methodology, challenges, and future trends in end-to-end autonomous driving. We delve into several critical challenges, including multi-modality, interpretability, causal confusion, robustness, and world models, amongst others. Additionally, we discuss current advancements in foundation models and visual pre-training, as well as how to incorporate these techniques within the end-to-end driving framework.
    ]]></description>
    <pubDate><![CDATA[ TUE, 30 JUL 2024 09:17:32 -0400 ]]></pubDate>
    <guid><![CDATA[ http://ieeexplore.ieee.org/document/10614862 ]]></guid>
    <volume>46</volume>
    <issue>12</issue>
    <startPage>10164</startPage>
    <endPage>10183</endPage>
    <fileSize>2772</fileSize>
    <authors><![CDATA[ Li Chen;Penghao Wu;Kashyap Chitta;Bernhard Jaeger;Andreas Geiger;Hongyang Li; ]]></authors>
    </item>
    
        <item>
        <title><![CDATA[ SegNet: A Deep Convolutional Encoder-Decoder Architecture for Image Segmentation ]]></title>
        <link><![CDATA[ http://ieeexplore.ieee.org/document/7803544 ]]></link>
        <description><![CDATA[
         We present a novel and practical deep fully convolutional neural network architecture for semantic pixel-wise segmentation termed SegNet. This core trainable segmentation engine consists of an encoder network, a corresponding decoder network followed by a pixel-wise classification layer. The architecture of the encoder network is topologically identical to the 13 convolutional layers in the VGG16 network [1] . The role of the decoder network is to map the low resolution encoder feature maps to full input resolution feature maps for pixel-wise classification. The novelty of SegNet lies is in the manner in which the decoder upsamples its lower resolution input feature map(s). Specifically, the decoder uses pooling indices computed in the max-pooling step of the corresponding encoder to perform non-linear upsampling. This eliminates the need for learning to upsample. The upsampled maps are sparse and are then convolved with trainable filters to produce dense feature maps. We compare our proposed architecture with the widely adopted FCN [2] and also with the well known DeepLab-LargeFOV [3] , DeconvNet [4] architectures. This comparison reveals the memory versus accuracy trade-off involved in achieving good segmentation performance. SegNet was primarily motivated by scene understanding applications. Hence, it is designed to be efficient both in terms of memory and computational time during inference. It is also significantly smaller in the number of trainable parameters than other competing architectures and can be trained end-to-end using stochastic gradient descent. We also performed a controlled benchmark of SegNet and other architectures on both road scenes and SUN RGB-D indoor scene segmentation tasks. These quantitative assessments show that SegNet provides good performance with competitive inference time and most efficient inference memory-wise as compared to other architectures. We also provide a Caffe implementation of SegNet and a web demo at http://mi.eng.cam.ac.uk/projects/segnet/.
        ]]></description>
        <pubDate><![CDATA[ MON, 02 JAN 2017 08:01:06 -0400 ]]></pubDate>
        <guid><![CDATA[ http://ieeexplore.ieee.org/document/7803544 ]]></guid>
        <volume>39</volume>
        <issue>12</issue>
        <startPage>2481</startPage>
        <endPage>2495</endPage>
        <fileSize>1394</fileSize>
        <authors><![CDATA[ Vijay Badrinarayanan;Alex Kendall;Roberto Cipolla; ]]></authors>
        </item>
    
    
    <!-- More <item> blocks could appear here -->
    </channel>
    </rss>
    """
    
    var body: some View {
        NavigationView {
            List {
                // Channel Info
                Section(header: Text("Channel Info")) {
                    Text("Title: \(parser.channel.title)")
                    Text("Link: \(parser.channel.link)")
                    Text("Description: \(parser.channel.description)")
                    Text("Year: \(parser.channel.year)")
                    Text("Month: \(parser.channel.month)")
                }
                
                // Items
                Section(header: Text("Items")) {
                    ForEach(parser.channel.items) { item in
                        NavigationLink(destination: ItemDetailView(item: item)) {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.description)
                                    .font(.subheadline)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("RSS Feed")
        }
        .onAppear {
            parser.parse(xmlString: xmlSnippet)
        }
    }
}

// MARK: - Item Detail View

struct ItemDetailView: View {
    let item: RSSItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Title: \(item.title)")
                    .font(.headline)
                Text("Link: \(item.link)")
                Text("Publication Date: \(item.pubDate)")
                Text("Volume: \(item.volume)")
                Text("Issue: \(item.issue)")
                Text("Pages: \(item.startPage) - \(item.endPage)")
                Text("File Size: \(item.fileSize)")
                Text("Authors: \(item.authors)")
                Text("Description:")
                    .fontWeight(.semibold)
                Text(item.description)
            }
            .padding()
        }
        .navigationTitle("Item Details")
    }
}

#Preview {
    RSSContentView()
}
// MARK: - Main App Entry (for SwiftUI Previews or full app)

//@main
//struct RSSParsingApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
