require 'test_helper'

class MetriksTest < Minitest::Test
  def setup
    Metriks::Registry.default.clear
  end

  def teardown
    Metriks::Registry.default.clear
  end

  def test_counter
    assert Metriks.counter('testing') != nil
  end

  def test_meter
    assert Metriks.meter('testing') != nil
  end

  def test_timer
    assert Metriks.timer('testing') != nil
  end

  def test_utilization_timer
    assert Metriks.utilization_timer('testing') != nil
  end

  def test_histogram
    assert Metriks.histogram('testing') != nil
  end
end
