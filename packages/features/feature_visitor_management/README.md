# feature_visitor_management

Structured identically to `feature_asset_management` — see that
package's README for the full layer-by-layer pattern.

Covers concept doc §5.3: pre-invite & walk-in check-in, meeting room
allocation (Calendar integration), document/ID verification (OCR +
watchlist), visitor categorisation, host approval, digital badge, and
real-time on-site headcount.

## Scaffolded so far

* `domain/entities/visitor.dart`, `visitor_status.dart`
* `domain/repositories/visitor_repository.dart`
* `domain/usecases/check_in_visitor.dart`
* `presentation/pages/visitor_checkin_page.dart` (stub)

## Not yet implemented (follow the asset_management reference to add)

* `data/local/` Drift table + database for offline-first visitor caching
  (important here specifically for kiosk check-in during connectivity
  drops at reception)
* `data/datasources/`, `data/repositories/visitor_repository_impl.dart`
* Calendar integration client, OCR/watchlist integration client
* The `SyncHandler` registration for queued check-ins
