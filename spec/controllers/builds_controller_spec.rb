require 'rails_helper'

RSpec.describe BuildsController, type: :controller do
  describe 'POST #create' do
    it 'returns http created' do
      post :create, params: { commit: '412f93baf924187b077f57c90a4fa01b8839de7e',
                              project: 'marmot' }
      expect(response).to have_http_status(:created)
    end

    describe 'without commit parameter' do
      it 'returns unprocessable entity' do
        post :create
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
