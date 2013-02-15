#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt
  class Macro

    # Class Methods

    def self.to_html(text)
      data = JSON.load(text)
      type = camel_case(data['type']) + 'Macro'
      Dirt.const_get(type).new(data).to_html
    end

    def self.camel_case(str)
      str.capitalize.gsub(/_(.)/) { |m| $1.upcase }
    end

    # Instance Methods

    def initialize(spec)
      @spec = spec
      @spec = expand_sql(@spec)
    end

    def haml(template_id, scope=self)
      template_file = File.expand_path("../../views/macros/" + template_id.to_s + '.haml', __FILE__)
      template = File.read template_file
      Haml::Engine.new(template, :format => :html5).render(scope)
    end

    def expand_sql(spec)
      if spec.has_key? 'sql' then
        spec['sql'].gsub!(/%([A-Z0-9_]+)\((.*?)\)/) do |match_string|
          function_name = $1.downcase
          params = $2
          self.method(function_name.to_sym).call(params)
        end
      end
      return spec
    end

    def date(date_string)
      Chronic.parse(date_string).strftime(%q{'%Y-%m-%d'})
    end

    def avg_days_since(field_name)
      "CAST(ROUND(AVG(DATEDIFF(CURRENT_DATE(),DATE(#{field_name}))),0) AS SIGNED) AS AVG_DAYS_SINCE_#{field_name.upcase}"
    end
  end

  class DumpMacro < Macro
    def to_html
      "<notextile> DUMP: " + JSON.dump(@spec) + " </notextile>"
    end
  end
end
