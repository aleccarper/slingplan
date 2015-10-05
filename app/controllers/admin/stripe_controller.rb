class Admin::StripeController < AdminController
  layout 'admin'

  def new_coupon
    @coupon = Coupon.new
  end

  def create_coupon
    @coupon = Coupon.new(params_for_coupon)
    @coupon.currency = 'usd'

    if @coupon.valid?
      begin
        Stripe::Coupon.create(@coupon.as_json(except: ['validation_context', 'errors']))
        return redirect_to '/admin/stripe'
      rescue Exception => e
        @errors = e.message
        return render :new_coupon
      end
    end
    flash_errors(@coupon)
    render :new_coupon
  end

  def delete_coupon
    begin
      @coupon = Stripe::Coupon.retrieve(params[:coupon_id].to_s)
      @coupon.delete
      return redirect_to '/admin/stripe'
    rescue Exception => e
      flash[:alert] = e.message
      return redirect_to '/admin/stripe'
    end
  end



  private

  def params_for_coupon
    params.require(:coupon).permit(
      :id,
      :currency,
      :duration,
      :amount_off,
      :max_redemptions
    )
  end

end


