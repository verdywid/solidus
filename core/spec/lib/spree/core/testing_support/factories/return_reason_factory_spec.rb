ENV['NO_FACTORIES'] = "NO FACTORIES"

require 'spec_helper'
require 'spree/testing_support/factories/return_reason_factory'

RSpec.describe 'return reason factory' do
  let(:factory_class) { Spree::ReturnReason }

  describe 'plain return reason' do
    let(:factory) { :return_reason }

    it_behaves_like 'a working factory'
  end
end
