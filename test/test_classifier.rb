require 'test_helper'

class ClassifierTest < Test::Unit::TestCase
  def setup
    @pid = spawn('jubaclassifier', '--name=TEST')
    sleep 1

    @classifier = Jubatus::Classifier.new([["localhost", 9199]], "test")
  end

  def teardown
    Process.kill('SIGKILL', @pid)
  end

  def test_save
    assert_equal(0, @classifier.save("hoge"))
  end

  def test_load
    assert_equal(0, @classifier.load("hoge"))
  end

  def test_get_config
    assert_equal(["", [{}, [], {}, [], {}, [], {}, []]], @classifier.get_config)
  end

  def test_set_config
    converter_config = [
      {},
      [], # string filter types, rules
      {},
      [], # num filter types, rules
      {},
      [
        ["*", "str", "bin", "bin"]
      ], # string types, rules
      {},
      [
        ["*", "str"]
      ]  # num types, rule
    ]

    assert_equal(0, @classifier.set_config(["PA", converter_config]))
    assert_equal(1, @classifier.train([["hoge", [
              [["key","value"]], # sv_t
              [["numkey", 1.0]], # nv_t
            ]]]))
    assert_equal([[["hoge", 1.0]]], @classifier.classify([
          [
            [["key","value"]], # sv_t
            [["numkey", 1.0]], # nv_t
          ]]))
  end
end
