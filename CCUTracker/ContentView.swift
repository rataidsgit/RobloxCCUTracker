import SwiftUI

struct ContentView: View {

    @StateObject
    private var sourceStore = SourceStore.shared

    @State private var games: [RobloxGame] = []

    @State private var isLoading = false

    @State private var errorMessage:
        String?

    @State private var showingSources = false

    @State private var lastUpdated:
        Date?

    // MARK: - Computed Properties

    private var totalCCU: Int {

        games.reduce(0) {
            $0 + $1.currentCCU
        }
    }

    private var sortedGames:
        [RobloxGame] {

        games.sorted {
            $0.currentCCU > $1.currentCCU
        }
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            Group {

                if isLoading && games.isEmpty {

                    ProgressView(
                        "Loading Roblox games..."
                    )

                } else if let errorMessage,
                          games.isEmpty {

                    errorView(
                        message: errorMessage
                    )

                } else {

                    gameList
                }
            }

            .navigationTitle(
                "Roblox CCU"
            )

            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button {

                        showingSources = true

                    } label: {

                        Image(
                            systemName:
                                "gearshape"
                        )
                    }
                }
            }

            .sheet(
                isPresented:
                    $showingSources
            ) {

                SourcesView()
            }

            .task {

                // Only load automatically if
                // we don't already have data.

                if games.isEmpty {

                    await loadGames()
                }
            }

            .refreshable {

                await loadGames()
            }
        }
    }

    // MARK: - Game List

    private var gameList: some View {

        List {

            Section {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(
                        totalCCU.formatted()
                    )
                    .font(
                        .system(
                            size: 36,
                            weight: .bold
                        )
                    )
                    .monospacedDigit()

                    Text("Total CCU")
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )

                    HStack(
                        spacing: 6
                    ) {

                        if isLoading {

                            ProgressView()
                                .controlSize(
                                    .mini
                                )

                            Text(
                                "Refreshing..."
                            )

                        } else if let lastUpdated {

                            Image(
                                systemName:
                                    "clock"
                            )

                            Text(
                                "Updated "
                                + lastUpdated,
                                style: .relative
                            )
                        }

                        Spacer()
                    }
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                    .padding(
                        .top,
                        4
                    )
                }
                .padding(
                    .vertical,
                    8
                )

            }

            Section(
                "Games"
            ) {

                ForEach(
                    sortedGames
                ) { game in

                    HStack {

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text(game.name)
                                .font(
                                    .headline
                                )

                            if let creatorName =
                                game.creatorName {

                                Text(
                                    creatorName
                                )
                                .font(
                                    .caption
                                )
                                .foregroundStyle(
                                    .secondary
                                )
                            }
                        }

                        Spacer()

                        Text(
                            game.currentCCU
                                .formatted()
                        )
                        .font(
                            .system(
                                size: 17,
                                weight: .semibold
                            )
                        )
                        .monospacedDigit()
                    }
                    .padding(
                        .vertical,
                        3
                    )
                }
            }
        }
    }

    // MARK: - Error

    private func errorView(
        message: String
    ) -> some View {

        VStack(
            spacing: 12
        ) {

            Image(
                systemName:
                    "exclamationmark.triangle"
            )
            .font(.largeTitle)

            Text(
                "Couldn't load games"
            )
            .font(.headline)

            Text(message)
                .font(.subheadline)
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
            .buttonStyle(
                .borderedProminent
            )
        }
        .padding()
    }

    // MARK: - Load Games

    @MainActor
    private func loadGames() async {

        guard !isLoading else {
            return
        }

        isLoading = true

        errorMessage = nil

        do {

            let discovered =
                try await
                    GameDiscoveryService.shared
                    .discoverGames(
                        from:
                            sourceStore.sources
                    )

            let refreshed =
                try await
                    GameDiscoveryService.shared
                    .refreshCCU(
                        for: discovered
                    )

            games = refreshed

            lastUpdated = Date()

            SharedDataStore.shared.save(
                games: refreshed
            )

            isLoading = false

        } catch {

            errorMessage =
                error.localizedDescription

            isLoading = false
        }
    }
}