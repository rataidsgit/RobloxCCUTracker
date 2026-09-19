import SwiftUI

struct ContentView: View {

    @State private var games: [RobloxGame] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    // TEMPORARY:
    // Replace these with your actual IDs.
    private let sources: [RobloxSource] = [

        .init(
            type: .user,
            value: 71800600,
            name: "ratty"
        ),

        .init(
            type: .group,
            value: 6770993,
            name: "Mousetrap Studios"
        ),

        .init(
            type: .group,
            value: 35153760,
            name: "Mousetrap Brainrot"
        ),

        .init(
            type: .group,
            value: 35483952,
            name: "SUMMIT!"
        ),

        .init(
            type: .group,
            value: 34922411,
            name: "Mousetrap Midnight"
        )
    ]

    var body: some View {
        NavigationStack {
            Group {

                if isLoading {
                    ProgressView("Loading Roblox games...")
                }

                else if let errorMessage {
                    VStack(spacing: 12) {
                        Text("Couldn't load games")
                            .font(.headline)

                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Retry") {
                            Task {
                                await loadGames()
                            }
                        }
                    }
                    .padding()
                }

                else if games.isEmpty {
                    ContentUnavailableView(
                        "No Games",
                        systemImage: "gamecontroller",
                        description: Text(
                            "Add a Roblox User, Group, or Game ID."
                        )
                    )
                }

                else {
                    gameList
                }
            }
            .navigationTitle("Roblox CCU")
            .task {
                await loadGames()
            }
            .refreshable {
                await loadGames()
            }
        }
    }

    private var gameList: some View {

        List {

            Section {
                VStack(spacing: 4) {
                    Text("\(totalCCU)")
                        .font(.system(
                            size: 42,
                            weight: .bold
                        ))

                    Text("TOTAL CCU")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }

            Section("Games") {

                ForEach(
                    games.sorted {
                        $0.currentCCU > $1.currentCCU
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

    private func loadGames() async {

        isLoading = true
        errorMessage = nil

        do {

            let discovered =
                try await GameDiscoveryService.shared
                    .discoverGames(
                        from: sources
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