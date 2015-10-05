class ServiceRfp < ActiveRecord::Base
  include Notifier

  belongs_to :event, foreign_key: 'event_id'
  belongs_to :service
  has_many :vendor_rfps, dependent: :destroy

  serialize :hidden_locations

  validates :service, presence: true
  validates :event, presence: true
  #validates :notes, presence: true, if: :created?
  validates :radius, presence: true
  validates :budget, allow_blank: true, format: {
    with: /(\d*)\.?(\d*)/
  }

  after_initialize :defaults

  def service_name
    self.service.name
  end

  def defaults
    self.hidden_locations ||= []
    self.radius ||= default_radius
  end

  def completed?
    self.vendor_rfps.select { |vrfp| vrfp.bid_approved? }.any?
  end

  def hide_location(location)
    current = hidden_locations || []
    self.update_attribute(:hidden_locations, current << location.id)
  end

  def unhide_location(location)
    hidden_locations.delete(location.id)
  end

  def make_outside_arrangements!
    self.outside_arrangements = true
    if self.save
      self.vendor_rfps.each do |vrfp|
        msg = NegotiationMessage.new.tap do |m|
          m.negotiation_id = vrfp.negotiation.id
          m.planner_id = self.event.planner.id
          m.action = vrfp.negotiation.status == 'closed' ? 'revoke' : 'reply'
          m.content = "[Automated Message] Outside arrangements have been made for #{self.service.name}, but bids may still be placed in case the RFP is reopened."
        end
        msg.save
      end
    end
  end

  def cancel_outside_arrangements!
    self.outside_arrangements = false
    if self.save
      self.vendor_rfps.each do |vrfp|
        msg = NegotiationMessage.new.tap do |m|
          m.negotiation_id = vrfp.negotiation.id
          m.planner_id = self.event.planner.id
          m.action = 'reply'
          m.content = "[Automated Message] Outside arrangements have been cancelled for #{self.service.name}, and the RFP has been reopened for bidding and negotiation."
        end
        msg.save
      end
    end
  end

  def has_outside_arrangements?
    self.outside_arrangements
  end

  def eligible_locations(mile_radius: nil)
    distance = mile_radius || self.radius
    locations = service.locations
      .vendor_owned
      .account_valid
      .active
      .near([event.latitude, event.longitude], distance)
    unless hidden_locations.blank?
      locations = locations.where('id NOT IN (?)', hidden_locations)
    end
    locations
  end

  def generate_vendor_rfps
    eligible_locations.each do |location|
      generate_vendor_rfp(location)
    end
  end

  def generate_vendor_rfp(location)
    vendor_rfps << VendorRfp.new(location: location)
  end

  def default_radius
    100
  end
end

