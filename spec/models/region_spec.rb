RSpec.describe Region, type: :model do

  let(:earth) { Region.create( name: "Earth" ) }
  let(:oceania) { Region.create( name: "Oceania", parent: earth ) }
  let(:australia) { Region.create( name: "Australia", parent: oceania ) }
  let(:new_zeland) { Region.create( name: "New Zeland", parent: oceania ) }

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

    it "can check depth on new record" do
      region = Region.new
      expect { region.depth }.not_to raise_error
      expect(region.depth).to eq(0)
    end

    it "finds roots" do
      expect(Region.roots).to eq([earth])
    end

    it "test first child coordinates" do
      expect(oceania.left).to eq(1.to_r / 2)
      expect(oceania.right).to eq(1.to_r)
    end

    it "test second child coordinates" do
      expect(australia.left).to eq(2.to_r / 3)
      expect(australia.right).to eq(1.to_r)

      expect(new_zeland.right).to eq(2.to_r / 3)
      expect(new_zeland.left).to eq(3.to_r / 5)
    end

    it "test ancestors" do
      expect(earth.ancestors.to_a).to eq([])
      expect(oceania.ancestors.to_a).to eq([ earth ])
      expect(australia.ancestors.to_a).to eq([ earth, oceania ])
      expect(new_zeland.ancestors.to_a).to eq([ earth, oceania ])
    end
  end
end
