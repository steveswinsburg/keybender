import Foundation

/// Add new modes here. Implement `encode(_:)` and fill in the metadata below.
enum TranslationMode: String, CaseIterable, Equatable {
    case off
    case hex
    case binary
    case octal
    case decimal
    case morse
    case caesar
    case rot13
    case atbash
    case greek

    // MARK: - UI metadata

    var menuLabel: String {
        switch self {
        case .off:     return "Off"
        case .hex:     return "Hex        (A → \\x41)"
        case .binary:  return "Binary     (A → 01000001)"
        case .octal:   return "Octal      (A → \\101)"
        case .decimal: return "Decimal    (A → 65)"
        case .morse:   return "Morse      (A → ·−)"
        case .caesar:  return "Caesar +3  (A → D)"
        case .rot13:   return "ROT13      (A → N)"
        case .atbash:  return "Atbash     (A → Z)"
        case .greek:   return "Greek      (A → Α)"
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
        case .caesar:  return "⌨ C3"
        case .rot13:   return "⌨ R13"
        case .atbash:  return "⌨ ATB"
        case .greek:   return "⌨ GRK"
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
        case .caesar:  return "6"
        case .rot13:   return "7"
        case .atbash:  return "8"
        case .greek:   return "9"
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

        case .caesar:
            return Self.shiftAlphabetic(char, by: 3)

        case .rot13:
            return Self.shiftAlphabetic(char, by: 13)

        case .atbash:
            return Self.atbash(char)

        case .greek:
            return Self.greekTable[char]
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

    private static let greekTable: [Character: String] = [
        "A": "Α", "B": "Β", "C": "Ϲ", "D": "Δ", "E": "Ε", "F": "Φ", "G": "Γ",
        "H": "Η", "I": "Ι", "J": "Ξ", "K": "Κ", "L": "Λ", "M": "Μ", "N": "Ν",
        "O": "Ο", "P": "Π", "Q": "Θ", "R": "Ρ", "S": "Σ", "T": "Τ", "U": "Υ",
        "V": "Ω", "W": "Ψ", "X": "Χ", "Y": "Υ", "Z": "Ζ",
        "a": "α", "b": "β", "c": "ϲ", "d": "δ", "e": "ε", "f": "φ", "g": "γ",
        "h": "η", "i": "ι", "j": "ξ", "k": "κ", "l": "λ", "m": "μ", "n": "ν",
        "o": "ο", "p": "π", "q": "θ", "r": "ρ", "s": "σ", "t": "τ", "u": "υ",
        "v": "ω", "w": "ψ", "x": "χ", "y": "υ", "z": "ζ"
    ]

    private static func shiftAlphabetic(_ char: Character, by shift: Int) -> String? {
        guard let scalar = char.unicodeScalars.first, scalar.isASCII else { return nil }
        let value = Int(scalar.value)
        let base: Int

        switch value {
        case 65...90: base = 65
        case 97...122: base = 97
        default: return nil
        }

        let offset = (value - base + shift) % 26
        return String(UnicodeScalar(base + offset)!)
    }

    private static func atbash(_ char: Character) -> String? {
        guard let scalar = char.unicodeScalars.first, scalar.isASCII else { return nil }
        let value = Int(scalar.value)

        switch value {
        case 65...90:
            return String(UnicodeScalar(90 - (value - 65))!)
        case 97...122:
            return String(UnicodeScalar(122 - (value - 97))!)
        default:
            return nil
        }
    }
}
