# frozen_string_literal: true

module Decidim
  module AccessRequests
    module Verification
      # This is an engine that implements the administration interface for
      # user authorization by access request.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::AccessRequests::Verification::Admin
        paths["db/migrate"] = nil

        routes do
          resources :pending_authorizations, only: [:index, :update, :destroy]
          resources :granted_authorizations, only: [:index, :new, :create, :destroy]

          root to: "pending_authorizations#index"
        end

        initializer "decidim_access_requests.admin_workflows_menu" do
          Decidim.menu :workflows_menu do |menu|
            next unless current_organization&.available_authorizations&.include?("access_requests")

            granted_path = decidim_admin_access_requests.granted_authorizations_path
            menu.add_item :access_requests_granted,
                          I18n.t("decidim.access_requests.verification.admin.granted_authorizations.index.title"),
                          granted_path,
                          active: is_active_link?(granted_path)
          end
        end
      end
    end
  end
end
