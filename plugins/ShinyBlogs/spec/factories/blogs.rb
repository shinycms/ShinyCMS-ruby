# frozen_string_literal: true

FactoryBot.define do
  factory :shiny_blogs_blog, class: 'ShinyBlogs::Blog' do
    internal_name { Faker::Books::CultureSeries.unique.culture_ship }

    association :user
  end
end