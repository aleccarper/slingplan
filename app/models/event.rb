class Event < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :planner, foreign_key: 'planner_id'
  has_many :service_rfps, dependent: :destroy
  accepts_nested_attributes_for :service_rfps, allow_destroy: true
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :services

  serialize :hidden_contact_info

  after_initialize :defaults
  after_validation :set_full_address, on: [:create, :update]
  before_save :geocode
  after_save :sync_service_rfps
  geocoded_by :full_address

  validates :planner, presence: true
  validates :name, presence: true, length: { maximum: 48 }
  validates :zip, allow_blank: true, format: { with: /\b\d{5}(-\d{4})?\b/ }
  validates :city, presence: true
  validates :state, presence: true
  validates :country_code, presence: true


  def self.per_page; 4 end
  scope :get_pages, -> { all.in_groups_of(Event.per_page).map(&:compact) }
  scope :get_page, lambda { |p| get_pages[p.to_i] }

  scope :confirmed, -> { where(confirmed: true) }
  scope :unconfirmed, -> { where(confirmed: false) }

  scope :today, -> {
    datetime_today = Time.zone.now.to_datetime.midnight
    datetime_tomorrow = datetime_today + 1.day
    where('(end_date IS NULL AND start_date >= ? AND start_date < ?) OR (start_date <= ? AND end_date >= ?)', datetime_today, datetime_tomorrow, datetime_today, datetime_tomorrow)
  }

  scope :future, -> {
    datetime_today = Time.zone.now.to_datetime.midnight
    datetime_tomorrow = datetime_today + 1.day
    where('(end_date IS NULL AND start_date >= ?) OR (end_date IS NOT NULL AND start_date >= ?)', datetime_today, datetime_today)
  }

  scope :past, -> {
    datetime_today = Time.zone.now.to_datetime.midnight
    datetime_tomorrow = datetime_today + 1.day
    where('(end_date IS NULL AND start_date < ?) OR (end_date IS NOT NULL AND end_date < ?)', datetime_today, datetime_today)
  }

  scope :by_today_future_and_past, -> {
    { today: today, future: future, past: past }
  }

  scope :active, -> {
    now = Time.zone.now.to_datetime
    where('(end_date IS NULL AND start_date >= ?) OR (end_date IS NOT NULL AND end_date >= ?)', now, now)
  }

  def self.potentially_hidden_contact_info
    [ :primary_phone_number,
      :primary_email,
      :primary_website,
      :company_name ]
  end

  def contact_info_hidden_for?(attribute)
    self.hidden_contact_info.include? attribute.to_sym
  end

  def defaults
    self.hidden_contact_info ||= []
  end

  def owner
    planner
  end

  def active?
    (end_date.nil? and start_date >= Time.zone.now.to_date) or (not end_date.nil? and end_date >= Time.zone.now.to_date)
  end

  def under_way?
    if end_date.nil?
      start_date.midnight == Time.zone.now.to_datetime.midnight
    else
      start_date.midnight <= Time.zone.now.to_datetime and end_date.tomorrow.midnight >= Time.zone.now.to_datetime
    end
  end

  def is_in_future?
    if start_date.blank? then false else start_date > Time.zone.now.to_datetime end
  end

  def date_from_or_ago_in_words
    if is_in_future?
      "takes place in #{time_ago_in_words(start_date)}"
    elsif under_way?
      "started #{time_ago_in_words(start_date)} ago"
    else
      if end_date.nil?
        "took place #{time_ago_in_words(start_date)} ago"
      else
        "took place #{time_ago_in_words(end_date)} ago"
      end
    end
  end

  def distance_in_miles(geocoded_model)
    self.distance_from([geocoded_model.latitude, geocoded_model.longitude]).to_i
  end

  def sync_service_rfps
    return if services.blank?

    # destroy service_rfps for service no longer attached
    service_ids_specified = self.services.map(&:id)
    self.service_rfps.each do |service_rfp|
      unless service_ids_specified.include? service_rfp.service.id
        service_rfp.destroy!
      end
    end

    # create service_rfps for new services attached
    service_ids_covered = self.service_rfps.map(&:service).map(&:id)
    self.services.each do |service|
      unless service_ids_covered.include? service.id
        self.service_rfps << ServiceRfp.new({ service: service })
      end
    end
  end

  def service_rfps_completed
    self.service_rfps
      .map(&:completed?)
      .reject(&:blank?)
      .count
  end

  def all_service_rfps_completed?
    self.service_rfps_completed == self.service_rfps.count
  end

  def has_any_rfps?
    self.service_rfps.count > 0
  end

  def unread_message_links(model)
    negotiations = self.service_rfps
      .map(&:vendor_rfps).flatten
      .map(&:negotiation).map { |n|
        n.messages
          .where.not("#{model}_id".to_sym => nil)
          .where(read: false)
      }.flatten
      .map(&:negotiation)
      .uniq
      .map { |n|
        text, path = if model == :planner
          [n.vendor_rfp.service_rfp.event.planner.name, n.vendor_path]
        elsif model == :vendor
          [n.vendor_rfp.location.name, n.planner_path]
        end
        Hash[text, path]
      }
  end

  def has_unread_messages?(model)
    self.service_rfps
      .map(&:vendor_rfps)
      .flatten
      .map(&:negotiation)
      .map { |n|
        n.messages
         .where.not("#{model}_id".to_sym => nil)
         .where(read: false)
      }.flatten
      .any?
  end

  def get_full_address
    [address1, address2, city, state, zip.to_s].reject(&:blank?).join(' ')
  end

  def clone
    # shallow copy
    self.dup.tap do |e|
      e.start_date = nil
      e.end_date = nil
      e.planner = self.planner
      e.confirmed = false
      self.services.each { |s| e.services << s }
      self.service_rfps.each { |s| e.service_rfps << s.dup }
    end
  end



  private

  def set_full_address
    self.full_address = get_full_address
  end

end

