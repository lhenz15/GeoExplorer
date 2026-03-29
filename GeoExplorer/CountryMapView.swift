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
// ── What is MKImageryMapConfiguration? ───────────────────────────────────────
// Introduced in iOS 16, MKImageryMapConfiguration renders pure satellite
// imagery with zero labels — no country names, city names, road names, or
// POI markers.  This guarantees the answer can never appear on screen,
// unlike the standard map which can still show text through feature labels.
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

        // ── Map configuration (iOS 16+) ───────────────────────────────────────
        // MKImageryMapConfiguration shows pure satellite imagery — no labels,
        // no POIs, no road names.  elevationStyle: .flat keeps it 2D.
        // selectableMapFeatures = [] prevents tapping from showing a callout
        // that could reveal a country name.
        let config                 = MKImageryMapConfiguration(elevationStyle: .flat)
        map.preferredConfiguration = config
        map.selectableMapFeatures  = []

        map.showsCompass  = false
        map.showsScale    = false

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
    // Calculates the bounding box of all polygon points, then picks a zoom
    // strategy based on the great-circle diagonal of that box:
    //
    //   < 500 km  — tiny single islands (Nauru, San Marino…).
    //               10 % padding, 0.3° minimum span (~33 km per side).
    //               Without this, the 1.0° floor would make a 5 km island
    //               occupy less than 5 % of the screen.
    //
    //   500–1200 km — small/medium archipelagos (Maldives, Tuvalu, Seychelles…).
    //               Their atolls are individually tiny but the spread is real.
    //               10 % padding keeps the view tight; 1.0° floor ensures at
    //               least one atoll fills a reasonable fraction of the screen.
    //
    //   > 1200 km — large countries and continent-spanning archipelagos
    //               (Marshall Islands, Kiribati, Indonesia, Russia…).
    //               40 % padding provides geographic context.  Clamped to
    //               legal MapKit limits (lat ≤ 180, lon ≤ 360) to prevent
    //               the NSInvalidArgumentException crash seen with near-
    //               antimeridian shapes.
    private func fitCamera(_ map: MKMapView, to coords: [CLLocationCoordinate2D]) {
        guard !coords.isEmpty else { return }

        let lats = coords.map(\.latitude)
        let lons  = coords.map(\.longitude)

        let minLat = lats.min()!, maxLat = lats.max()!
        let minLon = lons.min()!, maxLon = lons.max()!

        let diagonal = haversineKm(minLat: minLat, maxLat: maxLat,
                                   minLon: minLon, maxLon: maxLon)

        let padding : Double
        let minSpan : Double
        switch diagonal {
        case ..<500:
            padding = 0.10; minSpan = 0.3   // tiny islands — zoom in close
        case 500..<1200:
            padding = 0.10; minSpan = 1.0   // medium archipelagos — tight but legible
        default:
            padding = 0.40; minSpan = 1.0   // large countries — show context
        }

        let latPad = (maxLat - minLat) * padding
        let lonPad = (maxLon - minLon) * padding

        let latDelta = min(max(maxLat - minLat + latPad * 2, minSpan), 180.0)
        let lonDelta = min(max(maxLon - minLon + lonPad * 2, minSpan), 360.0)

        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude : (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta : latDelta,
                longitudeDelta: lonDelta
            )
        )
        map.setRegion(region, animated: false)
    }

    // ── Haversine diagonal ────────────────────────────────────────────────────
    // Returns the great-circle distance in km between the SW and NE corners of
    // a bounding box.  Used to choose the appropriate zoom strategy above.
    // The formula accounts for the Earth's curvature so it stays accurate even
    // near the poles where one degree of longitude represents very few km.
    private func haversineKm(minLat: Double, maxLat: Double,
                              minLon: Double, maxLon: Double) -> Double {
        let r    = 6371.0
        let lat1 = minLat * .pi / 180
        let lat2 = maxLat * .pi / 180
        let dLat = (maxLat - minLat) * .pi / 180
        let dLon = (maxLon - minLon) * .pi / 180
        let a    = sin(dLat / 2) * sin(dLat / 2)
                 + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        return r * 2 * atan2(sqrt(a), sqrt(1 - a))
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

            // Fill: #4F46E5 at 75 % opacity — boosted from 60 % to stand out
            // clearly against the darker satellite imagery background.
            renderer.fillColor = UIColor(red: 79/255, green: 70/255, blue: 229/255, alpha: 0.75)

            // Border: solid #4F46E5 so the edge is crisp.
            renderer.strokeColor = UIColor(red: 79/255, green: 70/255, blue: 229/255, alpha: 1.0)
            renderer.lineWidth   = 1.5

            return renderer
        }
    }
}
