require 'rails_helper'

RSpec.describe BuildsController, type: :controller do

  describe 'POST #create' do
    it 'returns http no content' do
      post :create, params: { commit: '4fedbeb547d5bd71a421c57622b71b0743971555'}
      expect(response).to have_http_status(:no_content)
    end

    describe 'without commit parameter' do
      it 'returns unprocessable entity' do
        post :create
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it 'creates new build'

  end
end
