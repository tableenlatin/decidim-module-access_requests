# Changelog

## 0.32.0

Compatibility release for Decidim 0.32.

### Required runtime changes

- Drop support for Decidim < 0.32 and Ruby < 3.4. Decidim 0.32 pins
  `required_ruby_version = "~> 3.4.0"` and ships Rails 8.1.
- `config/assets.rb` migrated from `Decidim::Webpacker` to
  `Decidim::Shakapacker` (the Webpacker module is deprecated in 0.32).

### Behaviour changes

- Admin workflow detection (`DetectableVerificationManifest`) no longer relies
  on `request.path.split("/")[2]`. It now reads the workflow handle from
  `request.script_name`, which is locale-prefix safe and correctly handles
  non-standard locales such as `fi-pl` and `fi-plain`.
- Public `AuthorizationsController#authorization_handle` resolves the workflow
  handle from the mounted engine's `script_name` instead of slicing the request
  path. This removes the `renew`-specific branch that broke under
  `/:locale/...` routes.
- Admin authorization lookups in `PendingAuthorizationsController` and
  `GrantedAuthorizationsController` are now scoped by `current_organization`
  through `Decidim::Verifications::Authorizations`, preventing cross-org
  authorization access. `GrantedAuthorizationsController#load_user` is likewise
  scoped to `current_organization.users`.
- `Engine#load_seed` enables every workflow registered against this engine,
  not only a hard-coded `:access_requests` handle. It also no-ops cleanly if
  no organization exists yet.

### Removed / deprecated

- `Decidim::Webpacker.register_*` calls removed (replaced by
  `Decidim::Shakapacker.register_*`).
- Old `request.path` heuristics for resolving the workflow handle.

### Installation notes

The README install instructions no longer recommend running
`bin/rails decidim:upgrade` as part of the module install — that is a
host-app upgrade task and is not required by this module on its own.

### Internal

- Test app now registers `ar_verification` via a dummy-app initializer copied
  in by the `test_app` Rake task, ensuring the verification engines are mounted
  by the time controller specs run.
- Spec assertions for redirects use the engine's URL helpers explicitly, since
  the anonymous controller subclasses created by rspec-rails do not inherit
  the engine route binding.
- Bumped development dependencies (`bootsnap`, `byebug`, `letter_opener_web`,
  `listen`, `puma`, `web-console`, `rubocop-performance`) and added
  `brakeman` and `parallel_tests` to match the Decidim 0.32 dev app stack.
  Removed `spring`, `spring-watcher-listen`, `uglifier`, and the
  `railties` CVE pin (no longer required on Rails 8.1).
