class PagesController < ApplicationController
  def about
  end

  def artists_about
  end

  def owners_about
  end

  def menu
      #render layout: false if turbo_frame_request? || request.format.turbo_stream?
  end
end
