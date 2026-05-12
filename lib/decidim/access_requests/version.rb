# frozen_string_literal: true

module Decidim
  module AccessRequests
    def self.decidim_version
      [">= 0.32.0.rc2", "< 0.33"].freeze
    end

    def self.version
      "0.32.0"
    end
  end
end
