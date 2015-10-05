class StaffersController < ApplicationController
  def resume
    staffer = Staffer.find_by_id(params[:id])
    file_path = "#{Rails.root}/public#{staffer.resume.url}".gsub(/(\?\d+)/, '')
    send_file(file_path, {
      filename: staffer.resume_file_name,
      type: staffer.resume_content_type
    })
  end
end
