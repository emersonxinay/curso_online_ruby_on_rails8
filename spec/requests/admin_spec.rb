require 'rails_helper'

RSpec.describe "Admins", type: :request do
  describe "GET /Dashboard" do
    it "returns http success" do
      get "/admin/Dashboard"
      expect(response).to have_http_status(:success)
    end
  end

end
