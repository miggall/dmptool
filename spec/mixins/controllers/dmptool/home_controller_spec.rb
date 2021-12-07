# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dmptool::HomeController, type: :request do

  include DmptoolHelper

  before(:each) do
    @controller = ::HomeController.new
    mock_blog
  end

  it 'HomeController includes our customizations' do
    expect(@controller.respond_to?(:render_home_page)).to eql(true)
  end

  describe '#render_home_page' do
    it '#page is accessible when not logged in' do
      create(:plan, template: create(:template), created_at: Time.now.yesterday)
      get root_path
      # Request specs are expensive so just check everything in this one test
      expect(response).to have_http_status(:success), 'should have received a 200'
      expect(assigns(:rss).present?).to eql(true), 'should have set @rss'
      expect(assigns(:stats).present?).to eql(true), 'should have set @stats'
      expect(assigns(:top_five).present?).to eql(true), 'should have set @top_five'
      expect(response.body.include?('<h1>Welcome to the DMPTool')).to eql(true)
    end
  end

  context 'private methods' do
    describe '#statistics' do
      it 'returns the contents of the Rails.cache if available' do
        val = [Faker::Lorem.paragraph]
        Rails.cache.stubs(:read).returns(val)
        expect(@controller.send(:statistics)).to eql(val)
      end
      it 'returns 0 for :user_count if no Users' do
        expect(@controller.send(:statistics)[:user_count]).to eql(0)
      end
      it 'returns 0 for :completed_plan_count if no Plans' do
        expect(@controller.send(:statistics)[:completed_plan_count]).to eql(0)
      end
      it 'returns 0 for :institution_count if no participating Orgs' do
        Org.destroy_all
        expect(@controller.send(:statistics)[:institution_count]).to eql(0)
      end
      it 'returns the total number of Users' do
        create(:user)
        expect(@controller.send(:statistics)[:user_count]).to eql(1)
      end
      it 'returns the total number of Plans' do
        create(:plan)
        expect(@controller.send(:statistics)[:completed_plan_count]).to eql(1)
      end
      it 'returns the total number of participating Orgs' do
        # The default org is being generated by the rails_helper!
        Org.destroy_all
        create(:org, managed: false)
        create(:org, managed: true)
        expect(@controller.send(:statistics)[:institution_count]).to eql(1)
      end
    end

    describe '#top_templates' do
      before(:each) do
        @older = create(:plan, template: create(:template),
                               created_at: Time.now - 120.days)
        6.times { create(:plan, template: create(:template), created_at: Date.yesterday) }
      end
      it 'returns the contents of the Rails.cache if available' do
        val = [Faker::Lorem.paragraph]
        Rails.cache.stubs(:read).returns(val)
        expect(@controller.send(:top_templates)).to eql(val)
      end
      it 'returns an empty array if no plans were created in last 90 days' do
        Plan.destroy_all
        expect(@controller.send(:top_templates)).to eql([])
      end
      it 'returns the top 5 templates' do
        expect(@controller.send(:top_templates).length).to eql(5)
      end
      it 'does not include plans that are older than 90 days' do
        expect(@controller.send(:top_templates).include?(@older.template)).to eql(false)
      end
    end

    describe '#feed' do
      it 'returns the contents of the Rails.cache if available' do
        val = [Faker::Lorem.paragraph]
        Rails.cache.stubs(:read).returns(val)
        expect(@controller.send(:feed)).to eql(val)
      end
      it 'returns an empty array if the Blog feed does not return a 200 code' do
        HTTParty.stubs(:get).returns(OpenStruct.new(code: 404, body: nil))
        expect(@controller.send(:feed)).to eql([])
      end
      it 'returns writes to log if an Error is thrown' do
        Rails.logger.expects(:error).at_least(1)
        RSS::Parser.stubs(:parse).raises(StandardError.new(Faker::Lorem.word))
        expect(@controller.send(:feed)).to eql([])
      end
      it 'returns the xml' do
        expect(@controller.send(:feed).length).to eql(2)
      end
    end

    describe '#cache_content' do
      before(:each) do
        # Rails cache is a NULL_STORE by default unless running in production
        # Enable the cache for these tests
        memory_store = ActiveSupport::Cache.lookup_store(:memory_store)
        Rails.stubs(:cache).returns(memory_store)

        @type = Faker::Lorem.word
        @val = Faker::Lorem.sentence
      end
      after(:each) do
        Rails.cache.clear
      end

      it 'Does not add the item to the Rails cache if :type is not present' do
        Rails.cache.expects(:write).at_most(0)
        @controller.send(:cache_content, nil, @val)
      end
      it 'Logs errors' do
        err = StandardError.new(Faker::Lorem.word)
        Rails.logger.expects(:error).at_least(1)
        Rails.cache.stubs(:write).raises(err)
        @controller.send(:cache_content, @type, @val)
      end
      it 'Adds the item to the Rails cache' do
        @controller.send(:cache_content, @type, @val)
        expect(Rails.cache.read(@type)).to eql(@val)
      end
    end
  end
end
