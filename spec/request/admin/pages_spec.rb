require 'rails_helper'

RSpec.describe 'Admin: Pages', type: :request do
  describe 'GET /admin/pages' do
    it 'fetches the list of pages in the admin area' do
      create :page
      create :page, :hidden
      p1 = create :page_in_section
      create :page_in_section, :hidden
      create :page_in_subsection
      create :page_in_subsection, :hidden
      get '/admin/pages'
      expect( response ).to have_http_status :ok
      expect( response.body ).to include 'List pages'
      expect( response.body ).to include 'Top-level pages'
      expect( response.body ).to include p1.section.name
      expect( response.body ).to include p1.name
      # expect( response.body ).to include 'Hidden top-level pages'  # FIXME
    end
  end

  describe 'GET /admin/page/add' do
    it 'loads the form to add a new page' do
      get '/admin/page/add'
      expect( response ).to have_http_status :ok
      expect( response.body ).to include 'Add new page'
    end
  end

  describe 'POST /admin/page/add' do
    it 'fails when the form is submitted without all the details' do
      post '/admin/page/add', params: {
        'page[title]': 'Test'
      }
      expect( response ).to have_http_status :ok
      expect( response.body ).to include 'Failed to create new page'
    end
  end

  describe 'POST /admin/page/add' do
    it 'adds a new page when the form is submitted' do
      template = create :page_template
      post '/admin/page/add', params: {
        'page[name]': 'Test',
        'page[title]': 'Test',
        'page[slug]': 'test',
        'page[template_id]': template.id
      }
      expect( response ).to have_http_status :found
      follow_redirect!
      expect( response ).to have_http_status :ok
      expect( response.body ).to include 'Edit page'
    end
  end

  describe 'GET /admin/page/:id' do
    it 'loads the form to edit an existing page' do
      page = create :page
      get "/admin/page/#{page.id}"
      expect( response ).to have_http_status :ok
      expect( response.body ).to include 'Add new page'
    end
  end

  describe 'POST /admin/page/:id' do
    it 'fails to update the page when submitted without all the details' do
      page = create :page
      post "/admin/page/#{page.id}", params: {
        'page[name]': nil
      }
      expect( response ).to have_http_status :ok
      expect( response.body ).to include 'Failed to update page details'
    end
  end

  describe 'POST /admin/page/:id' do
    it 'updates the page when the form is submitted' do
      page = create :page
      post "/admin/page/#{page.id}", params: {
        'page[name]': 'Updated by test'
      }
      expect( response ).to have_http_status :ok
      expect( response.body ).to include 'Updated by test'
    end
  end
end
