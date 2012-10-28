#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Extended regular-expression-based expressions.

require 'rubygems'
require 'riel'
require 'glark/app/options'

# An expression, which can be applied (processed) against a Glark::File.
class Expression
  include Loggable
  
  attr_accessor :matches, :invert_match

  def initialize
    @match_line_number = nil
    @matches           = Array.new
    
    opts               = Glark::Options.instance
    @invert_match      = opts.invert_match
    @display_matches   = !opts.file_names_only && opts.filter && !opts.count
    @range             = opts.range
    @file_names_only   = opts.file_names_only
    @match_limit       = opts.match_limit
    @write_null        = opts.write_null
    @filter            = opts.filter
  end

  def add_match lnum
    @matches.push lnum
  end

  def start_position
    @match_line_number
  end

  def end_position
    start_position
  end

  def reset_file file
    @match_line_number = nil
    @matches = Array.new
  end

  def process file
    got_match = false
    reset_file file.fname
    
    rgstart  = @range && @range.to_line(@range.from, file.linecount)
    info "rgstart: #{rgstart}".yellow
    rgend    = @range && @range.to_line(@range.to,   file.linecount)
    info "rgend: #{rgend}".yellow
    
    lastmatch = 0
    nmatches = 0
    lnum = 0
    file.each_line do |line|
      info "line: #{line.chomp}".cyan
      info "lnum: #{lnum}".cyan
      if ((!rgstart || lnum >= rgstart) && 
          (!rgend   || lnum < rgend)   &&
          evaluate(line, lnum, file))
        
        mark_as_match file
        got_match = true
        nmatches += 1
        
        if @display_matches
          file.write_matches !@invert_match, lastmatch, lnum
          lastmatch = lnum + 1
        elsif @file_names_only
          # we don't need to match more than once
          break
        end
        
        if @match_limit && nmatches >= @match_limit
          # we've found the match limit
          break
        end
      end
      lnum += 1
    end
    
    if @file_names_only
      if got_match != @invert_match
        if @write_null
          print file.fname + "\0"
        else
          puts file.fname
        end
      end
    elsif @filter
      if @invert_match
        file.write_matches false, 0, lnum
      elsif got_match
        file.write_matches true, 0, lnum
      end
    else
      file.write_all
    end
  end

  def mark_as_match file
    file.mark_as_match start_position
  end

  def to_s
    inspect
  end
end
