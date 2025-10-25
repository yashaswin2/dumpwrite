import SwiftUI


struct NoteEditorView: View {
    @Binding var note: Note
    let fontSize: Int
    let colorScheme: ColorScheme
    @Binding var isFreewriteMode: Bool
    @Binding var timeRemaining: Int

    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? .black : .white)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    TextEditor(text: $note.content)
                        .font(.custom("Times New Roman", size: CGFloat(fontSize)))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .background(Color.clear)
                        .frame(width: 600) // Fixed width for paper-like feel
                        .onChange(of: note.content) {
                            note.updatedAt = Date()
                        }
                    Spacer()
                }
                Spacer()
            }
        }
        .preferredColorScheme(colorScheme)
    }
}
