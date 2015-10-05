class Service < ActiveRecord::Base
  has_many :locations_services, class_name: 'LocationsServices'
  has_many :locations, through: :locations_services, source: :location

  has_and_belongs_to_many :events
  has_many :service_rfps, dependent: :destroy

  scope :with_vendor_locations, -> {
    find(Location.vendor_owned.map { |l| l.services.map(&:id) }.flatten.uniq)
  }

  validates :name,
    format: { with: /[A-Z\sa-z ]+/i },
    presence: true,
    uniqueness: { case_sensitive: false }
end

