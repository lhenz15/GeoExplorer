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
//   makeUIView(context:)   — called ONCE to create and configure the UIView.
//   updateUIView(_:context:) — called whenever SwiftUI re-renders this node
//                             (e.g. countryName changes to the next question).
//
// ── What is MKPolygon? ────────────────────────────────────────────────────────
// An MKPolygon is MapKit's way to represent a closed shape on the map.
// You hand it an array of CLLocationCoordinate2D (lat/lon structs) and it
// draws the outline.  To fill it with colour you also need an
// MKPolygonRenderer (returned from the delegate's rendererForOverlay method).
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
    // We configure every map setting here so the map arrives already in the
    // right state — no separate setup calls needed later.
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()

        // .mutedStandard shows roads and borders but in subtle grey tones,
        // so the indigo polygon stands out clearly against the background.
        map.mapType = .mutedStandard

        // Remove all labels (city names, country names, POI icons).
        // We don't want the answer printed on the map!
        if #available(iOS 16.0, *) {
            map.selectableMapFeatures = []
        }
        map.pointOfInterestFilter = .excludingAll

        // Lock the camera — students tap answer buttons, not the map.
        map.isScrollEnabled  = false
        map.isZoomEnabled    = false
        map.isRotateEnabled  = false
        map.isPitchEnabled   = false
        map.showsCompass     = false
        map.showsScale       = false
        map.showsTraffic     = false
        map.showsBuildings   = false

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
    // that shows the whole country with 40 % padding on each side so
    // neighbouring countries are visible for geographic context.
    private func fitCamera(_ map: MKMapView, to coords: [CLLocationCoordinate2D]) {
        guard !coords.isEmpty else { return }

        let lats = coords.map(\.latitude)
        let lons = coords.map(\.longitude)

        let minLat = lats.min()!, maxLat = lats.max()!
        let minLon = lons.min()!, maxLon = lons.max()!

        let latPad = (maxLat - minLat) * 0.4
        let lonPad = (maxLon - minLon) * 0.4

        // MKCoordinateRegion(center:span:) defines what the camera shows.
        // center is the midpoint; span is how many degrees of lat/lon to show.
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
    // MKMapViewDelegate provides the rendererForOverlay method.
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
            renderer.fillColor = UIColor(
                red  : 79/255,
                green: 70/255,
                blue : 229/255,
                alpha: 0.6
            )

            // Border: solid #4F46E5 so the edge is crisp.
            renderer.strokeColor = UIColor(
                red  : 79/255,
                green: 70/255,
                blue : 229/255,
                alpha: 1.0
            )
            renderer.lineWidth = 1.5

            return renderer
        }
    }
}
