class Location < ActiveRecord::Base
  geocoded_by :full_address

  has_many :locations_services, class_name: 'LocationsServices'
  has_many :services, through: :locations_services, source: :service

  has_and_belongs_to_many :events
  belongs_to :vendor, foreign_key: 'vendor_id'
  belongs_to :admin, foreign_key: 'admin_id'
  has_many :claims, class_name: 'Claim'
  has_many :claimants, through: :claims, source: :vendor
  has_many :vendor_rfps, foreign_key: 'location_id'


  after_initialize  :defaults
  before_validation :add_url_protocol
  after_validation :set_full_address, on: [:create, :update]
  before_save       :geocode
  after_save        :expire_states_with_locations
  after_destroy     :expire_states_with_locations
  after_commit      :after_commit


  validate :vendor_xor_admin
  validate :services_are_unique
  validates :name, presence: true, length: { maximum: 72 }
  validates :zip, allow_blank: false, format: { with: /\b\d{5}(-\d{4})?\b/ }
  validates :city, presence: true
  validates :state, presence: true
  validates :phone_number, presence: true
  validates :country_code, presence: true
  validates :email, allow_blank: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

  def self.per_page; 4 end
  scope :get_pages, -> { all.in_groups_of(Location.per_page).map(&:compact) }
  scope :get_page, lambda { |p| get_pages[p.to_i] }

  scope :admin_owned, -> { where.not(admin_id: nil) }
  scope :vendor_owned, -> { where.not(vendor_id: nil) }

  scope :confirmed, -> { where(confirmed: true) }
  scope :unconfirmed, -> { where(confirmed: false) }
  scope :active, -> { where(status: 'active') }
  scope :negotiating, lambda { |vendor_id|
    q = "SELECT * FROM vendor_locations_with_open_negotiations(#{vendor_id})"
    connection.execute(q).map { |r| [r['location_id'], r['negotiation_id']] }
  }

  scope :location_events, lambda { |location_id|
    connection.execute("SELECT * FROM location_events(#{location_id})").map do |r|
      [
        r['event_id'],
        r['location_id'],
        r['vendor_rfp_id'],
        r['service_rfp_id']
      ]
    end
  }

  scope :by_service_state_and_city, lambda { |service_ids|
    service_hash = Hash[service_ids.map { |s| [Service.find(s).name, s] }]

    service_hash.each do |name, id|
      groups = includes(:services)
        .joins(:services)
        .where('services.id = ?', id)
        .group_by { |loc| [loc.city, loc.state] }

      results = {}
      groups.each do |g|
        city, state, locations = g[0][0], g[0][1], g[1]
        results[state] = {} unless results.has_key? state
        results[state][city] = [] unless results[state].has_key? city
        locations.each { |loc| results[state][city] << loc }
      end
      service_hash[name] = results
    end
    service_hash
  }

  scope :by_state_and_city, -> {
    groups = all.group_by { |loc| [loc.city.titleize, loc.state] }
    results = {}
    groups.each do |g|
      city, state, locations = g[0][0], g[0][1], g[1]
      results[state] = {} unless results.has_key? state
      results[state][city] = [] unless results[state].has_key? city
      locations.each { |loc| results[state][city] << loc }
    end
    results
  }

  scope :by_state_ordered_by_city, -> {
    groups = all.group_by { |loc| loc.state }
    groups.each do |g|
      g[1].sort_by! { |l| l.city }
    end
    groups
  }


  scope :account_valid, -> {
    where('locations.id IN (?)',
      ActiveRecord::Base.connection.execute(
        'SELECT l.id FROM locations AS l
        LEFT JOIN vendors AS v ON v.id = l.vendor_id
        WHERE l.admin_id IS NOT NULL
        OR v.subscribed IS TRUE'
      ).to_a.collect { |l| l['id'] }
    )
  }

  comma do; id; name; address1; address2; city; state; zip; phone_number; email; website end

  def expire_states_with_locations
    Rails.cache.delete('states_with_locations')
  end

  def owner
    vendor or admin
  end

  def being_claimed?
    self.claims.any?
  end

  def active?
    self.status == 'active'
  end

  def confirm!
    self.update_attribute(:confirmed, true)
  end

  def after_commit
    unless vendor.nil?
      active_ids = vendor.locations.active.map(&:id).to_a
      vendor.update_attribute(:active_location_ids, active_ids)
    end
  end

  def owned_by_class?(vendor_or_admin)
    case vendor_or_admin
    when :vendor then not vendor.blank? and admin.blank?
    when :admin then vendor.blank? and not admin.blank?
    end
  end

  def empty?
    ignored_attrs = {'id' => 1, 'created_at' => 1, 'updated_at' => 1}
    self.attributes.all?{|k,v| v.blank? || ignored_attrs[k]}
  end

  def vendor_xor_admin
    unless vendor.blank? ^ admin.blank?
      errors.add(:base, "Location must have a vendor or admin.")
    end
  end

  def services_are_unique
    if services.length != services.uniq.length
      errors[:services] << 'must be unique'
    end
  end

  def add_url_protocol
    unless self.website.blank?
      unless self.website[/\Ahttp:\/\//] || self.website[/\Ahttps:\/\//]
        self.website = "http://#{self.website}"
      end
    else
      self.website = ''
    end
  end

  def defaults
    self.country_code ||= 'US'
  end

  def get_full_address
    [address1, address2, city, state, zip.to_s].reject(&:blank?).join(' ')
  end

  def negotiations
    VendorRfp.includes(:negotiation)
      .where(location_id: self.id)
      .map(&:negotiation)
  end



  private

  def set_full_address
    self.full_address = get_full_address
  end

  # mapping do
  #   indexes :services do
  #     indexes :name
  #     indexes :description
  #   end
  # end

  # def as_indexed_json(options={})
  #   self.as_json(
  #     include: {
  #                 services:   { only: [:name, :description]}
  #              })
  # end

  # after_commit on: [:create, :update] do
  #   index_document
  # end

  # def self.search(query, options={})
  #   @search_definition = {
  #     query: {}
  #   }

  #   unless query.blank?
  #     @search_definition[:query] = {
  #       fuzzy: {
  #         _all: query
  #       }
  #     }
  #   else
  #     @search_definition[:query] = { match_all: {} }
  #     @search_definition[:sort]  = { published_on: 'desc' }
  #   end

  #   @search_definition[:sort]  = { options[:sort] => 'desc' }
  #   @search_definition[:track_scores] = true

  #   unless query.blank?
  #     @search_definition[:suggest] = {
  #       text: query,
  #       suggest_title: {
  #         term: {
  #           field: 'title.tokenized',
  #           suggest_mode: 'always'
  #         }
  #       },
  #       suggest_body: {
  #         term: {
  #           field: 'content.tokenized',
  #           suggest_mode: 'always'
  #         }
  #       }
  #     }
  #   end
  #   __elasticsearch__.search(@search_definition)
  # end
end

