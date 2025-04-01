require 'rails_helper'

RSpec.describe Course, type: :model do
  it "es válido con título, descripción y precio" do
    user = create(:user, role: :instructor)
    course = Course.new(title: "Curso de Rails", description: "Aprende Rails desde cero", price: 100.0, user: user)
    expect(course).to be_valid
  end

  it "no es válido sin título" do
    course = Course.new(description: "Aprende Rails", price: 100.0)
    expect(course).to_not be_valid
  end

  it "no es válido sin descripción" do
    course = Course.new(title: "Curso de Rails", price: 100.0)
    expect(course).to_not be_valid
  end

  it "no es válido sin precio" do
    course = Course.new(title: "Curso de Rails", description: "Aprende Rails desde cero")
    expect(course).to_not be_valid
  end

  it "tiene un estado por defecto 'draft'" do
    course = Course.new(title: "Curso de Rails", description: "Aprende Rails", price: 100.0)
    expect(course.draft?).to be true
  end
end
