require 'test_helper'

require 'metriks/registry'

class RegistryTest < Minitest::Test
  def setup
    @registry = Metriks::Registry.new
  end

  def teardown
    @registry.stop
  end

  def test_counter
    assert @registry.counter('testing') != nil
  end

  def test_meter
    assert @registry.meter('testing') != nil
  end

  def test_timer
    assert @registry.timer('testing') != nil
  end

  def test_utilization_timer
    assert @registry.utilization_timer('testing') != nil
  end

  def test_histogram
    assert @registry.histogram('testing') != nil
  end

  def test_mismatched_metrics
    @registry.histogram('histogram')
    assert_raises(RuntimeError) { @registry.timer('histogram') }

    @registry.timer('timer')
    assert_raises(RuntimeError) { @registry.histogram('timer') }
  end

  def test_calling_counter_twice
    assert @registry.counter('testing') != nil
  end

  def test_default
    assert Metriks::Registry.default != nil
  end
end
