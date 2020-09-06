# frozen_string_literal: true

# ShinyCMS ~ https://shinycms.org
#
# Copyright 2009-2020 Denny de la Haye ~ https://denny.me
#
# ShinyCMS is free software; you can redistribute it and/or modify it under the terms of the GPL (version 2 or later)

# Common behaviour for templated content - e.g. ShinyPages::Page, ShinyNewsletters::Edition
module ShinyWithTemplate
  extend ActiveSupport::Concern

  included do
    # Validations

    validates :template, presence: true

    # Before/after actions

    after_create :add_elements

    # Plugins

    paginates_per 20

    # Instance methods

    # Add the elements specified by the template
    def add_elements
      template.elements.each do |template_element|
        elements.create!(
          name: template_element.name,
          content: template_element.content,
          element_type: template_element.element_type
        )
      end
    end

    # Returns a hash of all the elements for this item, to feed to render's local
    def elements_hash
      hash = {}
      elements.each do |element|
        hash[ element.name.to_sym ] = element.content
      end
      hash
    end

    # Specify policy class for Pundit
    def policy_class
      self.class.policy_class
    end
  end
end