# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Shakapacker.register_path("#{base_path}/app/packs", prepend: true)

Decidim::Shakapacker.register_stylesheet_import("stylesheets/decidim/access_requests/settings", type: :settings)

Decidim::Shakapacker.register_stylesheet_import("stylesheets/decidim/access_requests/verification")
