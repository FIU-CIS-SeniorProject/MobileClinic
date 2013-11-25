require 'spec_helper'

describe Medication do

  before {@med =   Medication.new(:medId => 12345678, :name => "Ibuprofen", :numContainers => 10, 
                :tabletsPerContainer => 20, :expiration => 1372171611, :doseOfTablets => 20, :status => 1)}

  subject { @med }
  #####################################
  # test for the existence attributes #
  #####################################

  it {should respond_to(:medId) }
  it {should respond_to(:name) }
  it {should respond_to(:numContainers) }
  it {should respond_to(:tabletsPerContainer) }
  it {should respond_to(:expiration) }
  it {should respond_to(:doseOfTablets)}
  it {should respond_to(:status)}

  ####################
  # VALIDATION TESTS #
  ####################


# Validation test for numContainers
describe "when numContainers is not present" do
  before { @med.numContainers = nil}
  it { should_not be_valid }
end

describe "when numContainers is not a number" do
  before { @med.numContainers = "not a num"}
  it { should_not be_valid }
end

# Validation test for tabletsPerContainer
describe "when tabletsPerContainer is not present" do
  before { @med.tabletsPerContainer = nil}
  it { should_not be_valid }
end

describe "when tabletsPerContainer is not a number" do
  before { @med.numContainers = "not a num"}
  it { should_not be_valid }
end

# Validation test for expiration
describe "when expiration is not present" do
  before { @med.expiration = nil  }
  it { should_not be_valid }
end

describe "when expiration is not a number" do
  before { @med.numContainers = "not a num"}
  it {should_not be_valid}
end

# Validation test for doseOfTablets
  describe "when doseOfTablets is not present" do
  before { @med.doseOfTablets = nil}
  it { should_not be_valid }
end

describe "when doseOfTablets is not a number" do
  before { @med.numContainers = "not a num"}
  it { should_not be_valid }
end
end