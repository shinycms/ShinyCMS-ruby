# ============================================================================
# Project:   ShinyCMS (Ruby version)
# File:      app/controllers/application_controller.rb
# Purpose:   Base controller for ShinyCMS
#
# Copyright: (c) 2009-2020 Denny de la Haye https://denny.me
#
# ShinyCMS is free software; you can redistribute it and/or
# modify it under the terms of the GPL (version 2 or later).
# ============================================================================
class ApplicationController < ActionController::Base
  include FeatureFlagsHelper

  before_action :set_view_paths
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout 'layouts/main_site'

  protected

  # Strong params config for Devise
  # rubocop:disable Layout/MultilineArrayLineBreaks
  SIGN_UP_PARAMS = %i[
    username email password password_confirmation
  ].freeze
  private_constant :SIGN_UP_PARAMS
  SIGN_IN_PARAMS = %i[
    username email password password_confirmation login remember_me
  ].freeze
  private_constant :SIGN_IN_PARAMS
  ACCOUNT_UPDATE_PARAMS = %i[
    username email password password_confirmation current_password
    display_name display_email profile_pic bio website location postcode
  ].freeze
  private_constant :ACCOUNT_UPDATE_PARAMS
  # rubocop:enable Layout/MultilineArrayLineBreaks

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit( :sign_up ) do |user_params|
      user_params.permit( SIGN_UP_PARAMS )
    end

    devise_parameter_sanitizer.permit( :sign_in ) do |user_params|
      user_params.permit( SIGN_IN_PARAMS )
    end

    devise_parameter_sanitizer.permit( :account_update ) do |user_params|
      user_params.permit( ACCOUNT_UPDATE_PARAMS )
    end
  end

  # Check user's password against pwned password service and warn if necessary
  def check_for_pwnage( resource )
    return unless resource.try( :pwned? )

    # :nocov:
    set_flash_message! :alert, :warn_pwned
    # :nocov:
  end

  def can_redirect_to_referer_after_login?
    request.referer.present? && request.referer != new_user_session_url
  end

  # Override post-login redirect
  def after_sign_in_path_for( resource )
    check_for_pwnage( resource )

    return URI( request.referer ).path if can_redirect_to_referer_after_login?

    return admin_path if resource.can? :view_admin_area

    user_profile_path( resource.username )
  end

  def set_view_paths
    # Add the default templates directory to the top of view_paths
    prepend_view_path 'app/views/shinycms'

    # Apply the configured theme, if any, by adding it above the defaults
    return unless Theme.current( current_user )

    prepend_view_path Theme.current( current_user ).view_path
  end
end
