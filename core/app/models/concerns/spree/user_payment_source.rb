module Spree
  module UserPaymentSource
    extend ActiveSupport::Concern

    included do
      has_many :credit_cards, class_name: "Spree::CreditCard", foreign_key: :user_id
    end

    def default_credit_card
      ActiveSupport::Deprecation.warn(
        "user.default_credit_card is deprecated. Please use user.wallet.default.source instead.",
        caller
      )
      default = wallet.default
      if default && default.source.is_a?(Spree::CreditCard)
        default.source
      end
    end

    def payment_sources
      credit_cards.with_payment_profile
    end
  end
end
