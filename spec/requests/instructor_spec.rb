require 'rails_helper'

RSpec.describe "Instructors", type: :request do
  describe "GET /Dashboard" do
    it "returns http success" do
      get "/instructor/Dashboard"
      expect(response).to have_http_status(:success)
    end
  end

end
