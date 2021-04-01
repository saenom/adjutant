require 'rails_helper'

RSpec.describe 'HomeController', type: :request do
  describe '#show' do
    subject(:json_body) { JSON.parse response.body }

    let(:send_request) { get '/', params: {}, as: :json }

    context 'when there is not settings' do
      before do
        allow(Settingslogic).to receive(:source).and_return({})
        Settings.reload!
      end

      it 'returns 500' do
        send_request
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'has a error body' do
        send_request
        expect(json_body).to have_key('error')
      end
    end

    context 'when social networks are set up' do
      before do
        allow(Settingslogic).to receive(:source).and_return(Rails.root.join('config', 'application.yml'))
        Settings.reload!

        response = Typhoeus::Response.new(code: 200, body: "{'name' : 'paul'}")
        Settings.social_networks.map(&:symbolize_keys).each do |social_network|
          Typhoeus.stub(social_network[:url]).and_return(response)
        end
      end

      it 'returns 200' do
        send_request
        expect(response).to have_http_status(:ok)
      end

      it 'has three social networks' do
        send_request
        expect(json_body).to include('twitter', 'facebook', 'instagram')
      end
    end
  end
end
