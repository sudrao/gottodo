module SessionHelper
  
  def sign_in(user)
    cookies.signed[:remember_token] = [user.id, user.salt]
    self.current_user = user
  end

  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end
  
  def signed_in?
    self.current_user
  end
  
  def current_user
    @current_user ||= user_from_remember_token
  end

  private

    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end
  
end
