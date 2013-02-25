module Spree
  module Stock
    class Package
      ContentItem = Struct.new(:variant, :quantity, :status)

      attr_reader :stock_location, :order, :contents
      attr_accessor :shipping_rates

      def initialize(stock_location, order, contents=[])
        @stock_location = stock_location
        @order = order
        @contents = contents
        @shipping_rates = Array.new
      end

      def add(variant, quantity, status=:on_hand)
        contents << ContentItem.new(variant, quantity, status)
      end

      def weight
        contents.sum { |item| item.variant.weight * item.quantity }
      end

      def on_hand
        contents.select { |item| item.status == :on_hand }
      end

      def backordered
        contents.select { |item| item.status == :backordered }
      end

      def find_item(variant, status=:on_hand)
        contents.select do |item|
          item.variant == variant &&
          item.status == status
        end.first
      end

      def quantity(status=nil)
        case status
        when :on_hand
          on_hand.sum { |item| item.quantity }
        when :backordered
          backordered.sum { |item| item.quantity }
        else
          contents.sum { |item| item.quantity }
        end
      end

      def empty?
        quantity == 0
      end

      def flattened
        flat = []
        contents.each do |item|
          item.quantity.times do
            flat << ContentItem.new(item.variant, 1, item.status)
          end
        end
        flat
      end

      def flattened=(flattened)
        contents.clear
        flattened.each do |item|
          current_item = find_item(item.variant, item.status)
          if current_item
            current_item.quantity += 1
          else
            add(item.variant, item.quantity, item.status)
          end
        end
      end

      def currency
        #TODO calculate from first variant?
      end

      def shipping_category
        #TODO return proper category?
      end

      def inspect
        out = "#{order} - "
        out << contents.map do |content_item|
          "#{content_item.variant.name} #{content_item.quantity} #{content_item.status}"
        end.join('/')
        out
      end
    end
  end
end
