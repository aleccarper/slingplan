class Admin < ActiveRecord::Base
  devise :database_authenticatable, :recoverable,
    :rememberable, :trackable, :validatable

  has_attached_file :logo_image,
    styles: {
      small: '60x60>',
      medium: '180x180>',
      large: '300x300>'
    },
    default_url: '/images/admin_default_:style_avatar.png'

  has_many :locations, dependent: :destroy
  has_many :seed_uploads

  validates_attachment_content_type :logo_image,
                                    content_type: /^image\/(png|gif|jpeg)/



  def name
    email.match(/(\w+)@.*/).captures.first.titleize
  end
end
