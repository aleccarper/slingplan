class Claim < ActiveRecord::Base
  belongs_to :vendor
  belongs_to :location

  validate :vendor, presence: true
  validate :location, presence: true

  def after_create
    self.reload
    Admin.all.each do |admin|
      ClaimsMailer.delay_for(15.seconds).new_claim_notification_email(admin.id, self.id)
    end
  end

  def approve
    location.vendor = vendor
    location.admin = nil
    location.status = 'inactive'
    location.save
    self.status = 'approved'
    self.save
    self.reload

    Notifier::Manager.notify(self.vendor, 'Claim Approved!', 'A location claim has been approved!', '/vendors/admin/locations', 1);
    ClaimsMailer.delay_for(15.seconds).claim_approved_notification(self.vendor.id, self.id)
  end

  def deny
    self.status = 'denied'
    self.save
    self.reload

    Notifier::Manager.notify(self.vendor, 'Claim Denied', 'A location claim has been denied.', '/vendors/admin/locations', 3);
    ClaimsMailer.delay_for(15.seconds).claim_denied_notification(self.vendor.id, self.id)
  end

  def cancel
    self.status = 'cancelled'
    self.save
    self.reload

    Admin.all.each do |admin|
      ClaimsMailer.delay_for(15.seconds).canceled_claim_notification_email(admin.id, self.id)
    end
  end
end
