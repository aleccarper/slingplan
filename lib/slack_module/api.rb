require 'slack-notifier'
require 'active_support/core_ext/integer/inflections'

module SlackModule

  class API

    # Launch Subscribers
    def self.notify_launch_subscriber_created(email, total)
      msg = "*Launch Subscriber Created* (#{total} total)\n"
      msg << "\tEmail: #{email}\n"
      self.notify msg
    end



    # Beta Testers
    def self.notify_beta_tester_created(email, password)
      msg = "*Beta Tester Created*\n"
      msg << "\tEmail:    #{email}\n"
      msg << "\tPassword: #{password}"
      self.notify msg
    end



    # Admins
    def self.notify_admin_location_created(admin, location, path, total_admin_locations)
      msg = "*Admin Location Created* (#{total_admin_locations} total)\n"
      msg << "\tAdmin:    #{admin.email}\n"
      msg << "\tLocation: [#{location.name}](#{path})"
      self.notify msg
    end

    def self.notify_seed_upload_started(seed_upload)
      msg = "*Seed Upload Started*\n"
      msg << "\tFile:          #{seed_upload.file.url}\n"
      msg << "\tSeedUpload ID: #{seed_upload.id}"
      self.notify msg
    end

    def self.notify_seed_upload_sheet_change(sheet_name)
      msg = "\tParsing sheet #{sheet_name}"
      self.notify msg
    end

    def self.notify_seed_upload_errors(seed_upload, errors)
      msg = "*Seed Upload Error*\n"
      msg << "\tFile:    #{seed_upload.file.url}"
      self.notify msg, [{
        fallback: 'Seed Upload Errors',
        text: errors.to_json,
        color: 'danger'
      }]
    end

    def self.notify_seed_upload_finished(seed_upload, locations)
      msg = "*Seed Upload Finished*\n"
      msg << "\tFile:     #{seed_upload.file.url}\n"
      msg << "\tLocations: #{locations.count}"
      self.notify msg
    end



    # Planners
    def self.notify_planner_created(planner, total_subscribers)
      msg = "*Planner Created* (#{total_subscribers} total)\n"
      msg << "\tPlanner: #{planner.email}"
      self.notify msg
    end

    def self.notify_planner_subscription_created(planner, plan, total_subscribers)
      msg = "*Subscription Created* (#{total_subscribers} total)\n"
      msg << "\tPlanner: #{planner.email}\n"
      msg << "\tPlan: #{plan}"
      self.notify msg
    end

    def self.notify_planner_subscription_cancelled(planner, plan, total_subscribers)
      msg = "*Subscription Cancelled* (#{total_subscribers} remaining)\n"
      msg << "\tPlanner: #{planner.email}"
      self.notify msg
    end



    # Vendors
    def self.notify_vendor_created(vendor, path, total_subscribers)
      msg = "*Vendor Created* (#{total_subscribers} total)\n"
      msg << "\tVendor: [#{vendor.name}](#{path})"
      self.notify msg
    end

    def self.notify_vendor_subscription_created(vendor, path, plan, total_subscribers)
      msg = "*Subscription Created* (#{total_subscribers} total)\n"
      msg << "\tVendor: [#{vendor.name}](#{path})\n"
      msg << "\tPlan:   #{plan}"
      self.notify msg
    end

    def self.notify_vendor_subscription_cancelled(vendor, path, plan, total_subscribers)
      msg = "*Subscription Cancelled* (#{total_subscribers} remaining)\n"
      msg << "\tVendor: [#{vendor.name}](#{path})"
      self.notify msg
    end

    def self.notify_claim_created(claim, claim_path, claimed, claimed_path)
      msg = "*Claim Created*\n"
      msg << "\tVendor:      [#{claim.vendor.name}](#{claim_path})\n"
      msg << "\tLocation ID: [#{claim.location.id}](#{claimed_path})"
      self.notify msg
    end



    #Staffers
    def self.notify_staffer_created(staffer, total_subscribers)
      msg = "*Staffer Created* (#{total_subscribers} total)\n"
      msg << "\tStaffer: #{staffer.name}"
      self.notify msg
    end

    def self.notify_staffer_subscription_created(staffer, plan, total_subscribers)
      msg = "*Subscription Created* (#{total_subscribers} total)\n"
      msg << "\tStaffer: #{staffer.name}\n"
      msg << "\tPlan:   #{plan}"
      self.notify msg
    end

    def self.notify_staffer_subscription_cancelled(staffer, plan, total_subscribers)
      msg = "*Subscription Cancelled* (#{total_subscribers} remaining)\n"
      msg << "\tPlanner: #{staffer.email}"
      self.notify msg
    end



    # Inquiries
    def self.notify_inquiry_created(model, inquiry, path)
      msg = "*#{model.class.name} Inquiry Created* [View Inquiry](#{path})\n"
      msg << "\tSubject:  #{inquiry.subject}\n\n"
      msg << "#{inquiry.body}"
      self.notify msg
    end



    def self.notify(message, attachments=nil)
      slack = Slack::Notifier.new(
        Rails.application.secrets['slack']['webhook_url'],
        channel: '#dev',
        username: "slingplan-#{Rails.env}"
      )
      if attachments
        slack.ping message, attachments: attachments
      else
        slack.ping message
      end
    end

  end

end
