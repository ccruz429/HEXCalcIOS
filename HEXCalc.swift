import SwiftUI

// Enum for Calculator Buttons
enum CalculatorButtons: String, CaseIterable {
    case one = "1", two = "2", three = "3", four = "4", five = "5", six = "6"
    case seven = "7", eight = "8", nine = "9", zero = "0"
    case clear = "AC"
    case hex = "HEX"
    case hexA = "A", hexB = "B", hexC = "C", hexD = "D", hexE = "E", hexF = "F"

    var buttonColor: Color {
        switch self {
        case .clear, .hex: return Color(.systemGray)
        case .hexA, .hexB, .hexC, .hexD, .hexE, .hexF: return Color(.systemBlue)
        default: return Color.orange
        }
    }
}

// ContentView
struct ContentView: View {
    @State private var value = "0"
    @State private var isHexMode = false

    // Buttons shown in grid; grid adapts when hex mode is ON
    private var gridButtons: [CalculatorButtons] {
        if isHexMode {
            // show HEX toggle + AC + A-F + numbers
            return [.hex, .clear,
                    .hexA, .hexB, .hexC, .hexD, .hexE, .hexF,
                    .seven, .eight, .nine, .four,
                    .five, .six, .three, .two,
                    .one, .zero]
        } else {
            // decimal mode: no A-F buttons
            return [.hex, .clear,
                    .seven, .eight, .nine, .four,
                    .five, .six, .three, .two,
                    .one, .zero]
        }
    }

    // 4 columns grid
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(value)
                        .bold()
                        .font(.system(size: 64))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                }
                .padding()

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(gridButtons, id: \.self) { item in
                        Button(action: { self.buttonTap(button: item) }) {
                            Text(item.rawValue)
                                .font(.system(size: 24, weight: .semibold))
                                .frame(maxWidth: .infinity, minHeight: 64)
                                .background(item.buttonColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Conversion helpers
    private func decimalToHex(_ s: String) -> String? {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let n = UInt64(trimmed, radix: 10) else { return nil }
        return String(n, radix: 16).uppercased()
    }

    private func hexToDecimal(_ s: String) -> String? {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let n = UInt64(trimmed, radix: 16) else { return nil }
        return String(n)
    }

    // MARK: - Button handling
    private func appendDigit(_ char: String) {
        if value == "0" {
            value = char
        } else {
            value += char
        }
    }

    func buttonTap(button: CalculatorButtons) {
        switch button {
        case .clear:
            value = "0"
        case .hex:
            // Convert according to current mode, then toggle the mode
            if isHexMode {
                // currently hex -> convert to decimal
                if let dec = hexToDecimal(value) {
                    value = dec
                } else {
                    value = "0" // fallback if parse fails
                }
                isHexMode = false
            } else {
                // currently decimal -> convert to hex
                if let hex = decimalToHex(value) {
                    value = hex
                } else {
                    value = "0"
                }
                isHexMode = true
            }
        case .hexA, .hexB, .hexC, .hexD, .hexE, .hexF:
            // Only accept A-F while in hex mode
            guard isHexMode else { return }
            appendDigit(button.rawValue)
        case .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .zero:
            appendDigit(button.rawValue)
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
