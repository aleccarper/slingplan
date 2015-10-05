require 'ostruct'

module FlashHelper

  def flash_messages
    {
      card_declined: {
        type: :alert,
        title: 'Your card was declined'
      },
      subscription_set_to_cancel: {
        type: :alert,
        title: 'Your subscription is set to end'
      },
      card_updated_successfully: {
        type: :notice,
        title: 'Card updated'
      },
      update_plan_success: {
        type: :notice,
        title: 'Subscription Updated'
      },
      subscription_activated: {
        type: :notice,
        title: 'Subscription Activated'
      },
      subscription_cancelation_reverted: {
        type: :notice,
        title: 'Subscription Cancelation Reverted'
      }
    }
  end

  def flash_background
    return unless flash_message_exists?
    content_tag :div, class: flash_background_classes do
      [ flash_background_controls,
        flash_background_title,
        flash_background_body
      ].join(' ').html_safe
    end
  end

  def flash_background_classes
    classes = ['flash-background']
    classes << 'persistent' if flash_message.type == :persistent
    classes << 'shown' unless flash_message.blank?
    classes.join(' ')
  end

  def flash_background_controls
    controls = ''
    unless flash_message.type == :persistent
      controls << content_tag(:div, icon('times'), class: 'hide')
    end
    if flash_message_partial_exists?
      controls << content_tag(:div, icon('question'), class: 'expand')
      controls << content_tag(:div, icon('angle-double-down'), class: 'collapse')
    end
    controls
  end

  def flash_background_title
    content_tag :div, class: flash_message.type do
      flash_message.title.html_safe
    end
  end

  def flash_background_body
    # does partial exist?
    return '' unless flash_message_partial_exists?
    path = "flash/#{flash_message.type.to_s}/#{flash_message_key.to_s}"
    content_tag :div, class: 'body' do
      content_tag :div, render(partial: path)
    end
  end

  def flash_message_partial_exists?
    partial_path = "flash/#{flash_message.type.to_s}/_#{flash_message_key.to_s}"
    lookup_context.find_all(partial_path).any?
  end

  def flash_message_exists?
    flash_messages.has_key? flash_message_key
  end

  def flash_message_key
    flash[:flash_background].to_sym unless flash[:flash_background].nil?
  end

  def flash_message
    if flash_message_exists?
      return OpenStruct.new flash_messages[flash_message_key]
    end
    nil
  end

end
