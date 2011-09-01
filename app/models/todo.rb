class Todo
  include ActiveModel::Validations
  include ActiveModel::Conversion
   
  attr_accessor :description, :start_time
  validates_presence_of :description, :start_time
  
  def initialize(attr = {})
    attr.each do |attr_name, value|
      # construct method name from variable content
      send("#{attr_name}", value)
    end
  end
 
  # This method allows use of url helpers without a standard db
  def persisted?
    false
  end
end
