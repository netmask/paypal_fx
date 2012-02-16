require 'helper'

class TestPaypalFx < Test::Unit::TestCase

  should "have commit method" do
    assert PaypalFx.new({}).respond_to? :commit
  end

  should "have convert method" do
    assert PaypalFx.new({}).respond_to? :convert
  end


end
