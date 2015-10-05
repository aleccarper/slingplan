class VendorRfp < ActiveRecord::Base
  extend OrderAsSpecified

  belongs_to :location
  belongs_to :service_rfp
  has_one :negotiation, dependent: :destroy

  validates :location, presence: true
  validates :service_rfp, presence: true

  after_create :after_create

  def self.per_page; 4 end
  scope :get_pages, -> { all.in_groups_of(VendorRfp.per_page).map(&:compact) }
  scope :get_page, lambda { |p| get_pages[p.to_i] }

  scope :bookmarked_first, lambda { |bookmark_ids|
    all.to_a.partition { |vrfp| bookmark_ids.include? vrfp.location.id }.flatten
  }

  scope :under_event_for_location, lambda { |event_id, location_id|
    query = "SELECT * FROM under_event_for_location(#{event_id}, #{location_id})"
    connection.execute(query).map do |r|
      [
        r['negotiation_id'],
        r['vendor_rfp_id']
      ]
    end
  }

  scope :by_responses, -> {
    ids = includes(:negotiation).sort { |v1, v2| v1.negotiation.messages.count <=> v2.negotiation.messages.count }.map(&:id)
    where('id IN (?)', ids).order_as_specified(id: ids).reverse_order || []
  }

  def after_create
    self.negotiation = Negotiation.new(planner: service_rfp.event.planner)
    self.save

    self.location.vendor.rfp_created
  end

  def last_message_with_bid
    with_bids = negotiation.messages.where.not(bid: nil)
    return nil if with_bids.empty?
    last_bidding_message = with_bids.order(created_at: :asc).last

    revoked = negotiation.messages.where(action: 'revoke')
    return last_bidding_message if revoked.empty?
    last_revoking_message = revoked.order(created_at: :asc).last
    return last_revoking_message.id > last_bidding_message.id ? nil : last_bidding_message
  end

  def current_bid_placed_by?(vendor)
    msg = self.last_message_with_bid
    return false if msg.nil?
    msg.owner == vendor
  end

  def current_bid
    m = last_message_with_bid
    m.blank? ? nil : m.bid
  end

  def has_bid?
    not current_bid.nil?
  end

  def bid_approved?
    negotiation.is_closed?
  end

  def vendor_path
    self.negotiation.vendor_path
  end

  def planner_path
    self.negotiation.planner_path
  end
end
