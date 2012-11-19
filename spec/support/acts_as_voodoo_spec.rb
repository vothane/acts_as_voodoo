require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo' do

  class Voodoo < ActiveResource::Base
    acts_as_voodoo
  end

  context "when included" do
    
    it "should included ace_of_spades searchable method" do
      Voodoo.should respond_to( :acts_as_voodoo )
    end

  end
end