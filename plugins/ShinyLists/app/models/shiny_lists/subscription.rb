# frozen_string_literal: true

# ShinyLists plugin for ShinyCMS ~ https://shinycms.org
#
# Copyright 2009-2020 Denny de la Haye ~ https://denny.me
#
# ShinyCMS is free software; you can redistribute it and/or modify it under the terms of the GPL (version 2 or later)

module ShinyLists
  # Model for subscriptions to mailing lists
  class Subscription < ApplicationRecord
    # Associations

    belongs_to :list,       inverse_of: :subscriptions
    belongs_to :subscriber, inverse_of: :subscriptions, polymorphic: true

    # Scopes

    scope :active, -> { where( unsubscribed_at: nil ) }
  end
end

::EmailRecipient.has_many :subscriptions, as: :subscriber, dependent: :destroy, class_name: 'ShinyLists::Subscription'
::User.has_many :subscriptions, as: :subscriber, dependent: :destroy, class_name: 'ShinyLists::Subscription'
