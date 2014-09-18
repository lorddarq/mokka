class PagesController < ApplicationController
  after_action :allow_widget_iframe, only: :widget

  def widget
    render layout: false
  end

  def debug
  end

  def index
  end

  private

  def allow_widget_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
