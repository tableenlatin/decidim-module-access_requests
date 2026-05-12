# frozen_string_literal: true

module Decidim
  module AccessRequests
    module Verification
      module DetectableVerificationManifest
        include ActiveSupport::Concern

        def verification_manifest
          if verification_manifest_handle
            Decidim::Verifications.workflows.to_a.find do |verification|
              verification.name == verification_manifest_handle
            end
          end
        end

        def verification_manifest_handle
          mounted_workflow_handle if admin_request_path?
        end

        def mounted_workflow_handle
          request.script_name.to_s.split("/").last.presence
        end

        def admin_request_path?
          path_segments = request.path.to_s.split("/").compact_blank
          %w(0 1).include?(path_segments.index("admin")&.to_s)
        end
      end
    end
  end
end
