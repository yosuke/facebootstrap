class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :parse_signed_request

  private
  def parse_signed_request
    if request.post? && params[:signed_request]
      @signed_request = Facebook.parse_signed_request params[:signed_request]
      user_id = @signed_request[:user_id]
      oauth_token = @signed_request[:oauth_token]
      if user_id
        if oauth_token
          user = User.where(facebook_user_id: user_id).first
          if user
            user.update_oauth_token(oauth_token)
          else
            user = User.create_from_oauth_token(oauth_token)
          end
          @current_user = user
          save_user_to_warden_session(user)
        else
          delete_user_from_warden_session
        end
        save_user_id_to_session(user_id)
      end
    end
  end
  protected
  def verify_post_method
    raise "Method not allowed" unless request.post?
  end
  def facebook_user_id
    session['facebook.user_id']
  end
  def signed_request
    @signed_request
  end
  private
  def save_user_to_warden_session(user)
    session['warden.user.user.key'] = [user.class.to_s, [user.id], nil]
  end
  def delete_user_from_warden_session
    session.delete('warden.user.user.key')
  end
  def save_user_id_to_session(user_id)
    session['facebook.user_id'] = user_id
  end
end
