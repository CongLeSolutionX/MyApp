//
//  NotificationView_V6.swift
//  ContentView_FullFeature.swift
//  MyApp
//
//  Created by Cong Le on 4/22/25.
//
//  Targets iOS 15+. Requires:
//    • NSCalendarsUsageDescription in Info.plist
//    • NSRemindersUsageDescription in Info.plist
//    • Add “MessageUI” framework

import SwiftUI
import MessageUI
import EventKit
import AVFoundation
import PhotosUI

// MARK: – Haptic Helper
struct Haptics {
    static let shared = Haptics()
    private let impact = UIImpactFeedbackGenerator(style: .light)
    private let selection = UISelectionFeedbackGenerator()
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private init() {
        impact.prepare(); selection.prepare(); medium.prepare()
    }
    func tap()        { impact.impactOccurred() }
    func select()     { selection.selectionChanged() }
    func openSheet()  { medium.impactOccurred() }
}

// MARK: – Data Model
enum FeatureDestination: Identifiable {
    case composeMessage
    case composeMail
    case pickPhoto(source: UIImagePickerController.SourceType)
    case showEventDetail(EKEvent)
    case showReminders
    case none
    
    var id: String {
        switch self {
        case .composeMessage:           return "msgCompose"
        case .composeMail:              return "mailCompose"
        case .pickPhoto(.camera):       return "photoCamera"
        case .pickPhoto(.photoLibrary): return "photoLibrary"
        case .showEventDetail(let e):   return e.eventIdentifier
        case .showReminders:            return "reminders"
        case .none:                     return "none"
        case .pickPhoto(source: .savedPhotosAlbum):
            return "pick photo from savedPhotosAlbum source"
        case .pickPhoto(source: _):
            return "pick photo from custom source"
        }
    }
}

struct NotificationData: Identifiable {
    let id = UUID()
    let icon: String
    let appName: String
    let title: String
    let body: String
    let date: Date
    let destination: FeatureDestination
    
    var timeString: String {
        let f = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            f.timeStyle = .short
            f.dateStyle = .none
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            f.dateStyle = .short
            f.timeStyle = .short
        }
        return f.string(from: date)
    }
}

// MARK: – EventKit Managers

class CalendarManager: ObservableObject {
    @Published var events: [EKEvent] = []
    @Published var error: String?
    @Published var loading = false
    private let store = EKEventStore()
    
    func requestAndFetch() {
        loading = true
        error = nil
        store.requestAccess(to: .event) { granted, err in
            DispatchQueue.main.async {
                guard granted else {
                    self.error = "Calendar access denied."
                    self.loading = false
                    return
                }
                self.fetch()
            }
        }
    }
    private func fetch() {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        let pred = store.predicateForEvents(withStart: start, end: end, calendars: store.calendars(for: .event))
        DispatchQueue.global(qos:.userInitiated).async {
            let evs = self.store.events(matching: pred)
                .filter { !$0.isAllDay }
                .sorted { $0.startDate < $1.startDate }
            DispatchQueue.main.async {
                self.events = evs
                self.loading = false
            }
        }
    }
}

class RemindersManager: ObservableObject {
    @Published var reminders: [EKReminder] = []
    @Published var error: String?
    @Published var loading = false
    private let store = EKEventStore()
    
    func requestAndFetch() {
        loading = true
        error = nil
        store.requestAccess(to: .reminder) { granted, err in
            DispatchQueue.main.async {
                guard granted else {
                    self.error = "Reminders access denied."
                    self.loading = false
                    return
                }
                self.fetch()
            }
        }
    }
    private func fetch() {
        let pred = store.predicateForReminders(in: store.calendars(for: .reminder))
        store.fetchReminders(matching: pred) { items in
            DispatchQueue.main.async {
                self.reminders = items?.filter { $0.isCompleted == false } ?? []
                self.loading = false
            }
        }
    }
}

// MARK: – UIKit Wrappers

// Message Composer
struct MessageComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.messageComposeDelegate = context.coordinator
        return vc
    }
    func updateUIViewController(_ ui: MFMessageComposeViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let parent: MessageComposeView
        init(_ p: MessageComposeView) { parent = p }
        func messageComposeViewController(_ vc: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.dismiss()
        }
    }
}

// Mail Composer
struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    func updateUIViewController(_ ui: MFMailComposeViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        init(_ p: MailComposeView) { parent = p }
        internal func mailComposeController(_ vc: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error?) {
            parent.dismiss()
        }
    }
}

// Image Picker (Camera/Library)
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    let source: UIImagePickerController.SourceType
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ ui: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ p: ImagePicker) { parent = p }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey:Any]) {
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: – SwiftUI Views

struct NotificationViewRow: View {
    let data: NotificationData
    var body: some View {
        HStack(spacing:12) {
            Image(systemName: data.icon)
                .font(.title3)
                .frame(width:36,height:36)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius:8))
            VStack(alignment:.leading,spacing:4) {
                HStack {
                    Text(data.appName).font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text(data.timeString).font(.caption2).foregroundColor(.secondary)
                }
                Text(data.title).font(.headline)
                Text(data.body).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius:16))
        .shadow(color:.black.opacity(0.1),radius:4,y:2)
    }
}

struct InteractiveRow: View {
    let data: NotificationData
    let onTap: (FeatureDestination) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button {
            Haptics.shared.tap()
            onTap(data.destination)
        } label: {
            NotificationViewRow(data: data)
        }
        .buttonStyle(.plain)
        .swipeActions(edge:.trailing) {
            Button(role:.destructive) {
                onDelete()
            } label: { Label("Clear", systemImage:"trash.fill") }
        }
    }
}

struct ContentView: View {
    @StateObject private var calMgr = CalendarManager()
    @StateObject private var remMgr = RemindersManager()
    
    // Master list
    @State private var items: [NotificationData] = [
        .init(icon:"message.fill", appName:"Messages", title:"Lunch?", body:"Hey, free for lunch?", date:Date().addingTimeInterval(-300), destination:.composeMessage),
        .init(icon:"envelope.fill", appName:"Mail", title:"Weekly Digest", body:"Your roundup is ready.", date:Date().addingTimeInterval(-3600), destination:.composeMail),
        .init(icon:"photo.on.rectangle", appName:"Photos", title:"New Memory", body:"Your trip memory is here.", date:Date().addingTimeInterval(-86400), destination:.pickPhoto(source:.photoLibrary)),
    ]
    @State private var collapsed = true
    @State private var flashlightOn = false
    
    // Presentation
    @State private var destination: FeatureDestination? = nil
    @State private var showRemindersSheet = false
    
    private let maxShow = 2
    
    var sorted: [NotificationData] {
        items.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        Text("ContentView")
    }
    
//    var body: some View {
//        ZStack {
//            LinearGradient(colors:[.blue.opacity(0.8),.indigo.opacity(0.8)], startPoint:.topLeading, endPoint:.bottomTrailing)
//                .ignoresSafeArea()
//            
//            ScrollView {
//                VStack(spacing:12) {
//                    HeaderView()
//                    
//                    Group {
//                        if calMgr.loading { ProgressView().tint(.white) }
//                        if let err = calMgr.error {
//                            Text(err).foregroundColor(.yellow).padding(6).background(.black.opacity(0.3)).clipShape(RoundedRectangle(cornerRadius:8))
//                        }
//                        if remMgr.loading { ProgressView("Loading Reminders…").tint(.white) }
//                    }
//                    
//                    // Merge calendar events when available
//                    ForEach(calMgr.events) { ev in
//                        let note = NotificationData(
//                            icon:"calendar",
//                            appName:"Calendar",
//                            title:ev.title ?? "Event",
//                            body:(ev.location ?? "") + " — \(ev.startDate, style:.time)",
//                            date:ev.startDate,
//                            destination:.showEventDetail(ev)
//                        )
//                        if !items.contains(where:{ $0.id == note.id }) {
//                            items.append(note)
//                        }
//                    }
//                    
//                    if collapsed && sorted.count > maxShow {
//                        ForEach(sorted.prefix(maxShow)) { note in
//                            InteractiveRow(data:note,onTap:launch, onDelete:{
//                                withAnimation { items.removeAll{ $0.id == note.id } }
//                            })
//                        }
//                        ExpandButton(count: sorted.count - maxShow) {
//                            withAnimation(.spring()) { collapsed = false }
//                        }
//                    } else {
//                        Text("Notifications").font(.caption2).foregroundColor(.white.opacity(0.8)).frame(maxWidth:.infinity,alignment:.leading)
//                        ForEach(sorted) { note in
//                            InteractiveRow(data:note,onTap:launch, onDelete:{
//                                withAnimation { items.removeAll{ $0.id == note.id } }
//                            })
//                        }
//                        if sorted.count > maxShow {
//                            CollapseButton { withAnimation(.spring()) { collapsed = true } }
//                        }
//                    }
//                }
//                .padding(.horizontal,10)
//                .padding(.top,50)
//                .padding(.bottom,140)
//            }
//            
//            BottomBar(
//                flashlightOn: $flashlightOn,
//                onCamera: { launch(.pickPhoto(source:.camera)) },
//                onReminders: {
//                    Haptics.shared.openSheet()
//                    remMgr.requestAndFetch()
//                    showRemindersSheet = true
//                },
//                toggleFlash: toggleFlash
//            )
//        }
//        .sheet(item:$destination) { dest in
//            switch dest {
//            case .composeMessage:
//                MessageComposeView()
//            case .composeMail:
//                MailComposeView()
//            case .pickPhoto(let src):
//                ImagePicker(source: src)
//            case .showEventDetail(let ev):
//                CalendarEventDetail(event:ev)
//            default:
//                EmptyView()
//            }
//        }
//        .sheet(isPresented:$showRemindersSheet) {
//            RemindersListView(manager: remMgr)
//        }
//        .onAppear {
//            calMgr.requestAndFetch()
//        }
//        .preferredColorScheme(.dark)
//    }
    
    private func launch(_ dest: FeatureDestination) {
        destination = dest
        Haptics.shared.openSheet()
    }
    
    private func toggleFlash() {
        guard let dev = AVCaptureDevice.default(for:.video), dev.hasTorch else { return }
        do {
            try dev.lockForConfiguration()
            dev.torchMode = dev.torchMode == .on ? .off : .on
            dev.unlockForConfiguration()
            flashlightOn.toggle()
            Haptics.shared.select()
        } catch { print("Torch error:",error) }
    }
}

// MARK: – Subviews

struct HeaderView: View {
    var body: some View {
        VStack(spacing:4) {
            Text(Date(), style:.date).font(.title3).foregroundColor(.white.opacity(0.9))
            Text(Date(), style:.time).font(.system(size:70, weight:.thin)).foregroundColor(.white)
        }
        .shadow(radius:3)
    }
}

struct ExpandButton: View {
    let count:Int, action:() -> Void
    var body: some View {
        Button(action:action) {
            HStack {
                Text("+\(count) more").font(.footnote).bold()
                Spacer()
                Image(systemName:"chevron.down")
            }
            .padding(8).background(.black.opacity(0.25)).clipShape(RoundedRectangle(cornerRadius:12))
        }
        .buttonStyle(.plain)
    }
}

struct CollapseButton: View {
    let action:() -> Void
    var body: some View {
        Button(action:action) {
            Label("Show Less", systemImage:"chevron.up")
                .font(.footnote).padding(8)
                .background(.black.opacity(0.25)).clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct BottomBar: View {
    @Binding var flashlightOn: Bool
    let onCamera: () -> Void
    let onReminders: () -> Void
    let toggleFlash: () -> Void
    
    var body: some View {
        HStack(spacing:80) {
            Button { toggleFlash() }
            label: {
                Image(systemName: flashlightOn ? "flashlight.on.fill":"flashlight.off.fill")
                    .font(.title2).frame(width:50,height:50)
                    .background(.black.opacity(0.3)).clipShape(Circle())
            }
            .buttonStyle(.plain)
            Button { onCamera() }
            label: {
                Image(systemName:"camera.fill")
                    .font(.title2).frame(width:50,height:50)
                    .background(.black.opacity(0.3)).clipShape(Circle())
            }
            .buttonStyle(.plain)
            Button { onReminders() }
            label: {
                Image(systemName:"list.bullet")
                    .font(.title2).frame(width:50,height:50)
                    .background(.black.opacity(0.3)).clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom,40)
        .foregroundColor(.white)
    }
}

// Calendar Event Detail
struct CalendarEventDetail: View {
    let event: EKEvent
    var body: some View {
        VStack(spacing:20) {
            Text(event.title ?? "Event").font(.title)
            Text(event.startDate, style:.date).bold()
            Text(event.startDate, style:.time)
            if let loc = event.location {
                Label(loc, systemImage:"mappin.and.ellipse")
            }
            Text(event.notes ?? "").padding()
            Spacer()
        }
        .padding()
    }
}

// Reminders List
struct RemindersListView: View {
    @ObservedObject var manager: RemindersManager
    var body: some View {
        NavigationView {
            List {
                if manager.loading {
                    ProgressView()
                } else if let err = manager.error {
                    Text(err).foregroundColor(.red)
                } else {
                    ForEach(manager.reminders, id: \.calendarItemIdentifier) { r in
                        HStack {
                            Text(r.title)
                            Spacer()
                            if let d = r.dueDateComponents?.date {
                                Text(d, style:.date).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reminders")
            .toolbar {
                ToolbarItem(placement:.automatic) {
                    Button("Done") { UIApplication.shared.dismissAllSheets() }
                }
            }
        }
    }
}

// Helper to dismiss sheets from UIKit
extension UIApplication {
    func dismissAllSheets() {
        windows.first?.rootViewController?.dismiss(animated:true)
    }
}

// MARK: – Previews
#Preview() {
    ContentView()
}

//
//struct ContentView_FullFeature_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .previewDevice("iPhone 14 Pro")
//    }
//}
