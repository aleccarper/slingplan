class BlogPost < ActiveRecord::Base
  self.per_page = 10

  belongs_to :admin

  before_create :generate_preview_hash

  validates :title,
    presence: true,
    length: { minimum: 2 }

  validates :content,
    presence: true,
    length: { minimum: 2 }

  validates :description,
    presence: true

  def preview_authenticated?(hash)
    hash == preview_hash
  end

  private

  def generate_preview_hash
    self.preview_hash = Digest::SHA256.hexdigest self.title
  end
end
