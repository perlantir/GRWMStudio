#!/usr/bin/env swift

import Foundation

struct PaletteColor {
    struct RGB {
        let red: Double
        let green: Double
        let blue: Double
    }

    let name: String
    let hex: String

    var rgb: RGB {
        let sanitized = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let value = Int(sanitized, radix: 16) ?? 0
        return RGB(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }

    var luminance: Double {
        func linearize(_ channel: Double) -> Double {
            channel <= 0.03928 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
        }

        return (0.2126 * linearize(rgb.red))
            + (0.7152 * linearize(rgb.green))
            + (0.0722 * linearize(rgb.blue))
    }
}

struct ContrastRule {
    let label: String
    let foreground: PaletteColor
    let background: PaletteColor
    let minimumRatio: Double
}

let white = PaletteColor(name: "white", hex: "#FFFFFF")
let pink = PaletteColor(name: "pink", hex: "#FF3DA5")
let pinkDeep = PaletteColor(name: "pinkDeep", hex: "#D4127B")
let pinkLight = PaletteColor(name: "pinkLight", hex: "#FFB8DC")
let pinkPaper = PaletteColor(name: "pinkPaper", hex: "#FFE5F2")
let cream = PaletteColor(name: "cream", hex: "#FFF6FA")
let butter = PaletteColor(name: "butter", hex: "#FFD66B")
let mint = PaletteColor(name: "mint", hex: "#A8E8C8")
let lavenderDeep = PaletteColor(name: "lavenderDeep", hex: "#7A53C9")
let ink = PaletteColor(name: "ink", hex: "#3A0E25")
let recRed = PaletteColor(name: "recRed", hex: "#FF2D5A")

let rules: [ContrastRule] = [
    ContrastRule(label: "Primary button copy", foreground: white, background: pink, minimumRatio: 3.0),
    ContrastRule(label: "White button copy", foreground: pinkDeep, background: white, minimumRatio: 4.5),
    ContrastRule(label: "Butter button copy", foreground: ink, background: butter, minimumRatio: 4.5),
    ContrastRule(label: "Mint surface body text", foreground: ink, background: mint, minimumRatio: 4.5),
    ContrastRule(label: "Body text on cream", foreground: ink, background: cream, minimumRatio: 4.5),
    ContrastRule(label: "Body text on pink paper", foreground: ink, background: pinkPaper, minimumRatio: 4.5),
    ContrastRule(label: "Large headline on pink paper", foreground: pinkDeep, background: pinkPaper, minimumRatio: 3.0),
    ContrastRule(label: "Large headline on pink light", foreground: pinkDeep, background: pinkLight, minimumRatio: 3.0),
    ContrastRule(label: "Badge copy on pink deep", foreground: white, background: pinkDeep, minimumRatio: 4.5),
    ContrastRule(label: "Large label on recording red", foreground: white, background: recRed, minimumRatio: 3.0),
    ContrastRule(label: "Large label on lavender deep", foreground: white, background: lavenderDeep, minimumRatio: 4.5),
    ContrastRule(label: "Deep text on cream", foreground: pinkDeep, background: cream, minimumRatio: 4.5)
]

func contrastRatio(foreground: PaletteColor, background: PaletteColor) -> Double {
    let lighter = max(foreground.luminance, background.luminance)
    let darker = min(foreground.luminance, background.luminance)
    return (lighter + 0.05) / (darker + 0.05)
}

var failures: [String] = []

for rule in rules {
    let ratio = contrastRatio(foreground: rule.foreground, background: rule.background)
    let status = ratio >= rule.minimumRatio ? "PASS" : "FAIL"
    let paddedLabel = rule.label.padding(toLength: 28, withPad: " ", startingAt: 0)
    let ratioText = String(format: "%.2f", ratio)
    let minimumText = String(format: "%.2f", rule.minimumRatio)
    let line = "\(status)  \(paddedLabel) \(rule.foreground.name) on \(rule.background.name)  \(ratioText) (min \(minimumText))"
    print(line)

    if ratio < rule.minimumRatio {
        failures.append(line)
    }
}

if failures.isEmpty {
    print("Contrast audit complete: 0 failures.")
    exit(EXIT_SUCCESS)
}

fputs("Contrast audit found \(failures.count) failure(s).\n", stderr)
exit(EXIT_FAILURE)
