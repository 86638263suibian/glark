#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter_spec'
require 'glark/util/optutil'

module Glark; end

class Glark::FileFilterSpec < Glark::FilterSpec
  include Glark::OptionUtil

  def add_as_options optdata
    add_opt_filter_int optdata, %w{ --size-limit }, :negative, SizeLimitFilter

    # match/skip files by basename
    add_opt_filter_re optdata, %w{ --basename --name --with-basename --with-name --match-name }, :positive, BaseNameFilter
    add_opt_filter_re optdata, %w{ --without-basename --without-name --not-name }, :negative, BaseNameFilter

    # match/skip files by pathname
    add_opt_filter_re optdata, %w{ --fullname --path --with-fullname --with-path --match-path }, :positive, FullNameFilter
    add_opt_filter_re optdata, %w{ --without-fullname --without-path --not-path }, :negative, FullNameFilter
  end

  def config_fields
    fields = {
      "size-limit" => (filter = @negative_filters.find_by_class(SizeLimitFilter) && filter.max_size),
    }
  end

  def update_fields fields
    fields.each do |name, values|
      case name
      when "size-limit"
        add_filter :negative, SizeLimitFilter, values.last.to_i
      when "match-name"
        values.each do |val|
          add_filter :positive, BaseNameFilter, Regexp.create(val)
        end
      when "not-name"
        values.each do |val|
          add_filter :negative, BaseNameFilter, Regexp.create(val)
        end
      end
    end
  end
end