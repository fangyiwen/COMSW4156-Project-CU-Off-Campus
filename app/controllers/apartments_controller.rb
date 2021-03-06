require './app/helpers/application_helper'
require "base64"

include ApplicationHelper

class ApartmentsController < ApplicationController
  def index
    if params[:commit] && params[:commit] != "Filter"
      session[:sort] = ''
      session[:price] = ''
      session[:search] = ''
      flash.clear
      redirect_to and return
    end
    @sort = params[:sort] || session[:sort]
    @price = params[:price] || session[:price]
    @search = params[:search] || session[:search]

    if (params[:sort] != session[:sort]) ||
      (params[:price] != session[:price]) ||
      (params[:search] != session[:search])
      session[:sort] = @sort
      session[:price] = @price
      session[:search] = @search
      redirect_to sort: @sort, price: @price, search: @search and return
    end

    ordering = case @sort
               when 'rating_desc'
                 { rating: :desc }
               when 'rating_asc'
                 { rating: :asc }
               when 'price_desc'
                 { price: :desc }
               when 'price_asc'
                 { price: :asc }
               end
    price_range = nil
    unless @price.nil?
      price_range = {
        '0-999': [0, 999],
        '1000-1499': [1000, 1499],
        '1500-1999': [1500, 1999],
        '2000': [2000, nil]
      }[@price.to_sym]
    end
    @apartments = Apartment.filter(@search, price_range)
    if ordering
      @apartments = @apartments.sort_by { |apartment| apartment.send(ordering.keys[0]) }
      @apartments.reverse! if ordering.values[0] == :desc
    end

    flash[:notice] = "No apartment found with the filters." if @apartments.empty?
  end

  def show
    id = params[:id]
    @apartment = Apartment.find id
  end

  def new
    return if session[:user_id]

    flash[:warning] = "You must be signed in to add apartment resources."
    redirect_back fallback_location: apartments_url
  end

  def create
    permitted = apartment_params

    # Handle image upload
    unless permitted[:image].nil? || (permitted[:image] == "")
      file_data = permitted[:image]
      permitted[:image] = Base64.encode64(file_data.read)
    end

    unless validate_aptmt_params permitted
      flash[:warning] = "Invalid parameters."
      redirect_to new_apartment_path and return
    end

    @apartment = Apartment.create!(permitted)
    flash[:notice] = "'#{@apartment.name}' was successfully created."
    redirect_to apartments_path
  end

  def edit
    unless session[:user_id]
      flash[:warning] = "You must be signed in to edit apartment resources."
      redirect_back fallback_location: apartment_path(params[:id]) and return
    end
    @apartment = Apartment.find params[:id]
  end

  def update
    @apartment = Apartment.find params[:id]
    permitted = apartment_params
    unless ApplicationHelper.validate_aptmt_params(permitted)
      flash[:warning] = "Invalid parameters."
      redirect_to edit_apartment_path(@apartment) and return
    end

    # Handle image upload
    unless permitted[:image].nil? || (permitted[:image] == "")
      file_data = permitted[:image]
      permitted[:image] = Base64.encode64(file_data.read)
    end

    @apartment.update!(permitted)
    flash[:notice] = "'#{@apartment.name}' was successfully updated."
    redirect_to apartment_path(@apartment)
  end

  private

  def apartment_params
    params.require(:apartment).permit(:name, :price, :image, :description, :address)
  end
end
