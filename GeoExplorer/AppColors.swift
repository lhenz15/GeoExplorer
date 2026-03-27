// AppColors.swift
// GeoExplorer
//
// The app's complete colour and style toolkit.
//
// New concepts used here:
//
//   UIColor(dynamicProvider:)
//     A closure-based UIColor that SwiftUI re-evaluates whenever the user
//     switches between Light and Dark Mode. We wrap it in Color(UIColor:)
//     so every SwiftUI view that reads AppColors automatically adapts —
//     no `@Environment(\.colorScheme)` checks needed anywhere.
//
//   UIColor hex init
//     A tiny private extension that lets us write colours as "4F46E5"
//     instead of the verbose UIColor(red:green:blue:alpha:).
//
//   ViewModifier
//     A protocol that packages a set of view modifiers into one reusable,
//     named unit — similar to how a ButtonStyle packages a button's look.
//     Call `.modifier(MyModifier())` or define a shortcut on View.
//
//   DragGesture(minimumDistance: 0)
//     Unlike TapGesture, DragGesture fires an `onChanged` event the instant
//     a finger touches the screen (before any movement) AND an `onEnded`
//     event when the finger lifts. We use that to detect "is this view
//     currently being pressed?", which TapGesture can't tell us.
//
//   simultaneousGesture
//     Attaches a gesture WITHOUT consuming the parent's gestures. The
//     Button tap, NavigationLink, and List row still all fire normally.

import SwiftUI

// ── Colour palette ───────────────────────────────────────────────────────────
//
// Semantic names tell you what a colour is FOR, not just what it looks like.
// Change a value here and it updates everywhere in the app.
enum AppColors {

    /// Primary accent — buttons, active indicators, progress bars.
    /// Light #4F46E5 (deep indigo)  |  Dark #818CF8 (soft violet)
    static let accent = Color(
        UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(hex: "818CF8")
                : UIColor(hex: "4F46E5")
        }
    )

    /// Page / screen background — the canvas everything sits on.
    /// Light #FAF9F6 (warm off-white)  |  Dark #1C1A17 (warm near-black)
    static let background = Color(
        UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(hex: "1C1A17")
                : UIColor(hex: "FAF9F6")
        }
    )

    /// Card and container surface — sits one layer on top of `background`.
    /// Light #F2F0EB  |  Dark #2C2A26
    static let surface = Color(
        UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(hex: "2C2A26")
                : UIColor(hex: "F2F0EB")
        }
    )

    /// Always-indigo colours for the hero gradient — the same indigo in both
    /// Light and Dark Mode (unlike `accent` which adapts). Used in HomeView's
    /// hero banner and the Explore Countries feature card.
    static let gradientLeading  = Color(red: 79/255,  green: 70/255,  blue: 229/255)
    static let gradientTrailing = Color(red: 129/255, green: 140/255, blue: 248/255)
}

// ── UIColor hex convenience init ─────────────────────────────────────────────
//
// Swift doesn't ship with a hex-string initialiser, so we add one.
// The `#` prefix is stripped if present, then the six hex digits are split
// into red / green / blue channels expressed as CGFloat values in 0…1.
// `private` means this extension is only usable inside this file — the
// callers above are the only ones that need it.
private extension UIColor {
    convenience init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: h).scanHexInt64(&value)
        self.init(
            red  : CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >>  8) & 0xFF) / 255,
            blue : CGFloat( value        & 0xFF) / 255,
            alpha: 1
        )
    }
}

// ── Scale-on-press modifier ───────────────────────────────────────────────────
//
// Wraps any view so it shrinks to 97 % while a finger is held down,
// then springs back the instant the finger lifts. This gives every button
// instant physical feedback — the user sees a reaction before the action
// completes.
//
// HOW IT WORKS:
//   1. @State var pressed tracks whether a finger is currently down.
//   2. DragGesture(minimumDistance: 0) fires the moment the screen is
//      touched (onChanged) and when the finger lifts (onEnded).
//   3. simultaneousGesture lets the parent's tap/navigation still fire.
//   4. .animation(…, value: pressed) runs a spring whenever pressed changes.
struct ScaleOnPress: ViewModifier {
    @State private var pressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(pressed ? 0.97 : 1.0)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.65),
                value: pressed
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in if !pressed { pressed = true  } }
                    .onEnded   { _ in              pressed = false  }
            )
    }
}

extension View {
    /// Adds a subtle spring scale-down while the user is pressing the view.
    func scaleOnPress() -> some View { modifier(ScaleOnPress()) }
}

// ── Scale-on-press button style ───────────────────────────────────────────────
//
// A ButtonStyle is the correct way to add press animations to NavigationLink
// and Button controls. Unlike a ViewModifier with a DragGesture, ButtonStyle
// uses `configuration.isPressed` — a value the system provides directly —
// so it never competes with the navigation gesture recogniser.
//
// Use this on NavigationLink labels:
//   NavigationLink { Destination() } label: { myCard }
//   .buttonStyle(NavLinkPressStyle())
struct NavLinkPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.65),
                value: configuration.isPressed
            )
    }
}

// ── Screen-appear transition ──────────────────────────────────────────────────
//
// Fades and lightly scales in the view's content when it first appears.
// Apply to the top-level VStack or ScrollView inside pushed screens to
// layer a depth effect on top of the standard NavigationStack slide.
//
// Why both opacity AND scale?
//   • Opacity alone looks flat — a simple fade.
//   • Scale alone looks sudden — a pop.
//   • Together they match the "material entering the stage" feel that Apple
//     uses in Settings, App Store, and Maps detail screens.
struct ScreenAppear: ViewModifier {
    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .scaleEffect(visible ? 1 : 0.97)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    visible = true
                }
            }
    }
}

extension View {
    /// Fades and lightly scales the view in when it first enters the screen.
    func screenAppear() -> some View { modifier(ScreenAppear()) }
}
