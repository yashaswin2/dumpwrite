import SwiftUI
import AppKit

struct ContentView: View {
    @State private var notes: [Note] = [] {
        didSet {
            saveNotes()
        }
    }
    @State private var selectedNoteID: UUID?

    private var selectedNote: Note? {
        notes.first { $0.id == selectedNoteID }
    }

    private var sortedNotes: [Note] {
        notes.sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    init() {
        loadNotes()
    }
    @State private var isFreewriteMode = false
    @State private var timerDuration: Int = 5 // minutes
    @State private var fontSize: Int = 13
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var isDarkMode = false

    private var effectiveColorScheme: ColorScheme {
        isDarkMode ? .dark : systemColorScheme
    }
    @State private var timer: Timer?
    @State private var timeRemaining: Int = 0

    var body: some View {
        HStack(spacing: 0) {
            // Left pane: Note list
            List(sortedNotes, selection: $selectedNoteID) { note in
                VStack(alignment: .leading) {
                    Text(note.title)
                        .font(.headline)
                    Text(note.preview)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .contextMenu {
                    Button("Delete") {
                        if let index = notes.firstIndex(where: { $0.id == note.id }) {
                            notes.remove(at: index)
                            if selectedNoteID == note.id {
                                selectedNoteID = nil
                            }
                        }
                    }
                }
            }
            .frame(width: 250)

            // Right pane: Editor
            if let selectedNote = selectedNote, let index = notes.firstIndex(where: { $0.id == selectedNote.id }) {
                NoteEditorView(note: $notes[index], fontSize: fontSize, colorScheme: effectiveColorScheme, isFreewriteMode: $isFreewriteMode, timeRemaining: $timeRemaining)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Select a note or create a new one")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button("New Note") {
                    let newNote = Note()
                    notes.append(newNote)
                    selectedNoteID = newNote.id
                }
                Picker("Timer", selection: $timerDuration) {
                    Text("5").tag(5)
                    Text("10").tag(10)
                    Text("15").tag(15)
                    Text("25").tag(25)
                }
                .pickerStyle(.segmented)
                Button("Freewrite") {
                    startFreewrite()
                }
                .disabled(selectedNote == nil)
                Picker("Font Size", selection: $fontSize) {
                    Text("13").tag(13)
                    Text("15").tag(15)
                }
                .pickerStyle(.segmented)
                Toggle("Dark Mode", isOn: $isDarkMode)
                Button("Export to PDF") {
                    exportToPDF()
                }
                .disabled(selectedNote == nil)
            }
        }
        .fullScreenCover(isPresented: $isFreewriteMode) {
            if let selectedNote = selectedNote, let index = notes.firstIndex(where: { $0.id == selectedNote.id }) {
                FreewriteView(note: $notes[index], fontSize: fontSize, colorScheme: effectiveColorScheme, timeRemaining: $timeRemaining, onExit: {
                    endFreewrite()
                })
            }
        }
    }

    private func startFreewrite() {
        guard selectedNote != nil else { return }
        timeRemaining = timerDuration * 60
        isFreewriteMode = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                endFreewrite()
            }
        }
    }

    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "notes"),
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decodedNotes
        }
    }

    private func saveNotes() {
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: "notes")
        }
    }

    private func endFreewrite() {
        timer?.invalidate()
        timer = nil
        isFreewriteMode = false
    }

    private func exportToPDF() {
        guard let note = selectedNote else { return }
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["pdf"]
        savePanel.nameFieldStringValue = note.title + ".pdf"
        if savePanel.runModal() == .OK, let url = savePanel.url {
            let textView = NSTextView()
            textView.string = note.content
            textView.font = NSFont(name: "Times New Roman", size: CGFloat(fontSize))
            textView.textColor = effectiveColorScheme == .dark ? .white : .black
            textView.backgroundColor = effectiveColorScheme == .dark ? .black : .white
            let printInfo = NSPrintInfo.shared
            printInfo.paperSize = NSSize(width: 612, height: 792) // Letter size
            printInfo.leftMargin = 72
            printInfo.rightMargin = 72
            printInfo.topMargin = 72
            printInfo.bottomMargin = 72
            printInfo.jobDisposition = .saveAsPDF
            printInfo.outputURL = url
            let printOperation = NSPrintOperation(view: textView, printInfo: printInfo)
            printOperation.run()
        }
    }
}
