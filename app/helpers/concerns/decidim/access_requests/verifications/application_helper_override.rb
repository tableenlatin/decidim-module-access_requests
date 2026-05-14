# frozen_string_literal: true

module Decidim
  module AccessRequests
    module Verifications
      # Overrides the title shown in the user-facing authorizations list
      # (/account/authorizations) for the access_requests workflow only.
      #
      # Decidim's default uses `decidim.authorization_handlers.<key>.name`
      # for both admin and user contexts. The TEL design wants:
      #   - admin menu/list: plural "Demandes d'accès"
      #   - user-facing list: singular "Demande d'accès"
      #
      # Decidim has no per-context i18n key, so this module swaps the title
      # in the helper used by `authorizations#index` for this workflow only.
      module ApplicationHelperOverride
        extend ActiveSupport::Concern

        prepended do
          private

          def access_requests_user_facing_title(name)
            return nil unless name.to_s == "access_requests"

            I18n.t(
              "decidim.access_requests.user_facing_name",
              default: I18n.t("access_requests.name", scope: "decidim.authorization_handlers")
            )
          end
        end

        def authorization_display_data(authorization)
          override = access_requests_user_facing_title(authorization.name)
          return { title: override } if override

          super
        end

        def unauthorized_method_display_data(method, redirect_url = nil)
          data = super
          override = access_requests_user_facing_title(method.key)
          data[:title] = override if override
          data
        end
      end
    end
  end
end
