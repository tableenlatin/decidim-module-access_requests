# frozen_string_literal: true

require "spec_helper"

module Decidim::AccessRequests::Verification
  describe Engine do
    describe "#load_seed" do
      let!(:organization) { create(:organization, available_authorizations: []) }

      it "enables the workflows registered for this engine" do
        described_class.instance.load_seed

        expect(organization.reload.available_authorizations).to include("ar_verification")
      end
    end
  end
end
