# frozen_string_literal: true

module Sanitizable
  extend ActiveSupport::Concern

  class_methods do
    def sanitize_fields(*fields)
      before_validation do
        fields.each do |field|
          value = send(field)
          next unless value.is_a?(String)

          send("#{field}=", Rails::Html::SafeListSanitizer.new.sanitize(value, tags: [], attributes: []).strip)
        end
      end
    end
  end
end
