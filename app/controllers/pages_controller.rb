class PagesController < ApplicationController
  after_action :allow_widget_iframe, only: [:widget, :tablet, :phone]

  def widget
    @auto_test = auto_test
    render layout: false
  end

  def tablet
    @auto_test = auto_test
    render layout: false
  end

  def phone
    @auto_test = auto_test
    render layout: false
  end

  def debug
  end

  def debug_tablet
  end

  def debug_phone
  end

  def index
  end

  private

  def allow_widget_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def auto_test
    t = Time.new
    return 1 if t < Date.parse('27.09.2014')
    return 2 if t < Date.parse('28.09.2014')
    return 3 if t < Date.parse('04.10.2014')
    return 4 if t < Date.parse('05.10.2014')
    return 5 if t < Date.parse('11.10.2014')
    return 6 if t < Date.parse('12.10.2014')
    return 7 if t < Date.parse('18.10.2014')
    return 8 if t < Date.parse('19.10.2014')
    8
  end
end
