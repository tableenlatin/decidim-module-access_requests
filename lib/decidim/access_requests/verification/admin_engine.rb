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

            menu.remove_item "access_requests"

            pending_path = decidim_admin_access_requests.pending_authorizations_path
            menu.add_item :access_requests_pending,
                          I18n.t("decidim.access_requests.verification.admin.pending_authorizations.index.title"),
                          pending_path,
                          active: is_active_link?(pending_path, :exclusive)

            granted_path = decidim_admin_access_requests.granted_authorizations_path
            menu.add_item :access_requests_granted,
                          I18n.t("decidim.access_requests.verification.admin.granted_authorizations.index.title"),
                          granted_path,
                          active: is_active_link?(granted_path, :exclusive)

            new_granted_path = decidim_admin_access_requests.new_granted_authorization_path
            menu.add_item :access_requests_new,
                          I18n.t("decidim.access_requests.verification.admin.granted_authorizations.index.new"),
                          new_granted_path,
                          active: is_active_link?(new_granted_path, :exclusive)
          end
        end
      end
    end
  end
end
