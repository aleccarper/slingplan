class AddFileAttachmentToNegotiationMessagesAndInquiries < ActiveRecord::Migration
  def self.up
    add_attachment :inquiry_messages, :file_attachment
    add_attachment :negotiation_messages, :file_attachment
  end

  def self.down
    remove_attachment :inquiry_messages, :file_attachment
    remove_attachment :negotiation_messages, :file_attachment
  end
end
