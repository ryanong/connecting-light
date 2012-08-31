require "minitest_helper"

describe Log do
  before do
    @log = Log.new
  end

  it "must be valid" do
    @log.valid?.must_equal true
  end
end
