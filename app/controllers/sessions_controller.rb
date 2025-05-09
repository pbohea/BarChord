class SessionsController < ApplicationController
  def new
  end

  def create
    email = params[:email].downcase.strip
    password = params[:password]

    resource, scope =
      if user = User.find_by(email: email)
        [user, :user]
      elsif artist = Artist.find_by(email: email)
        [artist, :artist]
      elsif owner = Owner.find_by(email: email)
        [owner, :owner]
      else
        [nil, nil]
      end

    if resource&.valid_password?(password)
      sign_in(scope, resource)
      redirect_to root_path, notice: "Signed in successfully as #{scope.to_s.titleize}."
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unauthorized
    end
  end
end
