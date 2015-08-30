RSpec::Matchers.define :each do |meta|
  match do |actual|
    actual.each_with_index do |i, j|
      @elem = j
      expect(i).to meta
    end
  end

  failure_message do |actual|
    "at[#{@elem}] #{meta.failure_message_for_should}"
  end
end

#
# USAGE
#
#describe "passing" do
#  it "should be a number" do
#    (1..10).should each be_kind_of(Numeric)
#  end
#end
#
#describe "failing" do
#  it "should not be a string" do
#    [1,2,3,4,"cow",6,"7"].should each be_kind_of(Numeric)
#  end
#end
#
#describe "failing again" do
#  subject{[1,2,3,4,"cow",6,"7"]}
#  it{should each be_kind_of(Numeric)}
#end