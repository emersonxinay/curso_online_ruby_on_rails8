require 'rails_helper'

RSpec.describe User, type: :model do
  it "tiene roles definidos correctamente" do
    user = User.new(email: "test@example.com", password: "password")
    expect(user.student?).to be true

    user.instructor!
    expect(user.instructor?).to be true

    user.admin!
    expect(user.admin?).to be true
  end
end
