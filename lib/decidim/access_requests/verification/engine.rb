# frozen_string_literal: true

module Decidim
  module AccessRequests
    module Verification
      # This is an engine that performs user authorization.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::AccessRequests::Verification
        paths["db/migrate"] = nil

        routes do
          resource :authorizations, only: [:new, :create, :edit], as: :authorization do
            get :renew, on: :collection
          end

          root to: "authorizations#new"
        end

        def load_seed
          # Enable the authorization workflows provided by this engine.
          org = Decidim::Organization.first
          return unless org

          workflow_names = Decidim.authorization_workflows.filter_map do |workflow|
            workflow.name if workflow.engine == Decidim::AccessRequests::Verification::Engine
          end
          return if workflow_names.empty?

          org.update!(available_authorizations: (org.available_authorizations + workflow_names).uniq)
        end
      end
    end
  end
end
