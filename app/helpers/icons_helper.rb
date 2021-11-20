# frozen_string_literal: true

module IconsHelper
  DEFAULT_ICON_SIZE = 14
  DEFAULT_ICON_PATH = 'public/svgs'

  def labeled_icon(label, icon_name = nil, size: DEFAULT_ICON_SIZE, css_class: nil, icon_only: false, path: DEFAULT_ICON_PATH)
    css_classes = []
    css_classes << "s#{size}" if size
    css_classes << "#{css_class}" unless css_class.blank?

    svg = svg_file(icon_name, css_classes, path)

    if icon_only
      svg
    else
      svg + label
    end
  end

  private

  def svg_file(icon, css_class, path)
    file_path = "#{Rails.root}/#{path}/#{icon}.svg"

    if File.exists?(file_path)
      doc = content_tag(:svg,:class => css_class, :xmlns => "http://www.w3.org/2000/svg") do
        content_tag(:use, '', :href => "/svgs/#{icon}.svg#icon")
      end
    else
      doc = "<!-- SVG #{icon} not found -->"
    end

    raw doc
  end
end
