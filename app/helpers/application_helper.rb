# encoding: UTF-8
module ApplicationHelper
  def parent_layout(layout)
    @view_flow.set(:layout, output_buffer)
    self.output_buffer = render(:file => "layouts/#{layout}")
  end

  def classes(*args)
    args.inject([]) do |memo, arg|
      case arg
      when Hash
        arg.each {|k, v| memo << k if v}
      else
        memo << arg
      end
      memo
    end.join(" ")
  end
end
