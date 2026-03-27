#!/usr/bin/env python3
"""
generate_shapes.py
Downloads Natural Earth 110m country borders GeoJSON and converts it to
GeoExplorer/countryShapes.json — a compact array of {name, polygons}
objects used by the Map Quiz mode.

Run from the project root:
    python3 generate_shapes.py

Output: GeoExplorer/countryShapes.json
"""

import json
import os
import sys
import urllib.request

GEOJSON_URL = (
    "https://raw.githubusercontent.com/nvkelso/natural-earth-vector"
    "/master/geojson/ne_110m_admin_0_countries.geojson"
)

# ── Name mapping ──────────────────────────────────────────────────────────────
# Natural Earth uses some names that differ from GeoExplorer's countries.json.
# Keys = Natural Earth NAME / ADMIN, Values = GeoExplorer name.
NE_TO_APP = {
    "United States of America":          "United States",
    "Ivory Coast":                       "Ivory Coast",
    "Côte d'Ivoire":                     "Ivory Coast",
    "Democratic Republic of the Congo":  "Democratic Republic of Congo",
    "Republic of the Congo":             "Republic of Congo",
    "Congo":                             "Republic of Congo",
    "Russian Federation":                "Russia",
    "Russia":                            "Russia",
    "South Korea":                       "South Korea",
    "Republic of Korea":                 "South Korea",
    "Korea":                             "South Korea",
    "North Korea":                       "North Korea",
    "Dem. Rep. Korea":                   "North Korea",
    "Czech Republic":                    "Czech Republic",
    "Czechia":                           "Czech Republic",
    "Lao PDR":                           "Laos",
    "Laos":                              "Laos",
    "Viet Nam":                          "Vietnam",
    "Vietnam":                           "Vietnam",
    "Syrian Arab Republic":              "Syria",
    "Syria":                             "Syria",
    "Iran (Islamic Republic of)":        "Iran",
    "Iran":                              "Iran",
    "Bolivia (Plurinational State of)":  "Bolivia",
    "Bolivia":                           "Bolivia",
    "Venezuela (Bolivarian Republic of)":"Venezuela",
    "Venezuela":                         "Venezuela",
    "United Republic of Tanzania":       "Tanzania",
    "Tanzania":                          "Tanzania",
    "Brunei Darussalam":                 "Brunei",
    "Brunei":                            "Brunei",
    "Swaziland":                         "Eswatini",
    "eSwatini":                          "Eswatini",
    "Eswatini":                          "Eswatini",
    "East Timor":                        "Timor-Leste",
    "Timor-Leste":                       "Timor-Leste",
    "Sao Tome and Principe":             "São Tomé and Príncipe",
    "São Tomé and Príncipe":             "São Tomé and Príncipe",
    "Myanmar":                           "Myanmar",
    "Burma":                             "Myanmar",
    "Palestine":                         "Palestine",
    "West Bank":                         "Palestine",
    "Palestinian Territory":             "Palestine",
    "Kosovo":                            "Kosovo",
    "Republic of Kosovo":                "Kosovo",
    "Macedonia":                         "North Macedonia",
    "North Macedonia":                   "North Macedonia",
    "Holy See":                          "Vatican City",
    "Vatican":                           "Vatican City",
    "Vatican City":                      "Vatican City",
    "Cape Verde":                        "Cape Verde",
    "Cabo Verde":                        "Cape Verde",
    "Guinea Bissau":                     "Guinea-Bissau",
    "Guinea-Bissau":                     "Guinea-Bissau",
    "Dem. Rep. Congo":                   "Democratic Republic of Congo",
    "Solomon Is.":                       "Solomon Islands",
    "Sao Tome and Principe":             "São Tomé and Príncipe",
    "Antigua and Barbuda":               "Antigua and Barbuda",
    "Saint Kitts and Nevis":             "Saint Kitts and Nevis",
    "Saint Lucia":                       "Saint Lucia",
    "Saint Vincent and the Grenadines":  "Saint Vincent and the Grenadines",
    "Trinidad and Tobago":               "Trinidad and Tobago",
    "Papua New Guinea":                  "Papua New Guinea",
    "Solomon Islands":                   "Solomon Islands",
    "Marshall Islands":                  "Marshall Islands",
    "Micronesia":                        "Micronesia",
    "Federated States of Micronesia":    "Micronesia",
    "Bosnia and Herz.":                  "Bosnia and Herzegovina",
    "Bosnia and Herzegovina":            "Bosnia and Herzegovina",
    "Dominican Rep.":                    "Dominican Republic",
    "Dominican Republic":                "Dominican Republic",
    "Eq. Guinea":                        "Equatorial Guinea",
    "Equatorial Guinea":                 "Equatorial Guinea",
    "Central African Rep.":              "Central African Republic",
    "Central African Republic":          "Central African Republic",
    "S. Sudan":                          "South Sudan",
    "South Sudan":                       "South Sudan",
    "United Arab Emirates":              "United Arab Emirates",
    "W. Sahara":                         None,          # disputed territory — skip
    "Somaliland":                        None,          # unrecognised — skip
    "N. Cyprus":                         None,          # skip
    "Taiwan":                            "Taiwan",
    "Saudi Arabia":                      "Saudi Arabia",
    "New Zealand":                       "New Zealand",
    "Sri Lanka":                         "Sri Lanka",
    "Burkina Faso":                      "Burkina Faso",
}


def download_geojson(url: str) -> dict:
    print(f"Downloading {url} …", flush=True)
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.loads(r.read().decode())


def largest_polygons(geometry: dict, keep: int = 50) -> list[list]:
    """
    Returns up to `keep` outer rings from a Polygon or MultiPolygon geometry.
    Rings are sorted largest-first (by vertex count) so tiny specks are
    dropped last if the cap is ever hit.

    50 is safely above the maximum polygon count in the 110m dataset (13 for
    Indonesia), so in practice every island of every archipelago is included.

    Each returned ring is a list of [lon, lat] pairs.
    """
    geo_type = geometry["type"]
    coords   = geometry["coordinates"]

    if geo_type == "Polygon":
        rings = [coords[0]]           # just the outer ring
    elif geo_type == "MultiPolygon":
        rings = [poly[0] for poly in coords]   # outer ring of each sub-polygon
    else:
        return []

    # Sort by descending vertex count, keep top `keep`
    rings.sort(key=len, reverse=True)
    return rings[:keep]


def resolve_name(props: dict) -> str | None:
    """
    Try multiple Natural Earth name fields in order of reliability,
    then apply the NE_TO_APP mapping.  Returns None for territories to skip.
    """
    for field in ("NAME", "ADMIN", "NAME_LONG", "SOVEREIGNT"):
        raw = props.get(field, "")
        if raw:
            # Direct mapping hit
            if raw in NE_TO_APP:
                return NE_TO_APP[raw]
            # Try stripping common suffixes then check again
            for suffix in (" (the)", " (The)"," Islands"):
                cleaned = raw.replace(suffix, "")
                if cleaned in NE_TO_APP:
                    return NE_TO_APP[cleaned]
            # Return as-is (will be matched against app names later)
            return raw
    return None


def main():
    # ── Load app country names ────────────────────────────────────────────────
    script_dir   = os.path.dirname(os.path.abspath(__file__))
    app_json     = os.path.join(script_dir, "GeoExplorer", "countries.json")
    output_path  = os.path.join(script_dir, "GeoExplorer", "countryShapes.json")

    with open(app_json) as f:
        app_countries = {c["name"] for c in json.load(f)}

    print(f"App has {len(app_countries)} countries.")

    # ── Download GeoJSON ──────────────────────────────────────────────────────
    geojson = download_geojson(GEOJSON_URL)

    # ── Convert features ──────────────────────────────────────────────────────
    shapes   = []
    matched  = set()
    skipped  = []

    for feature in geojson["features"]:
        props = feature.get("properties", {})
        name  = resolve_name(props)

        if name is None:
            # Explicitly marked as skip
            continue

        if name not in app_countries:
            skipped.append(name)
            continue

        rings = largest_polygons(feature["geometry"])
        if not rings:
            continue

        # Convert [lon, lat] → [lat, lon] (CLLocationCoordinate2D order)
        converted = [
            [[round(pt[1], 5), round(pt[0], 5)] for pt in ring]
            for ring in rings
        ]

        shapes.append({"name": name, "polygons": converted})
        matched.add(name)

    shapes.sort(key=lambda x: x["name"])

    # ── Write output ──────────────────────────────────────────────────────────
    with open(output_path, "w") as f:
        json.dump(shapes, f, separators=(",", ":"))

    # ── Report ────────────────────────────────────────────────────────────────
    missing = sorted(app_countries - matched)
    print(f"\n✅  Matched {len(matched)} / {len(app_countries)} countries")
    print(f"📄  Written to {output_path}")

    if missing:
        print(f"\n⚠️  {len(missing)} app countries have NO shape data (will be excluded from map quiz):")
        for m in missing:
            print(f"    • {m}")

    if skipped:
        unique_skipped = sorted(set(skipped))
        print(f"\nℹ️  {len(unique_skipped)} NE features skipped (not in app):")
        for s in unique_skipped[:20]:
            print(f"    • {s}")
        if len(unique_skipped) > 20:
            print(f"    … and {len(unique_skipped) - 20} more")


if __name__ == "__main__":
    main()
