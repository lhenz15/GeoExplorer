// ConfettiView.swift
// GeoExplorer
//
// A confetti burst built entirely from SwiftUI — no third-party packages.
// (SPM packages require Xcode's GUI to add; this gives you the same effect
//  and teaches you the animation tools along the way.)
//
// New concepts:
//
//   GeometryReader
//     Gives you the exact pixel size of the space your view occupies.
//     Here we use it to scatter pieces across the full screen width and
//     make them fall the full screen height — without hard-coding numbers
//     that would be wrong on different device sizes.
//
//   .position(x:y:)
//     Places a view's CENTER at exact coordinates relative to its parent.
//     Unlike .offset, it ignores the view's natural layout position.
//     We animate `y` from -20 (above the screen) down to the bottom.
//
//   Two separate withAnimation calls per piece
//     Each piece needs two animations: one to fall+spin, one to fade out
//     just before landing. You can run multiple `withAnimation` blocks
//     simultaneously on different properties — they don't conflict.
//
//   .allowsHitTesting(false)
//     Lets taps "pass through" the confetti layer to the buttons below.
//     Without this the confetti would block the Play Again / Back buttons.

import SwiftUI

// ── Data model for one piece ──────────────────────────────────────────────────
// A plain struct — no SwiftUI. Just the static, random data for one rectangle.
private struct Piece: Identifiable {
    let id           = UUID()
    let color        : Color
    let x            : CGFloat   // fixed horizontal position (points from left)
    let size         : CGFloat   // width; height is 45 % of width
    let delay        : Double    // seconds before this piece starts moving
    let finalY       : CGFloat   // destination y (near the bottom of the screen)
    let spinAmount   : Double    // total degrees rotated during the fall
}

// ── Animated view for one piece ───────────────────────────────────────────────
// Each instance handles its own animation so all 90 pieces run in parallel.
private struct PieceView: View {
    let piece: Piece

    // Two separate animated properties:
    @State private var y       : CGFloat = -20  // starts above the top edge
    @State private var angle   : Double  = 0
    @State private var opacity : Double  = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(piece.color)
            .frame(width: piece.size, height: piece.size * 0.45)
            .rotationEffect(.degrees(angle))
            // .position places the CENTER of this view at (x, y).
            .position(x: piece.x, y: y)
            .opacity(opacity)
            .onAppear {
                // ── Fall + spin ──────────────────────────────────────────────
                // easeIn: starts slow (like gravity just taking hold),
                // accelerates as the piece falls — matches real physics.
                withAnimation(
                    .easeIn(duration: 2.4).delay(piece.delay)
                ) {
                    y     = piece.finalY
                    angle = piece.spinAmount
                }
                // ── Fade out just before landing ─────────────────────────────
                // Starts 0.5 s before the fall ends so pieces dissolve
                // gracefully rather than popping off screen.
                withAnimation(
                    .linear(duration: 0.5).delay(piece.delay + 2.0)
                ) {
                    opacity = 0
                }
            }
    }
}

// ── Full confetti overlay ─────────────────────────────────────────────────────
struct ConfettiView: View {

    // Six festive colours that pop in both light and dark mode.
    private static let palette: [Color] = [
        Color(red: 1.00, green: 0.42, blue: 0.42),  // coral
        Color(red: 1.00, green: 0.65, blue: 0.00),  // orange
        Color(red: 1.00, green: 0.84, blue: 0.00),  // yellow
        Color(red: 0.40, green: 0.80, blue: 0.50),  // green
        Color(red: 0.45, green: 0.72, blue: 1.00),  // sky blue
        Color(red: 0.75, green: 0.60, blue: 1.00),  // lavender
    ]

    // Pieces are stored in @State so they're created ONCE on first appear
    // and never re-randomised when the view re-renders.
    @State private var pieces: [Piece] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { p in
                    PieceView(piece: p)
                }
            }
            .onAppear {
                // Guard prevents re-creating pieces if onAppear fires twice.
                guard pieces.isEmpty else { return }
                pieces = (0..<90).map { _ in
                    Piece(
                        color      : Self.palette.randomElement()!,
                        x          : CGFloat.random(in: 0...geo.size.width),
                        size       : CGFloat.random(in: 7...13),
                        delay      : Double.random(in: 0...1.6),
                        finalY     : CGFloat.random(
                                         in: geo.size.height * 0.6 ... geo.size.height + 40
                                     ),
                        spinAmount : Double.random(in: 200...720)
                    )
                }
            }
        }
        // Don't block taps on the buttons sitting behind the confetti.
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
