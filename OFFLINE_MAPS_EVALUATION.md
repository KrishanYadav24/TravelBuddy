# Offline Map Tiles Architecture Evaluation: Mapbox vs. Google Maps Tile Caching

## 1. Executive Summary
TravelBuddy requires robust offline map capability for high-altitude Himalayan treks (e.g. Kedarkantha, Valley of Flowers) where cellular connectivity is absent. This document evaluates the tradeoffs between switching to **Mapbox SDK** vs. building a **Custom Tile-Caching Layer on top of `google_maps_flutter`**.

---

## 2. Technical Comparison & Tradeoffs

| Architectural Dimension | Option A: Mapbox Maps SDK (`mapbox_maps_flutter`) | Option B: Custom Tile Cache on `google_maps_flutter` |
| :--- | :--- | :--- |
| **Offline Region Download** | ✅ Native vector tile packs via `TilePyramidOptions` & offline manager | ⚠️ Custom raster tile download (`TileProvider` + SQLite/CacheManager) |
| **Storage Footprint** | ⚡ Compact vector tiles (~12 MB for full trail region) | 📦 High raster PNG storage (~45 MB per region for zoom 12-16) |
| **Topographic Trail Maps** | ✅ Native contour lines & 3D terrain hillshading out of the box | ⚠️ Requires external raster tile server (e.g., OpenTopoMap) |
| **SDK Dependency & Cost** | 💳 Commercial Mapbox Access Token required | 🆓 Free standard Google Maps SDK / OpenStreetMap overlay |
| **Integration Complexity** | 🔨 High — requires refactoring `MapScreen` & marker controllers | ⚡ Low — preserves existing `GoogleMap` widget architecture |

---

## 3. Detailed Option Breakdown

### Option A: Switching to Mapbox SDK (`mapbox_maps_flutter`)
* **Advantages**: Mapbox provides native `OfflineManager` APIs capable of downloading vector tiles, terrain dem data, and style assets for specific bounding boxes (min/max latitude/longitude). This allows smooth vector zooming offline with low disk usage.
* **Drawbacks**: Requires every developer and user to register a Mapbox access token in `pubspec.yaml` / `.env`. Modifies existing `google_maps_flutter` map controller logic across `MapScreen` and `ItineraryDetailScreen`.

### Option B: Custom Tile-Caching Layer on `google_maps_flutter`
* **Advantages**: Retains the reliable `google_maps_flutter` widget already integrated into `MapScreen` and `DestinationDetailScreen`. Custom `TileProvider` interceptors can cache HTTP requests for OpenTopoMap or OpenStreetMap terrain tiles into local Hive/SQLite storage.
* **Drawbacks**: Google Maps Terms of Service prohibits offline caching of official Google vector map tiles directly. Offline caching must target open raster topographic layers.

---

## 4. Architectural Decision for TravelBuddy

TravelBuddy adopts a **Hybrid Architecture**:
1. **Current Production Default**: `google_maps_flutter` paired with `OfflineManagerNotifier` mock download manager and custom `TileProvider` interface for standard OSM topographic overlays.
2. **Enterprise/Offline Upgrade Path**: Feature flag `USE_MAPBOX_OFFLINE=true` prepared in `EnvConfig` for seamless migration to `mapbox_maps_flutter` when Mapbox access tokens are supplied.
