class Staffer < ActiveRecord::Base
  include StripeToolbox
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_validation :add_url_protocol
  before_create :before_create
  after_create :after_create

  after_validation :set_full_address, on: [:create, :update]
  before_save :geocode
  geocoded_by :full_address

  has_many :inquiries, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one :settings
  has_attached_file :logo_image,
    default_url: '/images/staffer_default_:style_avatar.png',
    styles: { small: '60x60>', medium: '180x180>', large: '300x300>' }
  has_attached_file :resume

  serialize :hidden_hints

  validates :name, presence: true, length: { minimum: 2, maximum: 72 }
  validates :accepted_terms_of_service, presence: true
  validates_attachment_content_type :logo_image, content_type: /^image\/(png|gif|jpeg|bmp)/
  validates_attachment_content_type :resume, content_type: %w(application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document)
  validate :resume_content_type, message: ", Only PDF or WORD files are allowed."
  validates :zip, allow_blank: false, format: { with: /\b\d{5}(-\d{4})?\b/ }
  validates :city, presence: true
  validates :state, presence: true

  validates :primary_email, allow_blank: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

  scope :by_state_and_city, -> {
    groups = all.group_by { |staffer| [staffer.city.titleize, staffer.state] }
    results = {}
    groups.each do |g|
      city, state, staffers = g[0][0], g[0][1], g[1]
      results[state] = {} unless results.has_key? state
      results[state][city] = [] unless results[state].has_key? city
      staffers.each { |staffer| results[state][city] << staffer }
    end
    results
  }

  def before_create
    self.time_zone ||= 'Central Time (US & Canada)'
    self.settings ||= Settings.new
  end

  def current_resume_url
    if Rails.env.development?
      "/staffers/#{self.id}/resume"
    else
      resume.url.gsub(/(\?\d+)/, '')
    end
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

  def subscription_ended
    send_subscription_ending_email

    self.billing_status = 'inactive'
    self.subscribed = false
    self.subscription_id = nil
    self.save
  end

  def send_subscription_ending_email
    case self.billing_status
      when 'active'
        StafferMailer.delay_for(15.seconds).staffer_payment_failed_email(self.reload)
     when 'cancellation_pending'
        StafferMailer.delay_for(15.seconds).staffer_subscription_ended_email(self.reload)
     end
  end

  def get_full_address
    [address1, address2, city, state, zip.to_s].reject(&:blank?).join(' ')
  end



  private

  def set_full_address
    self.full_address = get_full_address
  end
end
