import Foundation

/// Add new modes here. Implement `encode(_:)` and fill in the metadata below.
enum TranslationMode: String, CaseIterable, Equatable {
    case off
    case hex
    case binary
    case octal
    case decimal
    case morse

    // MARK: - UI metadata

    var menuLabel: String {
        switch self {
        case .off:     return "Off"
        case .hex:     return "Hex        (A → \\x41)"
        case .binary:  return "Binary     (A → 01000001)"
        case .octal:   return "Octal      (A → \\101)"
        case .decimal: return "Decimal    (A → 65)"
        case .morse:   return "Morse      (A → ·−)"
        }
    }

    var statusBarLabel: String {
        switch self {
        case .off:     return "⌨ OFF"
        case .hex:     return "⌨ HEX"
        case .binary:  return "⌨ BIN"
        case .octal:   return "⌨ OCT"
        case .decimal: return "⌨ DEC"
        case .morse:   return "⌨ ···"
        }
    }

    /// ⌘⇧<key> shortcut shown in the menu
    var keyEquivalent: String {
        switch self {
        case .off:     return "0"
        case .hex:     return "1"
        case .binary:  return "2"
        case .octal:   return "3"
        case .decimal: return "4"
        case .morse:   return "5"
        }
    }

    // MARK: - Encoding

    /// Returns the encoded representation of `char`, or `nil` if encoding
    /// is not applicable (e.g. `.off` mode or unrecognised morse character).
    func encode(_ char: Character) -> String? {
        guard self != .off else { return nil }
        guard let scalar = char.unicodeScalars.first else { return nil }
        let value = Int(scalar.value)

        switch self {
        case .off:
            return nil

        case .hex:
            return String(format: "\\x%02X", value)

        case .binary:
            let raw = String(value, radix: 2)
            let width = value > 0xFF ? 16 : 8
            return String(repeating: "0", count: max(0, width - raw.count)) + raw

        case .octal:
            return String(format: "\\%03o", value)

        case .decimal:
            return "\(value)"

        case .morse:
            guard let morse = Self.morseTable[Character(char.lowercased())] else {
                return nil
            }
            return morse + " "
        }
    }

    // MARK: - Morse table

    private static let morseTable: [Character: String] = [
        "a": "·−",   "b": "−···", "c": "−·−·", "d": "−··",  "e": "·",
        "f": "··−·", "g": "−−·",  "h": "····",  "i": "··",   "j": "·−−−",
        "k": "−·−",  "l": "·−··", "m": "−−",    "n": "−·",   "o": "−−−",
        "p": "·−−·", "q": "−−·−", "r": "·−·",   "s": "···",  "t": "−",
        "u": "··−",  "v": "···−", "w": "·−−",   "x": "−··−", "y": "−·−−",
        "z": "−−··",
        "0": "−−−−−", "1": "·−−−−", "2": "··−−−", "3": "···−−", "4": "····−",
        "5": "·····", "6": "−····", "7": "−−···", "8": "−−−··", "9": "−−−−·",
        " ": "/"
    ]
}
