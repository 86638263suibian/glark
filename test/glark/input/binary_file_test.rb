#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class BinaryFileTestCase < AppTestCase
    def test_match
      fname = to_path "textfile.txt.gz"
      expected = [ "Binary file " + fname + " matches" ]
      run_app_test expected, [ '--binary=binary', 'i' ], fname
    end

    def test_no_match
      fname = to_path "textfile.txt.gz"
      expected = [ ]
      run_app_test expected, [ '--binary=binary', 'Q' ], fname
    end

    def test_skip
      fname = to_path "textfile.txt.gz"
      expected = [ ]
      run_app_test expected, [ '--binary=skip', 'i' ], fname
    end

    def test_without_match
      fname = to_path "textfile.txt.gz"
      expected = [ ]
      run_app_test expected, [ '--binary=without-match', 'i' ], fname
    end

    def run_decompress_gz_single_test binopt
      fname = to_path "textfile.txt.gz"
      expected = [ 
                  "    5   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-[30m[43mTheCooksTale.txt[0m",
                  "   10   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-[30m[43mTheClerksTale.txt[0m",
                  "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-[30m[43mTheCanonsYeomansTale.txt[0m",
                 ]
      run_app_test expected, [ '--binary=' + binopt, 'The.*C.*' ], fname
    end

    def run_decompress_gz_multiple_test binopt
      fnames = [ to_path("textfile.txt.gz"),  to_path("zfile.txt.gz") ]
      expected = [ 
                  "[1m" + RES_DIR + "/textfile.txt.gz[0m",
                  "   18   -rw-r--r--   1 jpace jpace   14834 2010-12-04 15:24 17-Ch[30m[43maucersTaleOfSi[0mrThopas.txt",
                  "   19   -rw-r--r--   1 jpace jpace   43249 2010-12-04 15:24 18-Ch[30m[43maucersTaleOfMeli[0mboeus.txt",
                  "[1m" + RES_DIR + "/zfile.txt.gz[0m",
                  "   16 zyg[30m[43maeni[0md",
                 ]
      run_app_test expected, [ '--binary=' + binopt, 'a\w*e\w*i' ], *fnames
    end

    def test_decompress_gz_single
      run_decompress_gz_single_test 'decompress'
    end

    def test_decompress_gz_multiple
      run_decompress_gz_multiple_test 'decompress'
    end

    def test_read_gz_single
      run_decompress_gz_single_test 'read'
    end

    def test_read_gz_multiple
      run_decompress_gz_multiple_test 'read'
    end

    def test_list_tar_single
      fname = to_path "rc.tar"
      expected = [ 
                  "    4 rcm[30m[43ma[0mtch.txt",
                  "    5 rcp[30m[43ma[0mth.txt",
                 ]
      run_app_test expected, [ '--binary=list', 'a' ], fname
    end

    def test_contents_tar_single
      fname = to_path "rc.tar"
      expected = [ 
                  "[1mrcfile.txt (in " + RES_DIR + "/rc.tar)[0m",
                  "    2 h[30m[43mighlight: si[0mngle",
                  "    3 # h[30m[43mighlight: multi[0m",
                  "    4 local-conf[30m[43mig-fi[0mles: true",
                  "    8 s[30m[43mize-limi[0mt: 1000",
                  "[1mrcpath.txt (in " + RES_DIR + "/rc.tar)[0m",
                  "    1 match-d[30m[43mirpath: src/mai[0mn/java",
                  "    4 not-d[30m[43mirpath: org/incava/uti[0ml",
                 ]
      run_app_test expected, [ '--binary=read', 'i.*i' ], fname
    end

    def test_list_tar_gz_single
      fname = to_path "rubies.tar.gz"
      expected = [ 
                  "    2 [30m[43me[0mcho.rb",
                  "    3 gr[30m[43me[0m[30m[43me[0mt.rb",
                 ]
      run_app_test expected, [ '--binary=list', 'e' ], fname
    end

    def test_list_tar_gz_multiple
      fnames = [ RES_DIR + "/rubies.tar.gz", "doesnotexist" ]
      expected = [ 
                  "[1m" + RES_DIR + "/rubies.tar.gz[0m",
                  "    2 [30m[43me[0mcho.rb",
                  "    3 gr[30m[43me[0m[30m[43me[0mt.rb",
                 ]
      run_app_test expected, [ '--binary=list', 'e' ], *fnames
    end

    def test_list_jar_single
      fname = to_path "org-incava-ijdk-1.0.1.jar"
      # zlib returns a different order, between 1.8.7 and 1.9.1:
      if RUBY_VERSION.index %r{^1\.8}
        expected = [ 
                    '   17 o[30m[43mrg/incava/ijdk/lang/BooleanArr[0may.class',
                    '   31 o[30m[43mrg/incava/ijdk/lang/ByteArr[0may.class',
                    '   38 o[30m[43mrg/incava/ijdk/lang/Integer[0mExt.class',
                    '   47 o[30m[43mrg/incava/ijdk/lang/IntegerArr[0may.class',
                    '   65 o[30m[43mrg/incava/ijdk/lang/DoubleArr[0may.class',
                    '   74 o[30m[43mrg/incava/ijdk/lang/OrderedPair[0m.class',
                    '   83 o[30m[43mrg/incava/ijdk/lang/Range$RangeIterator[0m.class',
                   ]
      else
        expected = [ 
                    '   49 o[30m[43mrg/incava/ijdk/lang/DoubleArr[0may.class',
                    '   51 o[30m[43mrg/incava/ijdk/lang/BooleanArr[0may.class',
                    '   55 o[30m[43mrg/incava/ijdk/lang/Integer[0mExt.class',
                    '   58 o[30m[43mrg/incava/ijdk/lang/IntegerArr[0may.class',
                    '   59 o[30m[43mrg/incava/ijdk/lang/Range$RangeIterator[0m.class',
                    '   61 o[30m[43mrg/incava/ijdk/lang/OrderedPair[0m.class',
                    '   62 o[30m[43mrg/incava/ijdk/lang/ByteArr[0may.class',
                   ]
      end
      
      run_app_test expected, [ '--binary=list', 'r.*a.*n.*g.*e.*r' ], fname
    end

    def test_list_zip_single
      fname = to_path "aaa.zip"
      expected = [ 
                  "    2 [30m[43madd[0m.rb",
                 ]
      run_app_test expected, [ '--binary=list', 'a.*d' ], fname
    end

    def test_read_zip_single
      fname = to_path "aaa.zip"
      expected = [ 
                  "[1mabcfile.txt (in " + RES_DIR + "/aaa.zip)[0m",
                  "    1 A[30m[43mB[0mC",
                  "    2 [30m[43mD[0mEF",
                  "    3 [30m[43mG[0mHI",
                  "    4 [30m[43mJ[0mKL",
                  "[1madd.rb (in " + RES_DIR + "/aaa.zip)[0m",
                  "   10 Adder.new AR[30m[43mG[0mV.shift || 2, AR[30m[43mG[0mV.shift || 2",
                 ]
      run_app_test expected, [ '--binary=read', '[BDJG]' ], fname
    end

    def test_read_tar_gz_single
      fname = to_path "rubies.tar.gz"
      expected = [ 
                  "[1madd.rb (in " + RES_DIR + "/rubies.tar.gz)[0m",
                  "    5   def [30m[43minitialize[0m x, y",
                  "[1mgreet.rb (in " + RES_DIR + "/rubies.tar.gz)[0m",
                  "    4 requ[30m[43mire 'rubyge[0mms'",
                  "    5 requ[30m[43mire 'rie[0ml'",
                  "    8   def [30m[43minitialize name[0m",
                 ]
      run_app_test expected, [ '--binary=read', 'i.*e' ], fname
    end

    def test_read_tgz_single
      fname = to_path "txt.tgz"
      expected = [ 
                  "[1mfilelist.txt (in " + RES_DIR + "/txt.tgz)[0m",
                  "    8 07-The_[30m[43mFriars_Tale[0m.txt",
                  "   13 12-The_[30m[43mFranklins_Tale[0m.txt",
                 ]
      run_app_test expected, [ '--binary=read', 'F.*e' ], fname
    end

    def test_list_tgz_single
      fname = to_path "txt.tgz"
      expected = [ 
                  "    1 fi[30m[43mlelist.txt[0m",
                 ]
      run_app_test expected, [ '--binary=list', 'l.*t' ], fname
    end
  end
end
