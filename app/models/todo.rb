class Todo
  include Mongoid::Document
  
  # belongs_to :user
  # but we don't yet use mongo for users
  # so just add a user_id field
  field :user_id, type: Integer
  field :title
  field :description
  field :start, type: DateTime
  field :recur, type: Integer # enum
  field :recurrences, type: Integer
  
  validates_presence_of :user_id, :title, :recur
  validate :unique_todo
  
  def unique_todo
    unless Todo.where(user_id: self.user_id, title: self.title).first.nil?
      errors.add(:unique_check, "user_id and title are not unique")
    end
  end
end
