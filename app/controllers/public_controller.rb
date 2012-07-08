class PublicController < ApplicationController
  def index
    
  end
  
  def google
    domain = params[:domain]
    @domain = "https://www.google.com/accounts/o8/site-xrds?hd=#{domain}"
    
  end
end