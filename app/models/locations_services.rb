class LocationsServices < ActiveRecord::Base
  belongs_to :location
  belongs_to :service
end
