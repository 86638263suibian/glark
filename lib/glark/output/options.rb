#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

class OutputOptions
  attr_accessor :context
  attr_accessor :file_highlight
  attr_accessor :file_names_only
  attr_accessor :filter
  attr_accessor :highlight
  attr_accessor :invert_match
  attr_accessor :label
  attr_accessor :line_number_highlight
  attr_accessor :match_limit
  attr_accessor :out
  attr_accessor :show_file_names
  attr_accessor :show_line_numbers
  attr_accessor :write_null

  def initialize 
    @context = Glark::Context.new
    @file_highlight = nil
    @file_names_only = nil
    @filter = filter
    @highlight = nil
    @invert_match = nil
    @label = nil
    @line_number_highlight = nil
    @match_limit = nil
    @out = nil
    @show_file_names = nil
    @show_line_numbers = nil
    @write_null = nil
  end

  def after
    @context && @context.after
  end

  def before
    @context && @context.before
  end

  def add_as_options optdata
    @context.add_as_option optdata
  end
end
