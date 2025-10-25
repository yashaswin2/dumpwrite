import SwiftUI
import AppKit

// To disable backspace, we need to subclass NSTextView
class NoBackspaceTextView: NSTextView {
    override func keyDown(with event: NSEvent) {
        let keyCode = event.keyCode
        // Backspace is 51, Delete is 117
        if keyCode == 51 || keyCode == 117 {
            // Ignore
            return
        }
        super.keyDown(with: event)
    }
}

struct CustomTextView: NSViewRepresentable {
    @Binding var text: String
    let fontSize: Int
    let colorScheme: ColorScheme

    func makeNSView(context: Context) -> NoBackspaceTextView {
        let textView = NoBackspaceTextView()
        textView.font = NSFont(name: "Times New Roman", size: CGFloat(fontSize))
        textView.textColor = colorScheme == .dark ? .white : .black
        textView.backgroundColor = colorScheme == .dark ? .black : .white
        textView.isEditable = true
        textView.isSelectable = true
        textView.string = text
        textView.delegate = context.coordinator
        return textView
    }

    func updateNSView(_ nsView: NoBackspaceTextView, context: Context) {
        if nsView.string != text {
            nsView.string = text
        }
        nsView.font = NSFont(name: "Times New Roman", size: CGFloat(fontSize))
        nsView.textColor = colorScheme == .dark ? .white : .black
        nsView.backgroundColor = colorScheme == .dark ? .black : .white
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CustomTextView

        init(_ parent: CustomTextView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            if let textView = notification.object as? NSTextView {
                parent.text = textView.string
            }
        }

        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            // Allow all changes except if it's a backspace or delete
            // But actually, to disable backspace, we need to override keyDown
            return true
        }
    }
}

struct FreewriteView: View {
    @Binding var note: Note
    let fontSize: Int
    let colorScheme: ColorScheme
    @Binding var timeRemaining: Int
    let onExit: () -> Void

    @State private var showExitTopLeft = false
    @State private var showExitTopRight = false

    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? .black : .white)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CustomTextView(text: $note.content, fontSize: fontSize, colorScheme: colorScheme)
                        .frame(width: 600, height: 400)
                    Spacer()
                }
                Spacer()
            }
            // Top left corner hover
            VStack {
                HStack {
                    if showExitTopLeft {
                        Button("Exit Freewrite") {
                            onExit()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onHover { hovering in
                showExitTopLeft = hovering
            }
            // Top right corner hover
            VStack {
                HStack {
                    Spacer()
                    if showExitTopRight {
                        Button("Exit Freewrite") {
                            onExit()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onHover { hovering in
                showExitTopRight = hovering
            }
        }
        .preferredColorScheme(colorScheme)
        .onChange(of: note.content) {
            note.updatedAt = Date()
        }
    }
}
