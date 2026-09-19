import SwiftUI

struct SourcesView: View {

    @Environment(\.dismiss)
    private var dismiss

    @StateObject private var sourceStore =
        SourceStore.shared

    @State private var showingAddSource = false

    @State private var editingSource:
        RobloxSource?

    let onSourcesChanged: () -> Void

    var body: some View {

        NavigationStack {

            List {

                if sourceStore.sources.isEmpty {

                    ContentUnavailableView(
                        "No Sources",
                        systemImage:
                            "tray",
                        description:
                            Text(
                                "Add a Roblox User, Group, or Game."
                            )
                    )

                } else {

                    ForEach(
                        sourceStore.sources
                    ) { source in

                        SourceRow(
                            source: source
                        )
                        .contentShape(
                            Rectangle()
                        )
                        .onTapGesture {

                            editingSource =
                                source
                        }
                    }
                    .onDelete {
                        deleteSources(
                            at: $0
                        )
                    }
                }
            }

            .navigationTitle("Sources")

            .toolbar {

                ToolbarItem(
                    placement: .topBarLeading
                ) {

                    Button("Done") {

                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button {

                        showingAddSource = true

                    } label: {

                        Image(
                            systemName: "plus"
                        )
                    }
                }
            }

            .sheet(
                isPresented:
                    $showingAddSource
            ) {

                SourceEditorView(
                    mode: .add
                )
            }

            .sheet(
                item: $editingSource
            ) { source in

                SourceEditorView(
                    mode: .edit(source)
                )
            }

            .onChange(
                of: sourceStore.sources
            ) {

                onSourcesChanged()
            }
        }
    }

    private func deleteSources(
        at offsets: IndexSet
    ) {

        for index in offsets {

            let source =
                sourceStore.sources[index]

            sourceStore.delete(source)
        }
    }
}


// MARK: - Source Row

private struct SourceRow: View {

    let source: RobloxSource

    var body: some View {

        HStack(spacing: 14) {

            Image(
                systemName: icon
            )
            .font(.title3)
            .frame(
                width: 30
            )

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text(source.name)
                    .font(.headline)

                Text(
                    "\(source.type.displayName) • \(source.value)"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
            }

            Spacer()
        }
        .padding(
            .vertical,
            4
        )
    }

    private var icon: String {

        switch source.type {

        case .user:
            return "person.fill"

        case .group:
            return "person.3.fill"

        case .game:
            return "gamecontroller.fill"
        }
    }
}


// MARK: - Preview

#Preview {
    SourcesView {
    }
}