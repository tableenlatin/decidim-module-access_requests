# frozen_string_literal: true

require "spec_helper"

module Decidim::AccessRequests::Verification::Admin
  describe PendingAuthorizationsController, type: :controller do
    controller described_class do
      # Re-bind the anonymous controller subclass to the admin engine routes.
      # RSpec controller specs create an anonymous subclass whose `_routes`
      # falls back to `Rails.application.routes`; without this include, named
      # route helpers like `pending_authorizations_path` resolve to polymorphic
      # URLs instead of the engine path.
      include Decidim::AccessRequests::Verification::AdminEngine.routes.url_helpers

      # Since we cannot customize the route path for automatic detection of
      # the verification method handle, we are using a customized controller to
      # bypass the problem
      def verification_manifest_handle
        return "dummy" unless valid_manifest?

        "ar_verification"
      end

      def valid_manifest?
        true
      end
    end

    routes { Decidim::AccessRequests::Verification::AdminEngine.routes }

    let(:user) { create(:user, :confirmed, :admin, organization: organization) }
    let(:organization) do
      create(:organization, available_authorizations: [verification_type])
    end
    let(:verification_type) { "ar_verification" }

    before do
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    describe "workflow detection" do
      it "extracts the mounted workflow handle from the admin script name" do
        request.env["SCRIPT_NAME"] = "/en/admin/access_requests"

        handle = Decidim::AccessRequests::Verification::DetectableVerificationManifest
                 .instance_method(:mounted_workflow_handle)
                 .bind(controller)
                 .call

        expect(handle).to eq("access_requests")
      end

      it "detects admin routes with nonstandard locale prefixes" do
        allow(request).to receive(:path).and_return("/fi-plain/admin/access_requests/pending_authorizations")
        request.env["SCRIPT_NAME"] = "/fi-plain/admin/access_requests"

        handle = Decidim::AccessRequests::Verification::DetectableVerificationManifest
                 .instance_method(:verification_manifest_handle)
                 .bind(controller)
                 .call

        expect(handle).to eq("access_requests")
      end
    end

    describe "GET index" do
      before do
        create_list(
          :authorization,
          4,
          :granted,
          name: "ar_verification",
          organization: organization
        )
        create_list(
          :authorization,
          6,
          :pending,
          name: "ar_verification",
          organization: organization
        )
      end

      it "renders a list of granted authorizations" do
        get :index
        expect(assigns[:pending_authorizations].length).to eq(6)
        expect(subject).to render_template("decidim/access_requests/verification/admin/pending_authorizations/index")
      end

      context "when there are more than 15 pending results" do
        before do
          create_list(
            :authorization,
            20,
            :pending,
            name: "ar_verification",
            organization: organization
          )
        end

        it "paginates the results" do
          get :index
          expect(assigns[:pending_authorizations].length).to eq(15)
        end
      end
    end

    describe "PUT update" do
      let(:authorization) do
        create(
          :authorization,
          :pending,
          name: "ar_verification",
          organization: organization
        )
      end

      context "when the params are valid" do
        it "redirects with notice message" do
          post :update, params: { id: authorization.id }
          expect(flash[:notice]).not_to be_empty
          expect(response).to redirect_to(%r{/pending_authorizations(\?|\z)})
          expect(
            Decidim::Authorization.find(authorization.id).granted?
          ).to be(true)
        end
      end
    end

    describe "DELETE destroy" do
      let(:authorized_user) { create(:user, organization: organization) }
      let(:authorization) do
        create(
          :authorization,
          :pending,
          name: "ar_verification",
          user: authorized_user
        )
      end

      context "when the params are valid" do
        it "redirects with notice message" do
          authorization_id = authorization.id
          expect do
            post :destroy, params: { id: authorization_id }
            expect(flash[:notice]).not_to be_empty
            expect(response).to redirect_to(%r{/pending_authorizations(\?|\z)})
          end.to change(Decidim::Authorization, :count).by(-1)
        end
      end

      context "when the invalid authorization is provided" do
        it "redirects with alert" do
          authorization_id = authorization.id
          expect do
            post :destroy, params: { id: authorization_id + 10 }
            expect(flash[:alert]).not_to be_empty
            expect(response).to redirect_to(%r{/pending_authorizations(\?|\z)})
          end.not_to change(Decidim::Authorization, :count)
        end
      end
    end
  end
end
