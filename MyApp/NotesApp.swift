//
//  NotesApp.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

import SwiftUI

// --- Models ---

/// Represents a Note with a title, content, and associated theme color.
struct Note: Identifiable {
    let id: UUID
    var title: String
    var content: String
    var themeColor: Color
}

// --- ViewModels ---

/// ViewModel for managing a collection of notes.
class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    
    /// Adds a new note to the collection.
    func addNote(title: String, content: String, themeColor: Color) {
        let newNote = Note(id: UUID(), title: title, content: content, themeColor: themeColor)
        notes.append(newNote)
    }
    
    /// Deletes a note from the collection.
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
}

// --- Color Palettes ---

// (Palettes are the same as before)

/// Palette using the Display P3 color space for potentially more vibrant colors
/// on compatible wide-gamut displays.
struct DisplayP3Palette {
    static let vibrantRed: Color = Color(.displayP3, red: 1.0, green: 0.1, blue: 0.1)
    static let lushGreen: Color = Color(.displayP3, red: 0.1, green: 0.9, blue: 0.2)
    static let deepBlue: Color = Color(.displayP3, red: 0.1, green: 0.2, blue: 0.95)
    static let brightMagenta: Color = Color(.displayP3, red: 0.95, green: 0.1, blue: 0.8)
}

/// Palette demonstrating the use of extended range values (outside 0.0-1.0).
struct ExtendedRangePalette {
    static let ultraWhite: Color = Color(.sRGB, white: 1.1)
    static let intenseRed: Color = Color(.sRGB, red: 1.2, green: 0, blue: 0)
    static let deeperThanBlack: Color = Color(.sRGB, white: -0.1)
}

// Other palettes (HSBPalette and GrayscalePalette) are the same

// --- Views ---

/// The main view displaying the list of notes.
struct NotesListView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.notes) { note in
                    NavigationLink(destination: NoteDetailView(note: note)) {
                        NoteRowView(note: note)
                    }
                }
                .onDelete(perform: viewModel.deleteNote)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("My Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Note")
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(viewModel: viewModel)
            }
        }
    }
}

/// A view representing a single row in the list of notes.
struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(note.title)
                    .font(.headline)
                    .foregroundColor(note.themeColor)
                Text(note.content)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

/// A detailed view showing the full content of a note.
struct NoteDetailView: View {
    let note: Note
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(note.title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(note.themeColor)
                Text(note.content)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Note Details")
    }
}

/// A view for adding a new note.
struct AddNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: NotesViewModel
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedColor: Color = DisplayP3Palette.vibrantRed
    @State var showingColorPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter note title", text: $title)
                }
                
                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(height: 150)
                }
                
                Section(header: Text("Theme Color")) {
                    Button(action: {
                        showingColorPicker = true
                    }) {
                        HStack {
                            Circle()
                                .fill(selectedColor)
                                .frame(width: 30, height: 30)
                            Text("Choose Color")
                        }
                    }
                }
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addNote(title: title, content: content, themeColor: selectedColor)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerView(selectedColor: $selectedColor)
            }
        }
    }
}

/// A view for selecting a color from the palettes.
struct ColorPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedColor: Color
    
    // Combine all colors from the palettes into one array
    var colorOptions: [(String, Color)] = {
        let displayP3Colors = [
            ("Vibrant Red", DisplayP3Palette.vibrantRed),
            ("Lush Green", DisplayP3Palette.lushGreen),
            ("Deep Blue", DisplayP3Palette.deepBlue),
            ("Bright Magenta", DisplayP3Palette.brightMagenta)
        ]
        let extendedRangeColors = [
            ("Ultra White", ExtendedRangePalette.ultraWhite),
            ("Intense Red", ExtendedRangePalette.intenseRed),
            ("Deeper Than Black", ExtendedRangePalette.deeperThanBlack)
        ]
        let hsbColors = [
            ("Sunshine Yellow", HSBPalette.sunshineYellow),
            ("Sky Blue", HSBPalette.skyBlue),
            ("Forest Green", HSBPalette.forestGreen),
            ("Fiery Orange", HSBPalette.fieryOrange)
        ]
        let grayscaleColors = [
            ("Light Gray", GrayscalePalette.lightGray),
            ("Medium Gray", GrayscalePalette.mediumGray),
            ("Dark Gray", GrayscalePalette.darkGray)
        ]
        return displayP3Colors + extendedRangeColors + hsbColors + grayscaleColors
    }()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(colorOptions, id: \.0) { name, color in
                    Button(action: {
                        selectedColor = color
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                            Text(name)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Choose Color")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// --- App Entry Point ---

@main
struct NotesApp: App {
    var body: some Scene {
        WindowGroup {
            NotesListView()
        }
    }
}
