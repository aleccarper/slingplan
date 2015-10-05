class TooltipsController < ApplicationController
  def for_route
    render json: common.merge(page[params[:current_controller]] || {})
  end



  private

  # tooltips for every page
  def common
    {
      'manage-account' => 'Manage Account',
      'inquiries' => 'Inquiries',
      'edit-location' => 'Edit Location',
      'delete-location' => 'Delete Location',
      'manage-event' => 'Manage Event',
      'export' => 'Export Bookmarks',
      'sign-out' => 'Sign Out',
      'notifications' => 'Notifications',
      'expand' => 'Expand',
      'collapse' => 'Collapse'
    }
  end

  # tooltips for specific pages
  def page
    {
      'vendors-admin-sessions' => {
        'forgot-password' => 'Recover your password'
      },
      'planners-admin-events' => {
        'drag-to-adjust' => 'Drag to adjust'
      }
    }
  end
end
