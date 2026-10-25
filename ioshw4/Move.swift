import SwiftUI

/// 移動方式的稀有度
enum Rarity: String {
    case common
    case rare
    case legendary

    var label: String {
        switch self {
        case .common: "基礎"
        case .rare: "搞怪"
        case .legendary: "傳說"
        }
    }

    var color: Color {
        switch self {
        case .common: Color(hex: 0x3A7BC8)
        case .rare: Color(hex: 0xE8456B)
        case .legendary: Color(hex: 0x4CC93B)
        }
    }
}

/// 一種移動方式
struct Move: Identifiable {
    let id: String
    let name: String
    let rarity: Rarity
    /// 抽中權重（全部加總為 100，等於百分比）
    let weight: Int
    let description: String
    let imageName: String
    let themeColor: Color
}

/// 一次抽取的結果
struct DrawResult {
    let destination: String
    let move: Move
    /// 預估所需時間（秒）
    let seconds: Double
}

extension Move {
    static let all: [Move] = [
        Move(id: "walk", name: "走路", rarity: .common, weight: 12,
             description: "最樸實的選擇，用兩條腿正常走過去就好。",
             imageName: "move_walk", themeColor: Color(hex: 0x3A7BC8)),
        Move(id: "bike", name: "騎腳踏車", rarity: .common, weight: 12,
             description: "騎上腳踏車（或 YouBike）出發。",
             imageName: "move_bike", themeColor: Color(hex: 0x2E9C6C)),
        Move(id: "bus", name: "搭公車", rarity: .common, weight: 12,
             description: "走到最近的站牌，搭公車（或捷運）到目的地。",
             imageName: "move_bus", themeColor: Color(hex: 0xE08A1E)),
        Move(id: "front_flip", name: "前空翻", rarity: .rare, weight: 6,
             description: "每前進十步要來一個前空翻；做不到就原地轉一圈並大喊「空翻！」代替。",
             imageName: "move_front_flip", themeColor: Color(hex: 0xE8456B)),
        Move(id: "moonwalk", name: "月球漫步", rarity: .rare, weight: 6,
             description: "全程倒退滑步前進，記得偶爾回頭看路。",
             imageName: "move_moonwalk", themeColor: Color(hex: 0x2E2A78)),
        Move(id: "shopping_cart", name: "搭購物車", rarity: .rare, weight: 6,
             description: "坐進購物車讓朋友推你過去；沒有購物車就讓朋友推著你的肩膀走。",
             imageName: "move_shopping_cart", themeColor: Color(hex: 0xFF5E62)),
        Move(id: "broom", name: "騎掃把飛行", rarity: .rare, weight: 6,
             description: "把掃把或雨傘夾在腿間，一路小跑步並自己配起飛音效。",
             imageName: "move_broom", themeColor: Color(hex: 0x4776E6)),
        Move(id: "rocket", name: "火箭發射", rarity: .rare, weight: 6,
             description: "起跑前蹲下倒數 10 秒，喊「發射！」後全速衝刺 20 公尺，接著慢慢滑翔。",
             imageName: "move_rocket", themeColor: Color(hex: 0xF09819)),
        Move(id: "office_chair", name: "辦公椅滑行", rarity: .rare, weight: 6,
             description: "坐在有輪子的椅子上用腳划過去（限室內平地）。",
             imageName: "move_office_chair", themeColor: Color(hex: 0x0B7F7A)),
        Move(id: "invisible_horse", name: "騎隱形駿馬", rarity: .rare, weight: 6,
             description: "雙手握住看不見的韁繩，用小跳步奔馳前進，馬蹄聲請自備。",
             imageName: "move_invisible_horse", themeColor: Color(hex: 0xE8476B)),
        Move(id: "butterfly", name: "蝴蝶飛舞", rarity: .rare, weight: 6,
             description: "雙手當翅膀拍動、一路轉圈飄過去，遇到花要停下來聞一下。",
             imageName: "move_butterfly", themeColor: Color(hex: 0x5B8DEF)),
        Move(id: "statue_teleport", name: "木頭人瞬移", rarity: .rare, weight: 6,
             description: "只有沒人在看你時才能移動；一被看到就要立刻定格不動。",
             imageName: "move_statue_teleport", themeColor: Color(hex: 0x0A78B5)),
        Move(id: "zombie_chihuahua", name: "搭乘銀色殭屍吉娃娃", rarity: .legendary, weight: 10,
             description: "跨上你的銀色殭屍吉娃娃，用顫抖的小碎步前進；每走十步要對空氣「嗷嗚」一聲。",
             imageName: "move_zombie_chihuahua", themeColor: Color(hex: 0x120A1F)),
    ]

    /// 依權重隨機抽一種移動方式
    static func weightedRandom() -> Move {
        let total = all.reduce(0) { $0 + $1.weight }
        var roll = Int.random(in: 0..<total)
        for move in all {
            if roll < move.weight { return move }
            roll -= move.weight
        }
        return all[0]
    }
}

// MARK: - 預估時間

enum TravelTime {
    /// 普朗克時間（秒）
    static let planck = 5.391e-44
    /// 一兆年（秒）
    static let trillionYears = 1e12 * 31_557_600.0

    /// 隨機產生預估時間：4 成機率落在「正常」的 1 分鐘～3 小時，
    /// 其餘在普朗克時間到一兆年之間以對數均勻分佈，讓結果誇張又好笑
    static func random() -> Double {
        let (low, high) = Double.random(in: 0..<1) < 0.4
            ? (60.0, 3 * 3600.0)
            : (planck, trillionYears)
        return pow(10, Double.random(in: log10(low)...log10(high)))
    }

    /// 把秒數轉成好讀的中文字串，例如「3.2 億年」「約 1.5 垓個普朗克時間」
    static func format(_ seconds: Double) -> String {
        let year = 31_557_600.0
        let units: [(String, Double)] = [
            ("毫秒", 1e-3), ("微秒", 1e-6), ("奈秒", 1e-9), ("皮秒", 1e-12), ("飛秒", 1e-15),
        ]
        switch seconds {
        case ..<1e-15:
            return "\(bigNumber(seconds / planck)) 個普朗克時間"
        case ..<1:
            let (name, size) = units.first { seconds >= $0.1 } ?? units[units.count - 1]
            return "\(bigNumber(seconds / size)) \(name)"
        case ..<60:
            return "\(bigNumber(seconds)) 秒"
        case ..<3600:
            return "\(bigNumber(seconds / 60)) 分鐘"
        case ..<86400:
            return "\(bigNumber(seconds / 3600)) 小時"
        case ..<year:
            return "\(bigNumber(seconds / 86400)) 天"
        default:
            return "\(bigNumber(seconds / year)) 年"
        }
    }

    /// 用中文大數單位（萬、億、兆、京、垓、秭、穰）表示數字
    private static func bigNumber(_ value: Double) -> String {
        let scales: [(String, Double)] = [
            ("穰", 1e28), ("秭", 1e24), ("垓", 1e20), ("京", 1e16),
            ("兆", 1e12), ("億", 1e8), ("萬", 1e4),
        ]
        for (name, size) in scales where value >= size {
            return decimal(value / size) + " " + name
        }
        return decimal(value)
    }

    private static func decimal(_ value: Double) -> String {
        value < 10
            ? value.formatted(.number.precision(.fractionLength(0...1)))
            : value.formatted(.number.precision(.fractionLength(0)).grouping(.never))
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
