require 'rails_helper'

RSpec.describe 'Discussions/Comments', type: :request do
  before :each do
    create :feature_flag, name: 'blogs',    enabled: true
    create :feature_flag, name: 'comments', enabled: true

    blog = create :blog
    @post = create :blog_post, blog: blog

    @discussion = create :discussion, resource: @post
    @post.update!( discussion: @discussion )

    cmntr = create :user
    create :top_level_comment, discussion: @discussion
    @comment = create :top_level_comment, discussion: @discussion, author: cmntr
    create :top_level_comment, discussion: @discussion

    @nested = create :nested_comment, discussion: @discussion, parent: @comment
  end

  describe 'GET /blog/1999/12/testing' do
    it 'loads a blog post and its comments' do
      get "/blog/#{@post.posted_year}/#{@post.posted_month}/#{@post.slug}"

      expect( response      ).to have_http_status :ok
      expect( response.body ).to have_css 'h3', text: I18n.t( 'discussions.comments' )
      expect( response.body ).to have_css 'h2', text: @comment.title
      expect( response.body ).to have_css 'h2', text: @nested.title
    end

    it 'loads a blog post with an empty discussion' do
      @discussion.comments.delete_all

      get "/blog/#{@post.posted_year}/#{@post.posted_month}/#{@post.slug}"

      expect( response      ).to have_http_status :ok
      expect( response.body ).to have_css 'h3', text: I18n.t( 'discussions.comments' )
      expect( response.body ).to have_css 'p',  text: I18n.t( 'discussions.zero_comments' )
    end

    it 'loads a blog post with no discussion attached' do
      @post.update!( discussion: nil )

      get "/blog/#{@post.posted_year}/#{@post.posted_month}/#{@post.slug}"

      expect( response      ).to     have_http_status :ok
      expect( response.body ).not_to have_css 'h3', text: I18n.t( 'discussions.comments' )
    end
  end

  describe 'GET /discussions' do
    it 'redirects to the homepage, for now' do
      get discussions_path

      expect( response ).to have_http_status :found
      expect( response ).to redirect_to root_path
      follow_redirect!
      expect( response      ).to have_http_status :ok
    end
  end

  describe 'GET /discussion/1' do
    it 'displays a discussion, without its parent resource' do
      get discussion_path( @discussion )

      expect( response      ).to have_http_status :ok
      expect( response.body ).to have_css 'h2', text: @comment.title
      expect( response.body ).to have_css 'h2', text: @nested.title
    end

    it "renders the 404 page if the discussion doesn't exist" do
      get discussion_path( 999 )

      expect( response      ).to have_http_status :not_found
      expect( response.body ).to have_css 'h2', text: I18n.t(
        'errors.not_found.title', { resource_type: 'Discussion' }
      )
    end
  end

  describe 'GET /discussion/1/1' do
    it 'displays a comment and any replies to it' do
      get comment_path( @discussion, @comment.number )

      expect( response      ).to have_http_status :ok
      expect( response.body ).to have_css 'h2', text: @comment.title
      expect( response.body ).to have_css 'h2', text: @nested.title
    end

    it "renders the 404 page if the comment doesn't exist" do
      get comment_path( @discussion, 999 )

      expect( response      ).to have_http_status :not_found
      expect( response.body ).to have_css 'h2', text: I18n.t(
        'errors.not_found.title', { resource_type: 'Comment' }
      )
    end
  end

  describe 'POST /discussion/1' do
    it 'adds a new top-level comment to the discussion' do
      title = Faker::Science.scientist
      body  = Faker::Lorem.paragraph

      post discussion_path( @discussion ), params: {
        comment: { title: title, body: body }
      }

      expect( response      ).to have_http_status :found
      expect( response      ).to redirect_to discussion_path( @discussion )
      follow_redirect!
      expect( response      ).to have_http_status :ok
      expect( response.body ).to have_css '.notices', text: I18n.t( 'discussions.add_comment.success' )
      expect( response.body ).to have_css 'h2', text: title
      expect( response.body ).to include body
    end

    it 'fails to post a top-level comment with missing fields' do
      post discussion_path( @discussion ), params: {
        comment: { name: Faker::Science.scientist }
      }

      expect( response      ).to have_http_status :ok
      expect( response.body ).to have_css '.alerts', text: I18n.t( 'discussions.add_comment.failure' )
    end
  end

  describe 'POST /discussion/1/1' do
    it 'adds a new comment as a reply to an existing comment' do
      title = Faker::Science.scientist
      body  = Faker::Lorem.paragraph

      post comment_path( @discussion, @comment.number ), params: {
        comment: { title: title, body: body }
      }

      expect( response      ).to have_http_status :found
      expect( response      ).to redirect_to discussion_path( @discussion )
      follow_redirect!
      expect( response      ).to have_http_status :ok
      expect( response.body ).to have_css '.notices', text: I18n.t( 'discussions.add_reply.success' )
      expect( response.body ).to have_css 'h2', text: title
      expect( response.body ).to include body
    end

    it 'fails to post a reply with missing fields' do
      post comment_path( @discussion, @comment.number ), params: {
        comment: { name: Faker::Science.scientist }
      }

      expect( response      ).to have_http_status :ok
      expect( response.body ).to have_css '.alerts', text: I18n.t( 'discussions.add_reply.failure' )
    end
  end
end
