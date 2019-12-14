require "spec_helper"

describe SavonZuora::Hooks::Hook do

  let(:hook) { lambda {} }

  describe "#call" do
    it "calls the hook" do
      hook = SavonZuora::Hooks::Hook.new(:my_hook, :soap_request, &hook)
      hook.expects(:call).with(:arg1, :arg2)

      hook.call(:arg1, :arg2)
    end
  end

end
