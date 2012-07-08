class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :openid_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :identity_url
  
  
  def self.build_from_identity_url(identity_url)
    logger.info "building user identity from #{identity_url}"
     User.new(:identity_url => identity_url)
  end
  
  def self.openid_required_fields
    ["email", "http://axschema.org/contact/email"]
  end
  
  
  def openid_fields=(fields)
    fields.each do |key, value|
      # Some AX providers can return multiple values per key
      if value.is_a? Array
        value = value.first
      end

      case key.to_s
      when "fullname", "http://axschema.org/namePerson"
        self.name = value
      when "email", "http://axschema.org/contact/email"
        logger.info "assigned user email to #{value}"
        self.email = value
      when "gender", "http://axschema.org/person/gender"
        self.gender = value
      else
        logger.error "Unknown OpenID field: #{key}"
      end
    end
    logger.info "saving user now..."
    logger.info "user valid? #{self.valid?}"
    self.errors.each {|k, v| logger.info "#{k.capitalize}: #{v}"} unless self.valid?
    self.save!
  end
  
  protected 
   def password_required? 
     !identity_url.present? 
   end
end
