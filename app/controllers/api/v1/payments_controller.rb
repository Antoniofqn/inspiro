class Api::V1::PaymentsController < Api::ApiController

  # Create a checkout session
  def create_checkout_session
    begin
      root_url = ENV['ROOT_URL']
      session = Stripe::Checkout::Session.create({
        mode: 'subscription',
        line_items: [{
          price: ENV['STRIPE_PRICE_ID'],
          quantity: 1
        }],
        success_url: "#{root_url}/payments/success?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: "#{root_url}/payments/cancel",
        customer_email: current_user.email
      })

      render json: { url: session.url }, status: :see_other
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # Create a billing portal session
  def create_portal_session
    begin
      # Retrieve the customer ID from the latest checkout session
      checkout_session = Stripe::Checkout::Session.retrieve(params[:session_id])

      session = Stripe::BillingPortal::Session.create({
        customer: checkout_session.customer,
        return_url: root_url
      })

      render json: { url: session.url }, status: :see_other
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
