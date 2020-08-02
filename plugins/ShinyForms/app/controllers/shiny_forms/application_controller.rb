# frozen_string_literal: true

module ShinyForms
  # Base controller for ShinyCMS forms plugin
  class ApplicationController < ActionController::Base
    helper Rails.application.routes.url_helpers
  end
end
