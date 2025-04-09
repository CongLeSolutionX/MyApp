//
//  Microservice Design Patterns UI ImplementationVIEW.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//
import SwiftUI

// MARK: - Reusable Icon/Element Views

struct IconContainer<Content: View>: View {
    let content: Content
    let label: String?
    let color: Color
    let iconBgColor: Color

    init(label: String? = nil, color: Color = .blue, iconBgColor: Color = .gray.opacity(0.2), @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
        self.color = color
        self.iconBgColor = iconBgColor
    }

    var body: some View {
        VStack {
            if let label = label {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.bottom, 2)
            }
            content
                .font(.system(size: 24))
                .frame(width: 50, height: 40)
                .background(iconBgColor)
                .foregroundColor(color)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color, lineWidth: 1)
                )
        }
    }
}

struct ClientIcon: View {
    var body: some View {
        IconContainer(label: "Client", color: .teal, iconBgColor: .teal.opacity(0.1)) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
        }
    }
}

struct MobileIcon: View {
    var body: some View {
        IconContainer(label: "Mobile App", color: .teal, iconBgColor: .teal.opacity(0.1)) {
            Image(systemName: "iphone.gen1") // Or "iphone"
        }
    }
}

struct MicroserviceIcon: View {
    var label: String = "Microservice"
    var body: some View {
        IconContainer(label: label, color: .green, iconBgColor: .green.opacity(0.1)) {
            Image(systemName: "server.rack")
        }
    }
}

struct DatabaseIcon: View {
    var label: String? = "Database" // Optional label
    var body: some View {
        IconContainer(label: label, color: .green, iconBgColor: .green.opacity(0.1)) {
            Image(systemName: "cylinder.split.1x2") // Or "opticaldisc"
        }
    }
}

struct APIGatewayIcon: View {
    var body: some View {
        IconContainer(label: "API Gateway", color: .pink, iconBgColor: .pink.opacity(0.1)) {
            Image(systemName: "network") // Placeholder
        }
    }
}

struct EventStoreIcon: View {
    var body: some View {
        IconContainer(label: "Event Store", color: .orange, iconBgColor: .orange.opacity(0.1)) {
            DatabaseIcon(label: nil) // Reuse database icon visually
        }
    }
}

struct MessageQueueIcon: View {
    var body: some View {
        IconContainer(label: "Message Queue", color: .yellow, iconBgColor: .yellow.opacity(0.1)) {
             Image(systemName: "envelope.fill") // Placeholder for message queue
        }
    }
}

struct CircuitBreakerIcon: View {
     var body: some View {
        IconContainer(label: "Circuit Breaker", color: .red, iconBgColor: .red.opacity(0.1)) {
             Image(systemName: "bolt.slash.circle.fill")
        }
    }
}

struct GenericBox: View {
    let text: String
    let color: Color
    var dotted: Bool = false

     var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(color, style: StrokeStyle(lineWidth: 1, dash: dotted ? [3] : []))
            )
            .foregroundColor(.black)

     }
}

struct ArrowSymbol: View {
    var direction: Edge = .trailing
    var length: CGFloat = 30

    var body: some View {
        Group {
            switch direction {
            case .trailing:
                Image(systemName: "arrow.right")
                    .frame(width: length)
            case .leading:
                Image(systemName: "arrow.left")
                    .frame(width: length)
            case .top:
                 Image(systemName: "arrow.up")
                    .frame(height: length)
            case .bottom:
                 Image(systemName: "arrow.down")
                    .frame(height: length)
            default:
                Image(systemName: "arrow.right") // Default
                    .frame(width: length)
            }
        }
        .foregroundColor(.gray)
    }
}

// MARK: - Pattern Detail Views

struct PatternSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            content
                .padding(.leading, 10) // Indent content slightly
        }
        .padding(.vertical)
    }
}

struct DatabasePerServiceView: View {
    var body: some View {
        PatternSection(title: "Database Per Service Pattern") {
            HStack(alignment: .center, spacing: 20) {
                ClientIcon()
                ArrowSymbol()
                VStack(spacing: 30) {
                    HStack {
                        MicroserviceIcon()
                        ArrowSymbol()
                        DatabaseIcon()
                    }
                    HStack {
                        MicroserviceIcon()
                        ArrowSymbol()
                        DatabaseIcon()
                    }
                }
                Spacer() // Push content to left
            }
        }
    }
}

struct APIGatewayView: View {
    var body: some View {
        PatternSection(title: "API Gateway Pattern") {
            HStack(spacing: 20) {
                VStack(spacing: 20) {
                    ClientIcon()
                    MobileIcon()
                }
                ArrowSymbol() // Simplified arrows
                APIGatewayIcon()
                ArrowSymbol() // Simplified arrows
                VStack(spacing: 20) {
                    HStack { MicroserviceIcon(); ArrowSymbol(); DatabaseIcon() }
                    HStack { MicroserviceIcon(); ArrowSymbol(); DatabaseIcon() }
                    HStack { MicroserviceIcon(); ArrowSymbol(); DatabaseIcon() }
                }
                Spacer()
            }
        }
    }
}

struct BFFPatternView: View {
    var body: some View {
        PatternSection(title: "BFF Pattern") {
             HStack(spacing: 15) {
                VStack(spacing: 20) {
                    ClientIcon()
                    MobileIcon()
                }
                ArrowSymbol()
                VStack(spacing: 10) {
                    GenericBox(text: "Web UI BFF", color: .yellow, dotted: true)
                    GenericBox(text: "App BFF", color: .yellow, dotted: true)
                }
                ArrowSymbol()
                 VStack(spacing: 20) {
                    HStack { MicroserviceIcon(); ArrowSymbol(); DatabaseIcon() }
                    HStack { MicroserviceIcon(); ArrowSymbol(); DatabaseIcon() }
                    HStack { MicroserviceIcon(); ArrowSymbol(); DatabaseIcon() }
                }
                 Spacer()
             }
        }
    }
}

struct EventSourcingView: View {
     var body: some View {
        PatternSection(title: "Event Sourcing Pattern") {
            VStack(alignment: .leading, spacing: 15) {
                 HStack {
                    ClientIcon()
                    ArrowSymbol(direction: .bottom, length: 20)
                    Spacer().frame(width: 100) // Spacing for layout
                    ArrowSymbol(direction: .bottom, length: 20)
                    Spacer()
                 }
                HStack(spacing: 10) {
                     GenericBox(text: "Profile Created", color: .yellow, dotted: false)
                     ArrowSymbol()
                     GenericBox(text: "Hobbies Updated", color: .yellow, dotted: false)
                     ArrowSymbol()
                     GenericBox(text: "Location Updated", color: .yellow, dotted: false)
                     ArrowSymbol()
                     EventStoreIcon()
                 }
                 HStack {
                      Spacer().frame(width: 100) // Align under boxes
                      ArrowSymbol(direction: .bottom, length: 20)
                      Spacer()
                 }
                 HStack {
                    GenericBox(text: "Read Data", color: .gray) // Placeholder for read model
                    ArrowSymbol()
                    DatabaseIcon(label: "Read Database")
                 }

            }
             .padding(.leading, 20) // Adjust layout
        }
     }
}

struct CQRSView: View {
    var body: some View {
        PatternSection(title: "CQRS Pattern") {
            HStack(spacing: 20) {
                ClientIcon()
                VStack { // Commands
                    ArrowSymbol(direction: .bottom)
                    GenericBox(text: "Command", color: .yellow, dotted: true)
                    ArrowSymbol(direction: .bottom)
                    DatabaseIcon(label: "Write DB")
                }
                ArrowSymbol() // To Message Queue
                MessageQueueIcon()
                ArrowSymbol() // From Message Queue
                VStack { // Queries
                     ArrowSymbol(direction: .bottom)
                     GenericBox(text: "Query", color: .yellow, dotted: true)
                     ArrowSymbol(direction: .bottom)
                     DatabaseIcon(label: "Read DB")
                }
                Spacer()
            }.padding(.leading)
        }
    }
}

struct SagaPatternView: View {
    var body: some View {
        PatternSection(title: "Saga Pattern") {
            // Representing Saga is complex; this is a simplified flow
           VStack(alignment: .leading, spacing: 15) {
               HStack {
                   MicroserviceIcon(label: "Service A")
                   ArrowSymbol()
                   Text("1").font(.caption).padding(5).background(Circle().fill(Color.blue)).foregroundColor(.white)
                   Text("Trigger Saga").font(.caption)
               }
               HStack {
                   GenericBox(text: "Saga Orchestrator", color: .green, dotted: true)
                   ArrowSymbol()
                   Text("2").font(.caption).padding(5).background(Circle().fill(Color.blue)).foregroundColor(.white)
                   MessageQueueIcon()
                    ArrowSymbol()
                    Text("3").font(.caption).padding(5).background(Circle().fill(Color.blue)).foregroundColor(.white)
                    MicroserviceIcon(label: "Service B")
                   ArrowSymbol(); DatabaseIcon()
               }
               HStack {
                    Spacer().frame(width: 150) // Layout spacing
                    ArrowSymbol(direction: .top)
                    Text("4").font(.caption).padding(5).background(Circle().fill(Color.blue)).foregroundColor(.white)
                    MessageQueueIcon()
                    ArrowSymbol(direction: .top)
                    Text("5").font(.caption).padding(5).background(Circle().fill(Color.blue)).foregroundColor(.white)
                     MicroserviceIcon(label: "Service C")
                     ArrowSymbol(); DatabaseIcon()
                }
                HStack {
                    Spacer().frame(width: 50) // Layout spacing
                    ArrowSymbol(direction: .leading)
                    Text("6").font(.caption).padding(5).background(Circle().fill(Color.blue)).foregroundColor(.white)
                    DatabaseIcon(label: "Saga Log")

                }
           }
           .padding(.leading)
        }
    }
}

struct SidecarPatternView: View {
    var body: some View {
         PatternSection(title: "Sidecar Pattern") {
             HStack(spacing: 15) {
                ClientIcon()
                ArrowSymbol()
                GenericBox(text: "Request", color: .gray)
                ArrowSymbol()
                VStack {
                    GenericBox(text: "Pod", color: .black.opacity(0.7))
                    VStack {
                        HStack(spacing: 30) {
                           GenericBox(text: "Service Container", color: .blue)
                           GenericBox(text: "Service Container", color: .blue) // Sidecar
                        }
                         HStack(spacing: 10) {
                            Text("Read").font(.caption)
                            ArrowSymbol()
                             IconContainer(label: nil, color: .blue) { Image(systemName: "arrow.triangle.2.circlepath") } // Placeholder
                            ArrowSymbol()
                             Text("Write").font(.caption)
                         }

                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.yellow, style: StrokeStyle(lineWidth: 1, dash: [4])))
                }
                ArrowSymbol()
                GenericBox(text: "Poll", color: .gray)
                 ArrowSymbol()
                 IconContainer(label: nil, color: .black) { Text("😺").font(.largeTitle) } // Github Octocat Placeholder
                Spacer()
             }
         }
    }
}

struct CircuitBreakerView: View {
     var body: some View {
        PatternSection(title: "Circuit Breaker Pattern") {
            HStack(spacing: 15) {
                VStack {
                    ClientIcon()
                    ArrowSymbol(direction: .bottom)
                    MicroserviceIcon(label: "Service A")
                    ArrowSymbol(direction: .bottom)
                    DatabaseIcon()
                }
                ArrowSymbol()
                CircuitBreakerIcon() // Simplified representation
                 Image(systemName: "xmark.octagon.fill") // Broken connection symbol
                    .foregroundColor(.red)
                    .font(.title)
                 ArrowSymbol()
                 VStack {
                     MicroserviceIcon(label: "Service B")
                     ArrowSymbol(direction: .bottom)
                     DatabaseIcon()

                 }
                 Spacer()
            }
        }
     }
}

// MARK: - Header and Main Content View

struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Rectangle() // Vertical bar
                    .fill(Color.teal)
                    .frame(width: 8, height: 40)
                Text("A Crash Course on")
                    .font(.title)
                    .fontWeight(.medium)
                Text("Microservice Design Patterns")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.teal)) // Rounded badge

                Spacer() // Pushes logo to the right

                 // Placeholder for ByteByteGo Logo
                 HStack {
                     Image(systemName: "leaf.fill") // Placeholder logo icon
                         .foregroundColor(.green)
                     Text("ByteByteGo")
                         .font(.headline)
                 }
            }
            .padding(.bottom)

            // Divider below header (optional)
            Divider()
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

struct PatternWheelView: View {
    // Conceptual representation - A simple list for now
    let patterns = [
        "Database Per Service Pattern", "API Gateway Pattern", "CQRS Pattern",
        "Saga Pattern", "Circuit Breaker Pattern", "Sidecar Pattern",
        "Event Sourcing Pattern", "BFF Pattern"
    ]

    var body: some View {
        VStack(alignment: .center) {
             Text("Core Patterns Overview")
                .font(.headline)
                .padding(.bottom, 5)

             // Simple list representation of the wheel concept
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 10) {
                 ForEach(patterns, id: \.self) { pattern in
                    Text(pattern)
                        .font(.caption)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(5)
                 }
             }
             .padding()
             .background(Circle().fill(Color.green.opacity(0.05))) // Hint at circular layout
             .frame(maxWidth: 400) // Limit width
        }
         .padding(.vertical)
    }
}

// MARK: - Main ContentView
struct MicroserviceDesignPatternsUIImplementationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HeaderView()

                // Conceptually represent the central wheel idea
                PatternWheelView()

                // Detail Sections for each pattern
                Group {
                    DatabasePerServiceView()
                    APIGatewayView()
                    BFFPatternView()
                    EventSourcingView()
                    SidecarPatternView()
                    CircuitBreakerView()
                    CQRSView()
                    SagaPatternView()
                }
                .padding(.horizontal) // Add padding to the detail sections

                Spacer() // Push content to top
            }
        }
    }
}

// MARK: - Preview Provider
#Preview {
    MicroserviceDesignPatternsUIImplementationView()
}
