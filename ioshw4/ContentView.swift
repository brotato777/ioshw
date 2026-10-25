import SwiftUI

struct ContentView: View {
    @State private var destination = ""
    @State private var result: DrawResult?
    /// 每次抽取時累加，用來讓卡片翻轉一圈
    @State private var spin = 0.0
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text("今天怎麼去？")
                .font(.largeTitle.bold())

            TextField("想去哪裡？", text: $destination)
                .textFieldStyle(.roundedBorder)
                .focused($isFieldFocused)
                .submitLabel(.done)

            Image(result?.move.imageName ?? "move_card_back")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 240)
                .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
                .rotation3DEffect(.degrees(spin), axis: (x: 0, y: 1, z: 0))
                .accessibilityLabel(result?.move.name ?? "未抽取的卡片")

            if let result {
                ResultInfo(result: result)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Text("輸入目的地，抽一個推薦的移動方式")
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Button(action: draw) {
                Label("抽取", systemImage: "shuffle")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(result?.move.themeColor ?? .accentColor)
        }
        .padding(24)
    }

    private func draw() {
        isFieldFocused = false
        let trimmed = destination.trimmingCharacters(in: .whitespacesAndNewlines)
        let newResult = DrawResult(
            destination: trimmed.isEmpty ? "目的地" : trimmed,
            move: Move.weightedRandom(),
            seconds: TravelTime.random()
        )
        withAnimation(.spring(duration: 0.6)) {
            spin += 360
            result = newResult
        }
    }
}

/// 抽取結果：稀有度、移動方式、預估時間、玩法說明
private struct ResultInfo: View {
    let result: DrawResult

    var body: some View {
        VStack(spacing: 10) {
            Text(result.move.rarity.label)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(result.move.rarity.color, in: .capsule)

            Text("推薦你\(result.move.name)去\(result.destination)")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Label("預估 \(TravelTime.format(result.seconds))", systemImage: "clock")
                .font(.headline)
                .foregroundStyle(result.move.themeColor)

            Text(result.move.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ContentView()
}
