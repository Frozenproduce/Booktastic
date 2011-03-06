class Bookmark < ActiveRecord::Base
  acts_as_taggable_on :tag   
  belongs_to :domain
  
  include Booktastic::ConditionalSet
  
  validate :validate_url
  validates_presence_of :url
  validates_format_of :url, :with => URI::regexp(%w(http https)), :message => "Make sure that you enter a valid URL"
  
  # Strip www from domains, but leave intact any other subdomains
  def to_domain
    domain = URI.parse(url)
    domain.host.gsub(/\Awww\./, '')
  end
  
  def to_s
    url
  end

  def short_url
    set_if_value_does_not_exist(:compressed_url) do
      HTTParty.get("http://tinyurl.com/api-create.php?url=#{url}").parsed_response
    end
  end
  
  private
  
    # Custom validation method to ensure the domain + bookmark actually exists
    def validate_url
      begin
        http_object = HTTParty.get(url)
      rescue SocketError
        errors.add(:url, "This url doesn't exist")
      else
        errors.add(:url, "This url doesn't exist") if http_object.response.is_a? Net::HTTPNotFound
      end
    end
    
  
end
