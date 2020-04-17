# Application Record
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.use_algolia?
    ENV['ALGOLIASEARCH_APPLICATION_ID'].present?
  end

  def self.algolia_searchable
    return unless use_algolia?

    include AlgoliaSearch

    algoliasearch unless: :hidden?, per_environment: true do
      # all attributes will be sent
    end
  end

  def human_name
    name = self.class.name.underscore
    return name.humanize.downcase unless I18n.exists?( "content_types.#{name}" )

    I18n.t( "content_types.#{name}" )
  end
end
