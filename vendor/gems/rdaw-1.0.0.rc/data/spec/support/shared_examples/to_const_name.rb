shared_examples_for '.to_const_name' do
  it 'is a module_function' do
    described_class.should respond_to :to_const_name
  end

  it 'requires a code as a parameter' do
    described_class.method(:to_const_name).parameters.should eq [[:req, :code]]
  end

  it 'returns nil when no code is passed' do
    described_class.to_const_name(nil).should eq nil
  end

  it 'returns nil when the code is not found' do
    described_class.to_const_name(1337).should eq nil
  end

  it 'returns the constant\'s string representation for found values' do
    result = described_class.to_const_name(codes.first.last)
    result.should eq codes.first.first.to_s
    result.should be_an_instance_of String
  end

  it 'looks up the appropriate value through a self.constants search' do
    constants = [:DUMMY]
    described_class.should_receive(:constants).and_return constants
    constants.should_receive(:select).and_return constants
    constants.should_receive(:first).and_return :DUMMY
    described_class.to_const_name(9999).should eq 'DUMMY'
  end
end