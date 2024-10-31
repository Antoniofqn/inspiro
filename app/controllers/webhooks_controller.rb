# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET']
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      render json: { error: e.message }, status: 400
      return
    end

    handle_event(event)

    head :ok
  end

  private

  def handle_event(event)
    case event['type']
    when 'checkout.session.completed'
      handle_checkout_session_completed(event)
    when 'customer.subscription.created'
      handle_subscription_created(event)
    when 'customer.subscription.updated'
      handle_subscription_updated(event)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event)
    when 'customer.subscription.trial_will_end'
      handle_trial_will_end(event)
    end
  end

  def handle_checkout_session_completed(event)
    session = event.data.object
    user = User.find_by(email: session.customer_email)
    user.update(plan: :premium) if user
  end

  def handle_subscription_created(event)
    # Add logic for a new subscription if needed
    puts "Subscription created: #{event.id}"
  end

  def handle_subscription_updated(event)
    # Add logic to handle subscription updates if needed
    puts "Subscription updated: #{event.id}"
  end

  def handle_subscription_deleted(event)
    # Handle subscription cancellations
    puts "Subscription canceled: #{event.id}"
  end

  def handle_trial_will_end(event)
    # Notify user if trial will end soon
    puts "Subscription trial will end: #{event.id}"
  end
end
