# frozen_string_literal: true

module Decidim
  module AccessRequests
    module Verification
      # A form object to be used when public users want to get verified by
      # access requests.
      class RequestForm < AuthorizationHandler
        attribute :handler_handle, String
        attribute :membership_number, String

        validates :handler_handle,
                  presence: true,
                  inclusion: {
                    in: proc { |form|
                      form.current_organization.available_authorizations
                    }
                  }
        validates :membership_number, presence: true, if: :require_membership_number?

        def handler_name
          handler_handle
        end

        def metadata
          super.merge(membership_number:)
        end

        private

        # Membership number is required when the user submits the form (public
        # access request flow). It is skipped when admin actions re-build the
        # form (confirm a pending request, grant access directly) because:
        # - for pending#update the value already lives on the persisted
        #   authorization metadata and is passed through;
        # - for granted#create the admin grants without going through the user
        #   workflow, so there is no value to validate against.
        def require_membership_number?
          # `context` is an OpenStruct in Decidim 0.32, not a Hash; unknown
          # attributes return nil, so `!context.admin_context` is true when
          # the flag is absent (public flow) and false when admin sets it.
          !context.admin_context
        end
      end
    end
  end
end
