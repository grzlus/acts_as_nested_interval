RSpec.describe Region, type: :model do

  let(:earth) { Region.create( name: "Earth" ) }

  describe "#callbacks" do
    it :create do
      expect(earth.left).to eq(0.to_r)
      expect(earth.right).to eq(1.to_r)
    end
  end
end
