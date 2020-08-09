# frozen_string_literal: true

# ============================================================================
# Project:   ShinyNews plugin for ShinyCMS (Ruby version)
# File:      plugins/ShinyNews/app/models/shiny_news/post.rb
# Purpose:   Model for news posts
#
# Copyright: (c) 2009-2020 Denny de la Haye https://denny.me
#
# ShinyCMS is free software; you can redistribute it and/or
# modify it under the terms of the GPL (version 2 or later).
# ============================================================================

module ShinyNews
  # Model for news posts
  class Post < ApplicationRecord
    include ShinyDemoDataProvider
    include ShinyPost

    # Associations

    # TODO: this needs to be polymorphic I think?
    belongs_to :user, inverse_of: :shiny_news_posts

    has_one :discussion, as: :resource, dependent: :destroy

    # Instance methods

    def path( anchor: nil )
      url_helpers.view_news_post_path(
        posted_year, posted_month, slug, anchor: anchor
      )
    end

    # Specify policy class for Pundit
    def policy_class
      Admin::PostPolicy
    end

    # Class methods

    def self.policy_class
      Admin::PostPolicy
    end
  end
end