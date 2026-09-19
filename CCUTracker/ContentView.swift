import SwiftUI

struct ContentView: View {

    @StateObject private var sourceStore =
        SourceStore.shared

    @State private var games: [RobloxGame] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var showingSources = false

    private var totalCCU: Int {
        games.reduce(0) {
            $0 + $1.currentCCU
        }
    }

    var body: some View {

        NavigationStack {

            Group {

                if isLoading {

                    ProgressView(
                        "Loading Roblox games..."
                    )
                }

                else if let errorMessage {

                    VStack(spacing: 12) {

                        Image(
                            systemName: "exclamationmark.triangle"
                        )
                        .font(.largeTitle)

                        Text("Couldn't load games")
                            .font(.headline)

                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )
                            .multilineTextAlignment(
                                .center
                            )

                        Button("Retry") {

                            Task {
                                await loadGames()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }

                else if games.isEmpty {

                    ContentUnavailableView(
                        "No Games",
                        systemImage:
                            "gamecontroller",
                        description:
                            Text(
                                "Add a Roblox User, Group, or Game ID."
                            )
                    )
                }

                else {

                    gameList
                }
            }

            .navigationTitle("Roblox CCU")

            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button {

                        showingSources = true

                    } label: {

                        Image(
                            systemName: "gearshape"
                        )
                    }
                }
            }

            .task {

                await loadGames()
            }

            .refreshable {

                await loadGames()
            }

            .sheet(
                isPresented: $showingSources
            ) {

                SourcesView {
                    Task {
                        await loadGames()
                    }
                }
            }
        }
    }

    // MARK: - Game List

    private var gameList: some View {

        List {

            Section {

                VStack(spacing: 4) {

                    Text(
                        totalCCU.formatted()
                    )
                    .font(
                        .system(
                            size: 42,
                            weight: .bold
                        )
                    )
                    .monospacedDigit()

                    Text("TOTAL CCU")
                        .font(.caption)
                        .foregroundStyle(
                            .secondary
                        )
                }
                .frame(
                    maxWidth: .infinity
                )
                .padding(
                    .vertical,
                    12
                )
            }

            Section("Games") {

                ForEach(
                    games.sorted {
                        $0.currentCCU >
                        $1.currentCCU
                    }
                ) { game in

                    HStack {

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text(game.name)
                                .font(.headline)

                            if let creatorName =
                                game.creatorName {

                                Text(creatorName)
                                    .font(.caption)
                                    .foregroundStyle(
                                        .secondary
                                    )
                            }
                        }

                        Spacer()

                        Text(
                            game.currentCCU.formatted()
                        )
                        .font(.headline)
                        .monospacedDigit()
                    }
                }
            }
        }
    }

    // MARK: - Load

    private func loadGames() async {

        await MainActor.run {

            games = refreshed

            SharedDataStore.shared.save(
                games: refreshed
            )

            isLoading = false
        }

        do {

            let discovered =
                try await GameDiscoveryService.shared
                    .discoverGames(
                        from: sourceStore.sources
                    )

            let refreshed =
                try await GameDiscoveryService.shared
                    .refreshCCU(
                        for: discovered
                    )

            await MainActor.run {

                games = refreshed
                isLoading = false
            }

        } catch {

            await MainActor.run {

                errorMessage =
                    error.localizedDescription

                isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
}