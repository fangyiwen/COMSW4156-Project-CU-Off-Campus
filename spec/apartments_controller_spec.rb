require 'rails_helper'
require_relative '../app/controllers/apartments_controller'

RSpec.describe ApartmentsController, :type => :controller do
  it 'does index' do
    get :index, params: { commit: nil }
    expect(response).to redirect_to apartments_path

    get :index, params: { search: "Apple", sort: "price", price: "1000-1499" }, session: { sort: "price", price: "1000-1499" }
    expect(response.inspect.to_s).to include "Apple"

    get :index, params: { search: "Apple", sort: "price", price: "1000-1499" }, session: { search: "Apple", sort: "price", price: "1000-1499" }
    expect(response.inspect.to_s).to include "Apple"

    get :index, params: { search: "Apple", sort: "rating", price: "1000-1499" }, session: { sort: "rating", price: "1000-1499" }
    expect(response.inspect.to_s).to include "Apple"
  end

  it 'does show' do
    ap = {
      name: "Apartment 1",
      price: 1200,
      image: nil,
      description: "This is apartment 1.",
      address: "3 Apple St"
    }
    Apartment.create!(ap)
    id = Apartment.find_by(ap)[:id]
    get :show, params: { id: id }
    expect(response.inspect.to_s).to include "Apartment 1"

    Apartment.destroy(id)
  end

  it 'does create' do
    get :create, params: {
      apartment: {
        name: "Apartment 5",
        price: 800,
        image: nil,
        description: "This is apartment 5.",
        address: "9 Tomato St"
      }
    }
    expect(response).to redirect_to apartments_path

    get :create, params: {
      apartment: {
        name: "Apartment 5",
        price: "Invalid price",
        image: nil,
        description: "This is apartment 5.",
        address: "9 Tomato St"
      }
    }
    expect(response).to redirect_to new_apartment_path
  end

  it 'does edit' do
    ap = {
      name: "Apartment 1",
      price: 1200,
      image: nil,
      description: "This is apartment 1.",
      address: "3 Apple St"
    }
    Apartment.create!(ap)
    id = Apartment.find_by(ap)[:id]
    get :edit, params: { id: id }
    expect(response.inspect.to_s).to include "Apartment 1"

    Apartment.destroy(id)
  end

  it 'does update' do
    ap = {
      name: "Apartment 1",
      price: 1200,
      image: nil,
      description: "This is apartment 1.",
      address: "3 Apple St"
    }

    Apartment.create!(ap)
    id = Apartment.find_by(ap)[:id]
    put :update, params: { id: id, apartment: ap }
    expect(response).to redirect_to apartment_path(Apartment.find id)

    Apartment.destroy(id)

    ap = {
      name: "Apartment 1",
      price: 1200,
      image: nil,
      description: "This is apartment 1.",
      address: "3 Apple St"
    }
    Apartment.create!(ap)
    id = Apartment.find_by(ap)[:id]
    ap = {
      name: "Apartment 1",
      price: "Invalid price",
      image: nil,
      description: "This is apartment 1.",
      address: "3 Apple St"
    }
    put :update, params: { id: id, apartment: ap }
    expect(response).to redirect_to edit_apartment_path(Apartment.find id)

    Apartment.destroy(id)
  end
end