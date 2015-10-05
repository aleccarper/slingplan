class CouponController < ApplicationController

  def validate_coupon
    code = params[:code]
    @coupons = Stripe::Coupon.all['data']

    index = @coupons.find_index { |c| c.id == code }

    if index.nil?
      render json: { success: false }
    else
      render json: {
        success: true,
        view: render_to_string({
          partial: 'vendors/admin/account/billing/entered_coupon',
          formats: [:html],
          locals: {
            coupon: @coupons[index]
          }
        })
      }
    end
  end

end
