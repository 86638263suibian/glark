#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pathname'
require 'tempfile'
require 'glark/app/tc'
require 'glark/app/options'

module Glark
  class RcfileTestCase < AppTestCase
    def run_option_test args, exp, &blk
      gopt = Glark::AppOptions.new
      gopt.run args

      exp.each do |name, expval|
        val = gopt.method(name).call
        assert_equal expval, val
      end
      
      blk.call(gopt) if blk
    end

    def read_rcfile opts, basename
      opts.read_rcfile Pathname.new(RES_DIR) + basename
    end

    def test_simple
      run_option_test(%w{ foo }, []) do |opts|
        # default values
        assert_equal "multi", opts.colors.text_color_style
        assert_equal false, opts.local_config_files

        read_rcfile opts, 'rcfile.txt'

        assert_equal "single", opts.colors.text_color_style
        assert_equal true, opts.local_config_files
        ###$$$ assert_equal %w{ bold red }, opts.colors.line_number_highlight.colors
        assert opts.match_spec.ignorecase

        assert_file_filter_eq 1000, opts, :size, :negative, SizeLimitFilter, :max_size
        ###$$$ assert_equal %w{ underline magenta }, opts.match_spec.text_highlights[3].colors
      end
    end

    def test_grep
      run_option_test(%w{ foo }, []) do |opts|
        # default values
        assert_equal "glark", opts.output_options.style
        read_rcfile opts, 'rcgrep.txt'
        assert_equal "grep", opts.output_options.style
      end
    end

    def assert_has_filter_pattern exppat, filters, cls
      clsfilters = filters.select { |pf| pf.kind_of? cls }
      expre = Regexp.new exppat
      assert clsfilters.detect { |filter| filter.pattern == expre }, "exppat: #{exppat}; cls: #{cls}"
    end

    def assert_filters opts, filttype, posneg, cls, *patterns
      filtmeth = filttype.to_s + '_filters'
      spec = opts.input_options.send filtmeth.to_sym
      filters = spec.send posneg
      patterns.each do |pat|
        assert_has_filter_pattern pat, filters, cls
      end
    end

    def assert_file_filters opts, posneg, cls, *patterns
      assert_filters opts, :file, posneg, cls, *patterns
    end

    def assert_directory_filters opts, posneg, cls, *patterns
      assert_filters opts, :directory, posneg, cls, *patterns
    end

    def test_name
      run_option_test(%w{ foo }, []) do |opts|
        read_rcfile opts, 'rcmatch.txt'

        [ '\w+.java', '\w+.rb' ].each do |pat|
          assert_file_filter_pattern_eq pat, opts, :name, :positive, BaseNameFilter
        end

        assert_file_filter_pattern_eq 'zxcdjlk', opts, :name, :negative, BaseNameFilter
      end
    end

    def test_path
      run_option_test(%w{ foo }, []) do |opts|
        read_rcfile opts, 'rcpath.txt'

        assert_directory_filter_pattern_eq 'src/main/java', opts, :dirpath, :positive, FullNameFilter

        [ 'src/main/java', 'src/test/ruby' ].each do |pat|
          assert_directory_filter_pattern_eq pat, opts, :dirpath, :positive, FullNameFilter
        end

        assert_directory_filter_pattern_eq 'org/incava/util', opts, :dirpath, :negative, FullNameFilter
      end
    end

    def test_ext
      run_option_test(%w{ foo }, []) do |opts|
        read_rcfile opts, 'rcext.txt'

        assert_file_filter_pattern_eq 'rb', opts, :ext, :positive, ExtFilter 
        assert_file_filter_pattern_eq 'pl', opts, :ext, :positive, ExtFilter
        assert_file_filter_pattern_eq 'txt', opts, :ext, :negative, ExtFilter
      end
    end
  end
end
