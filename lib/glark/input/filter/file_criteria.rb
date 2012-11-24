#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/criteria'
require 'glark/input/filter/filter'
require 'glark/util/optutil'

module Glark; end

class Glark::Option
  include Loggable
  
  def initialize criteria
    @criteria = criteria
  end
end

class Glark::SizeLimitOption < Glark::Option
  def to_hash
    {
      :tags => %w{ --size-limit },
      :arg  => [ :integer ],
      :set  => Proc.new { |val| set val }
    }
  end

  def set val
    @criteria.add :size, :negative, SizeLimitFilter.new(val.to_i)
  end
end

class Glark::ExtOption < Glark::Option
  def postags
    %w{ --match-ext }
  end

  def negtags
    %w{ --not-ext }
  end
  
  def posrc
    'match-ext'
  end

  def negrc
    'not-ext'
  end

  def cls
    ExtFilter
  end

  def field
    :ext
  end

  def add_to_option_data optdata
    [ [ postags, :positive ], 
      [ negtags, :negative ] ].each do |tags, posneg|
      next unless tags
      optdata << {
        :tags => tags,
        :arg  => [ :string ],
        :set  => Proc.new { |pat| set posneg, pat }
      }
    end
  end

  def set posneg, val
    info "posneg: #{posneg}"
    info "val: #{val}"
    @criteria.add field, posneg, cls.new(Regexp.create val)
  end
end

class Glark::PathnameOption
end

class Glark::FileCriteria < Glark::Criteria
  include Glark::OptionUtil
  
  def initialize 
    super

    @szlimit_opt = Glark::SizeLimitOption.new self

    @basename_opt = { :field => :name, :cls => BaseNameFilter }
    @basename_opt[:postags] = %w{ --basename --name --with-basename --with-name --match-name }
    @basename_opt[:negtags] = %w{ --without-basename --without-name --not-name }
    @basename_opt[:posrc] = 'match-name'
    @basename_opt[:negrc] = 'not-name'
    
    @pathname_opt = { :field => :path, :cls => FullNameFilter }
    @pathname_opt[:postags] = %w{ --fullname --path --with-fullname --with-path --match-path }
    @pathname_opt[:negtags] = %w{ --without-fullname --without-path --not-path }
    @pathname_opt[:posrc] = 'match-path'
    @pathname_opt[:negrc] = 'not-path'

    @ext_opt = Glark::ExtOption.new self
  end

  def add_as_options optdata
    add_option optdata, @szlimit_opt

    add_opt_filter_pat optdata, @basename_opt
    add_opt_filter_pat optdata, @pathname_opt
    # add_opt_filter_pat optdata, @ext_opt

    @ext_opt.add_to_option_data optdata
  end

  def config_fields
    maxsize = (filter = find_by_class(:size, :negative, SizeLimitFilter)) && filter.max_size
    fields = {
      "size-limit" => maxsize
    }
  end

  def update_fields rcfields
    process_rcfields rcfields, [ @basename_opt, @pathname_opt ]

    rcfields.each do |name, values|
      info "name: #{name}".cyan
      if name == 'size-limit'
        @szlimit_opt.set values.last
      elsif name == 'match-ext'
        info "name: #{name}".blue
        values.each do |val|
          @ext_opt.set :positive, val
        end
      elsif name == 'not-ext'
        info "name: #{name}".red
        values.each do |val|
          @ext_opt.set :negative, val
        end
      end
    end
  end
end
