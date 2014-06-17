RSpec.describe Region, type: :model do

  let(:earth) { Region.create( name: "Earth" ) }

  describe "#callbacks" do
    it "create_with_coordinates" do
      expect(earth.left).to eq(0.to_r)
      expect(earth.right).to eq(1.to_r)
    end

    it "allows only one root" do
      expect do
        expect( earth ).to be_present
        Region.create( name: "Another root" )
      end.to raise_error
    end
  end
end
