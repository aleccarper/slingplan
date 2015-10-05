class SeedUpload < ActiveRecord::Base
  belongs_to :admin
  has_attached_file :file

  validate :file, presence: true
  validates_attachment_content_type :file,
    content_type: ['application/vnd.oasis.opendocument.spreadsheet']
end

