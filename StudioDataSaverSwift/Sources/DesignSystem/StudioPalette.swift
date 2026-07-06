import SwiftUI

enum StudioPalette {
    static func appBackground(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.030, green: 0.032, blue: 0.042) : Color(red: 0.962, green: 0.962, blue: 0.948)
    }

    static func sidebar(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.055, green: 0.058, blue: 0.072) : Color(red: 0.928, green: 0.928, blue: 0.910)
    }

    static func terminal(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.018, green: 0.020, blue: 0.028) : Color(red: 0.992, green: 0.988, blue: 0.965)
    }

    static func panel(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.105, green: 0.108, blue: 0.128) : Color(red: 0.982, green: 0.978, blue: 0.952)
    }

    static func selectedPanel(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.150, green: 0.156, blue: 0.186) : Color(red: 0.882, green: 0.908, blue: 0.892)
    }

    static func primaryText(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.900, green: 0.915, blue: 0.940) : Color(red: 0.095, green: 0.105, blue: 0.120)
    }

    static func secondaryText(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.570, green: 0.600, blue: 0.670) : Color(red: 0.390, green: 0.410, blue: 0.450)
    }

    static func border(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.11) : Color.black.opacity(0.12)
    }

    static func commandBand(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.150, green: 0.152, blue: 0.178) : Color(red: 0.900, green: 0.908, blue: 0.898)
    }

    static let accent = Color(red: 0.100, green: 0.780, blue: 0.650)
    static let cyan = Color(red: 0.270, green: 0.810, blue: 0.930)
    static let warning = Color(red: 0.950, green: 0.610, blue: 0.200)
    static let danger = Color(red: 0.900, green: 0.250, blue: 0.280)
}
