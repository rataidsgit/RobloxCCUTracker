import SwiftUI

struct SourceEditorView: View {

    enum Mode {
        case add
        case edit(RobloxSource)
    }

    @Environment(\.dismiss)
    private var dismiss

    @StateObject private var sourceStore =
        SourceStore.shared

    let mode: Mode

    @State private var type:
        RobloxSourceType = .group

    @State private var idText = ""

    @State private var name = ""

    private var isEditing: Bool {

        if case .edit = mode {
            return true
        }

        return false
    }

    private var title: String {

        isEditing
            ? "Edit Source"
            : "Add Source"
    }

    private var validID: Int? {

        Int(
            idText
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
        )
    }

    private var canSave: Bool {

        guard validID != nil else {
            return false
        }

        return !name
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
    }

    var body: some View {

        NavigationStack {

            Form {

                Section("Source Type") {

                    Picker(
                        "Type",
                        selection: $type
                    ) {

                        ForEach(
                            RobloxSourceType.allCases
                        ) { type in

                            Text(
                                type.displayName
                            )
                            .tag(type)
                        }
                    }
                    .pickerStyle(
                        .segmented
                    )
                }

                Section("Roblox ID") {

                    TextField(
                        idPlaceholder,
                        text: $idText
                    )
                    .keyboardType(
                        .numberPad
                    )

                    Text(
                        idDescription
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                }

                Section("Name") {

                    TextField(
                        "Display Name",
                        text: $name
                    )
                }

                if !canSave {

                    Section {

                        Label(
                            "Enter a valid Roblox ID and name.",
                            systemImage:
                                "exclamationmark.circle"
                        )
                        .foregroundStyle(
                            .secondary
                        )
                    }
                }
            }

            .navigationTitle(title)

            .toolbar {

                ToolbarItem(
                    placement: .topBarLeading
                ) {

                    Button("Cancel") {

                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button("Save") {

                        save()
                    }
                    .disabled(
                        !canSave
                    )
                }
            }
        }

        .onAppear {

            loadExistingSource()
        }
    }

    // MARK: - Existing Source

    private func loadExistingSource() {

        guard case .edit(let source) = mode
        else {
            return
        }

        type = source.type
        idText = String(source.value)
        name = source.name
    }

    // MARK: - Save

    private func save() {

        guard let value = validID
        else {
            return
        }

        let trimmedName =
            name.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        switch mode {

        case .add:

            let source = RobloxSource(
                type: type,
                value: value,
                name: trimmedName
            )

            sourceStore.add(source)

        case .edit(let existing):

            let updated = RobloxSource(
                id: existing.id,
                type: type,
                value: value,
                name: trimmedName
            )

            sourceStore.update(updated)
        }

        dismiss()
    }

    // MARK: - UI Text

    private var idPlaceholder: String {

        switch type {

        case .user:
            return "User ID"

        case .group:
            return "Group ID"

        case .game:
            return "Universe ID"
        }
    }

    private var idDescription: String {

        switch type {

        case .user:
            return "The numeric ID of the Roblox user."

        case .group:
            return "The numeric ID of the Roblox group."

        case .game:
            return "Use the game's Universe ID, not its Place ID."
        }
    }
}

#Preview {
    SourceEditorView(
        mode: .add
    )
}