# frozen_string_literal: true

# Registers an `ar_verification` access requests workflow inside the generated
# dummy test app so the verification engines are mounted at boot time. The file
# is copied into `spec/decidim_dummy_app/config/initializers/` by the
# `test_app` Rake task — `spec/decidim_dummy_app` is gitignored and rebuilt by
# `decidim:generate_external_test_app`.

Decidim::Verifications.register_workflow(:ar_verification) do |workflow|
  workflow.engine = Decidim::AccessRequests::Verification::Engine
  workflow.admin_engine = Decidim::AccessRequests::Verification::AdminEngine
end
