import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Roblox CCU")
                    .font(.largeTitle)
                    .bold()

                Text("Loading...")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("All Games")
        }
    }
}

#Preview {
    ContentView()
}