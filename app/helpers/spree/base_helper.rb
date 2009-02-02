module Spree::BaseHelper

  def cart_path
    return new_order_url if session[:order_id].blank?
    return edit_order_url(Order.find_or_create_by_id(session[:order_id]))
  end
  
  def cart_link(text=t('cart'))
    path = cart_path
    order = Order.find_or_create_by_id(session[:order_id]) unless session[:order_id].blank?
    unless order.nil?
      line_items_count = order.line_items.size
      return "" if current_page?(path)
      text = "#{text}: (#{line_items_count}) #{order_price(order)}"
    end
    link_to text, path
  end
  
  def order_price(order, options={})
    options.assert_valid_keys(:format_as_currency, :show_vat_text, :show_price_inc_vat)
    options.reverse_merge! :format_as_currency => true, :show_vat_text => true
    
    # overwrite show_vat_text if show_price_inc_vat is false
    options[:show_vat_text] = Spree::Tax::Config[:show_price_inc_vat]

    amount =  order.item_total    
    amount += Spree::VatCalculator.calculate_tax(order) if Spree::Tax::Config[:show_price_inc_vat]    

    options.delete(:format_as_currency) ? format_price(amount, options) : amount
  end
  
  def windowed_pagination_links(pagingEnum, options)
    link_to_current_page = options[:link_to_current_page]
    always_show_anchors = options[:always_show_anchors]
    padding = options[:window_size]

    current_page = pagingEnum.page
    html = ''

    #Calculate the window start and end pages 
    padding = padding < 0 ? 0 : padding
    first = pagingEnum.page_exists?(current_page  - padding) ? current_page - padding : 1
    last = pagingEnum.page_exists?(current_page + padding) ? current_page + padding : pagingEnum.last_page

    # Print start page if anchors are enabled
    html << yield(1) if always_show_anchors and not first == 1

  # Print window pages
  first.upto(last) do |page|
    (current_page == page && !link_to_current_page) ? html << page : html << yield(page)
  end

  # Print end page if anchors are enabled
  html << yield(pagingEnum.last_page) if always_show_anchors and not last == pagingEnum.last_page
  html
  end 
  
  def add_product_link(text, product) 
    link_to_remote text, {:url => {:controller => "cart", 
              :action => "add", :id => product}}, 
              {:title => "Add to Cart", 
               :href => url_for( :controller => "cart", 
                          :action => "add", :id => product)} 
  end 
  
  def remove_product_link(text, product) 
    link_to_remote text, {:url => {:controller => "cart", 
                       :action => "remove", 
                       :id => product}}, 
                       {:title => "Remove item", 
                         :href => url_for( :controller => "cart", 
                                     :action => "remove", :id => product)} 
  end 
  
  def todays_short_date
    utc_to_local(Time.now.utc).to_ordinalized_s(:stub)
  end
 
  def yesterdays_short_date
    utc_to_local(Time.now.utc.yesterday).to_ordinalized_s(:stub)
  end  
  

  # human readable list of variant options
  def variant_options(v, allow_back_orders = Spree::Config[:allow_backorders])
    list = v.option_values.map { |ov| "#{ov.option_type.presentation}: #{ov.presentation}" }.to_sentence({:connector => ","})
    list = "<span class =\"out-of-stock\">(OUT OF STOCK) #{list}</span>" unless (v.in_stock or allow_back_orders)
    list
  end  
  
  def mini_image(product)
    if product.images.empty?
      image_tag "noimage/mini.jpg"  
    else
      image_tag product.images.first.attachment.url(:mini)  
    end
  end

  def small_image(product)
    if product.images.empty?
      image_tag "noimage/small.jpg"  
    else
      image_tag product.images.first.attachment.url(:small)  
    end
  end

  def product_image(product)
    if product.images.empty?
      image_tag "noimage/product.jpg"  
    else
      image_tag product.images.first.attachment.url(:product)  
    end
  end
end
