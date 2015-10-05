class Vendor < ActiveRecord::Base
  include StripeToolbox
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_validation :add_url_protocol
  before_create :before_create
  after_create :after_create

  has_many :locations, dependent: :destroy
  has_many :inquiries, dependent: :destroy
  has_many :claims, class_name: 'Claim'
  has_many :claimed_locations, through: :claims, source: :location
  has_many :notifications, dependent: :destroy
  has_one :settings
  has_attached_file :logo_image,
    default_url: '/images/vendor_default_:style_avatar.png',
    styles: { small: '60x60>', medium: '180x180>', large: '300x300>' }

  serialize :active_location_ids
  serialize :hidden_hints

  validates :name, presence: true, length: { minimum: 2, maximum: 72 }
  validates :accepted_terms_of_service, presence: true
  validates_attachment_content_type :logo_image, content_type: /^image\/(png|gif|jpeg|bmp)/

  validates :primary_email, allow_blank: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }


  def before_create
    self.time_zone ||= 'Central Time (US & Canada)'
    self.settings ||= Settings.new
  end

  def add_url_protocol
    unless self.primary_website.blank?
      unless self.primary_website[/\Ahttp:\/\//] || self.primary_website[/\Ahttps:\/\//]
        self.primary_website = "http://#{self.primary_website}"
      end
    else
      self.primary_website = ''
    end
  end

  def after_create
    create_customer
  end

  def create_customer
    stripe_wrapper = StripeToolbox::Wrapper.new
    stripe_toolbox = StripeToolbox::Toolbox.new
    stripe_toolbox.init_stripe

    customer = stripe_wrapper.execute(Stripe::Customer, 'create', {
      email: self.email,
    })

    self.stripe_id = customer[:id]
    self.save
  end

  def rfp_created
    end_trial
  end

  def end_trial
    if(self.billing_status == 'trial')
      stripe_toolbox = StripeToolbox::Toolbox.new
      stripe_toolbox.init_stripe

      customer = StripeToolbox::Wrapper.new.execute(Stripe::Customer, 'retrieve', self.stripe_id)
      response = stripe_toolbox.create_subscription(customer, self.subscription_id)
      self.billing_status = 'active'
      self.save

      #vendor_trial_ended_email(self)
    end
  end

  def get_max_allowed_locations(plan)
    if !plan
      return 0
    end
    plan = plan[1..-1] if plan[0] != 't'
    allowed = 0
    case plan[0..4]
      when 'tier1' then allowed = 1
      when 'tier2' then allowed = 5
      when 'tier3' then allowed = 10
      when 'tier4' then allowed = 20
      when 'tier5' then allowed = 40
      when 'tier6' then allowed = 'Unlimited'
    end
    return allowed
  end

  def archive_locations
    active_locations = self.locations.where(status: 'active')
    ids = active_locations.map { |l| l.id }.join(", ")
    self.previous_active_location_ids = ids
    self.locations.update_all(status: 'deactivated')

    self.save
  end

  def unarchive_locations
    location_ids = self.previous_active_location_ids

    if !location_ids || get_max_allowed_locations(self.subscription_id) < location_ids.split(',').count
      return
    end

    self.previous_active_location_ids = nil
    self.save

    location_ids.split(',').each do |id|
      l = Location.find(id.to_i)
      l.status = 'active'
      l.save
    end
  end

  def subscription_ended
    archive_locations
    send_subscription_ending_email

    self.billing_status = 'inactive'
    self.subscribed = false
    self.subscription_id = nil
    self.save
  end

  def send_subscription_ending_email
    case self.billing_status
      when 'active'
        VendorMailer.delay_for(15.seconds).vendor_payment_failed_email(self.reload)
      when 'cancellation_pending'
        VendorMailer.delay_for(15.seconds).vendor_subscription_ended_email(self.reload)
    end
  end

  def can_claim?(loc)
    loc.owned_by_class?(:admin) and not claims.where(location_id: loc.id).any?
  end

  def claimed?(loc)
    loc.claims.where(location_id: loc.id).any?
  end

  def locations_negotiating
    id_array = Location.negotiating(self.id)
    Location.find_by_id(id_array.map(&:first))
  end
end
