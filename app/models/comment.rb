class Comment < ActiveRecord::Base
  def self.rating_of(apartment_id)
    where(apartment_id: apartment_id).average(:rating) || 0
  end

  def apartment
    Apartment.find(apartment_id)
  end

  def user
    User.find(user_id)
  end

  def tags_array
    tags.split(",")
  end
end
