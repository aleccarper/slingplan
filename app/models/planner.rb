class Planner < ActiveRecord::Base
  include StripeToolbox
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_validation :add_url_protocol
  before_create :before_create
  after_create :after_create

  has_many :events, dependent: :destroy
  has_many :inquiries, dependent: :destroy
  has_many :inquiry_messages, dependent: :destroy
  has_many :negotiations, dependent: :destroy
  has_many :negotiation_messages, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :bookmark_lists, dependent: :destroy
  has_one :settings, foreign_key: 'planner_id'
  has_attached_file :logo_image,
    default_url: '/images/planner_default_:style_avatar.png',
    styles: { small: '60x60>', medium: '180x180>', large: '300x300>' }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :accepted_terms_of_service, presence: true
  validates_attachment_content_type :logo_image, content_type: /^image\/(png|gif|jpeg|bmp)/

  validates :primary_email, allow_blank: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def before_create
    self.time_zone ||= 'Central Time (US & Canada)'
    self.settings ||= Settings.new
  end

  def after_create
    stripe_wrapper = StripeToolbox::Wrapper.new
    stripe_toolbox = StripeToolbox::Toolbox.new
    stripe_toolbox.init_stripe

    customer = stripe_wrapper.execute(Stripe::Customer, 'create', {
      email: self.email,
    })

    self.stripe_id = customer[:id]

    plan = 'ptier1m'
    response = stripe_toolbox.create_subscription(customer, plan)

    self.subscribed = true
    self.subscription_id = plan
    self.billing_status = 'active'
    self.sign_up_step = 'completed'
    self.save

    PlannerMailer.planner_welcome_email(self).deliver
  end

  def subscription_ended
    send_subscription_ending_email

    stripe_wrapper = StripeToolbox::Wrapper.new
    stripe_toolbox = StripeToolbox::Toolbox.new
    stripe_toolbox.init_stripe

    plan = 'ptier1m'
    customer =  stripe_wrapper.execute(Stripe::Customer, 'retrieve', self.stripe_id)

    response = stripe_toolbox.create_subscription(customer, plan)

    self.subscribed = true
    self.subscription_id = plan
    self.billing_status = 'active'
    self.save

  end

  def send_subscription_ending_email
    case self.billing_status
      when 'active'
        PlannerMailer.delay_for(15.seconds).planner_payment_failed_email(self.reload)
      when 'cancellation_pending'
        PlannerMailer.delay_for(15.seconds).planner_subscription_ended_email(self.reload)
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
end
