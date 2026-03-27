// CountryMapView.swift
// GeoExplorer
//
// Displays a country's border as a filled polygon on a muted map.
// Used by MapQuizView as the visual "question" for the Map → Country mode.
//
// ── What is UIViewRepresentable? ─────────────────────────────────────────────
// SwiftUI is great for most UI, but some things only exist as UIKit classes —
// MKMapView is one of them.  UIViewRepresentable is a bridge protocol that
// lets you wrap any UIKit view so SwiftUI can create, update, and destroy it
// like any other SwiftUI view.
//
// You implement two required methods:
//   makeUIView(context:)    — called ONCE to create and configure the UIView.
//   updateUIView(_:context:) — called whenever SwiftUI re-renders this node
//                             (e.g. countryName changes to the next question).
//
// ── What is MKPolygon? ────────────────────────────────────────────────────────
// An MKPolygon is MapKit's way to represent a closed shape on the map.
// You hand it an array of CLLocationCoordinate2D (lat/lon structs) and it
// draws the outline.  To fill it with colour you also need an
// MKPolygonRenderer (returned from the delegate's rendererForOverlay method).
//
// ── What is MKStandardMapConfiguration? ─────────────────────────────────────
// Introduced in iOS 16, MKStandardMapConfiguration replaces the old
// `mapType` property as the way to describe what a map looks like.
// Setting it on `map.preferredConfiguration` is the modern approach.
// We use `emphasisStyle: .muted` which renders a minimal, low-contrast
// style that suppresses all country names, city names, and road labels —
// exactly what we need so the answer isn't printed on screen.
//
// ── What is a Coordinator? ────────────────────────────────────────────────────
// MKMapView uses the old delegate pattern from Objective-C days: you set a
// delegate object that receives callbacks like "please draw this overlay."
// UIViewRepresentable's makeCoordinator() creates that delegate object.
// The Coordinator lives as long as the SwiftUI view does, and SwiftUI passes
// it to makeUIView via context.coordinator so you can wire up the delegate.

import SwiftUI
import MapKit

struct CountryMapView: UIViewRepresentable {

    let countryName: String

    // ── Step 1: create the map ────────────────────────────────────────────────
    // makeUIView is called exactly once when SwiftUI first mounts this view.
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()

        // ── Suppress all labels (iOS 16+) ─────────────────────────────────────
        // MKStandardMapConfiguration is the modern replacement for mapType.
        // emphasisStyle: .muted produces a minimal basemap with no country
        // names, city names, or region labels — critical for a quiz where
        // the answer must not appear on screen.
        // pointOfInterestFilter: .excludingAll removes all POI icons/labels.
        if #available(iOS 16.0, *) {
            let config                  = MKStandardMapConfiguration(elevationStyle: .flat,
                                                                      emphasisStyle : .muted)
            config.pointOfInterestFilter = .excludingAll
            config.showsTraffic          = false
            map.preferredConfiguration   = config
        } else {
            // Fallback for iOS 15 — still muted but labels may show
            map.mapType             = .mutedStandard
            map.pointOfInterestFilter = .excludingAll
        }

        // Belt-and-suspenders: these older properties are checked in addition
        // to the configuration above.  They have no effect on iOS 16+ when
        // preferredConfiguration is set, but they guard against any edge case
        // where MapKit falls back to the legacy rendering path.
        map.showsPointsOfInterest = false
        map.showsTraffic          = false
        map.showsBuildings        = false
        map.showsCompass          = false
        map.showsScale            = false

        // Lock the camera — students tap answer buttons, not the map.
        map.isScrollEnabled = false
        map.isZoomEnabled   = false
        map.isRotateEnabled = false
        map.isPitchEnabled  = false

        // Wire up the delegate so MapKit calls our Coordinator when it
        // needs to draw the polygon overlay.
        map.delegate = context.coordinator

        return map
    }

    // ── Step 2: update when data changes ─────────────────────────────────────
    // updateUIView is called every time SwiftUI re-renders this node.
    // That happens when countryName changes (next question) or when the
    // parent view's state changes.  We remove old overlays and add new ones.
    func updateUIView(_ map: MKMapView, context: Context) {
        map.removeOverlays(map.overlays)

        guard let shape = ShapeLoader.shapes[countryName] else { return }

        var allCoords: [CLLocationCoordinate2D] = []

        // Each ring in shape.polygons is one land mass (mainland, island, etc.).
        // We add EVERY ring as its own MKPolygon overlay so archipelagos like
        // Indonesia, Philippines, and the Bahamas show all their islands.
        for ring in shape.polygons {
            // Convert our [lat, lon] arrays into CLLocationCoordinate2D structs.
            var coords = ring.map {
                CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1])
            }
            // MKPolygon(coordinates:count:) takes an UnsafeMutablePointer —
            // passing &coords gives it a pointer to the first element of the array.
            let polygon = MKPolygon(coordinates: &coords, count: coords.count)
            map.addOverlay(polygon, level: .aboveRoads)
            allCoords.append(contentsOf: coords)
        }

        fitCamera(map, to: allCoords)
    }

    // ── Step 3: create the coordinator ───────────────────────────────────────
    func makeCoordinator() -> Coordinator { Coordinator() }

    // ── Camera fit ────────────────────────────────────────────────────────────
    // Calculates the bounding box of all polygon points and sets a region
    // that shows the whole country with 40 % padding so neighbouring countries
    // are visible for geographic context.
    private func fitCamera(_ map: MKMapView, to coords: [CLLocationCoordinate2D]) {
        guard !coords.isEmpty else { return }

        let lats = coords.map(\.latitude)
        let lons = coords.map(\.longitude)

        let minLat = lats.min()!, maxLat = lats.max()!
        let minLon = lons.min()!, maxLon = lons.max()!

        let latPad = (maxLat - minLat) * 0.4
        let lonPad = (maxLon - minLon) * 0.4

        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude : (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta : max(maxLat - minLat + latPad * 2, 1.0),
                longitudeDelta: max(maxLon - minLon + lonPad * 2, 1.0)
            )
        )
        map.setRegion(region, animated: false)
    }

    // ── Coordinator: MKMapViewDelegate ────────────────────────────────────────
    // The Coordinator class handles delegate callbacks from MKMapView.
    // NSObject is required because Objective-C delegate protocols expect it.
    class Coordinator: NSObject, MKMapViewDelegate {

        // MapKit calls this whenever it needs to draw an overlay.
        // We return a custom MKPolygonRenderer with GeoExplorer's indigo colour.
        func mapView(_ mapView: MKMapView,
                     rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polygon = overlay as? MKPolygon else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolygonRenderer(polygon: polygon)

            // Fill: #4F46E5 at 60 % opacity — enough to see the country shape
            // without completely hiding the map underneath.
            renderer.fillColor = UIColor(red: 79/255, green: 70/255, blue: 229/255, alpha: 0.6)

            // Border: solid #4F46E5 so the edge is crisp.
            renderer.strokeColor = UIColor(red: 79/255, green: 70/255, blue: 229/255, alpha: 1.0)
            renderer.lineWidth   = 1.5

            return renderer
        }
    }
}
