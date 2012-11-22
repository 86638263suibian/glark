#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::BinaryFileTestCase < Glark::AppTestCase
  def test_match
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ "Binary file " + fname + " matches" ]
    run_app_test expected, [ '--binary=binary', 'i' ], fname
  end

  def test_no_match
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ ]
    run_app_test expected, [ '--binary=binary', 'Q' ], fname
  end

  def test_as_text
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ 
                '    1 ��$�P textf[30m[43mi[0mle.txt ���n�0E��',
                '    3 ��!��8�&qm��.���(�BIM?��n�A@���8w�X�ޫT-c��`[w�3���� +.�/(�ձs���4�������y#	,�����[30m[43mi[0m<ھ�Ť��,\X[��.�Р�K,����r�(�*%�&Ɨb�h�UnІ��޾�j���^h?���N7v��G�5ɫ���m��2�B5�_��r����f��V�؀j�����֥��a���E���f��-S`(a/ӷ����J�,d�oc;��4JR�e��6=ư&�'
                ]
    run_app_test expected, [ '--binary-files=text', 'i' ], fname
  end

  def test_skip
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ ]
    run_app_test expected, [ '--binary=skip', 'i' ], fname
  end

  def test_without_match
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ ]
    run_app_test expected, [ '--binary=without-match', 'i' ], fname
  end

  def xxxtest_decompress_gz
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ ]
    run_app_test expected, [ '--binary=decompress', 'i' ], fname
  end
end
