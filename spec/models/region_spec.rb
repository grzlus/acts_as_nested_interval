RSpec.describe Region, type: :model do

  let(:earth) { Region.create( name: "Earth" ) }
  let(:oceania) { Region.create( name: "Oceania", parent: earth ) }
  let(:australia) { Region.create( name: "Australia", parent: oceania ) }
  let(:new_zeland) { Region.create( name: "New Zeland", parent: oceania ) }
  let(:pacific) { Region.create(name: "Pacific", parent: earth) }

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
      expect(earth.ancestors).to eq([])
      expect(oceania.ancestors).to eq([ earth ])
      expect(australia.ancestors).to eq([ earth, oceania ])
      expect(new_zeland.ancestors).to eq([ earth, oceania ])
    end

    it "test descenddants" do
      expect(australia.descendants).to eq([])
      expect(new_zeland.descendants).to eq([])
      expect(oceania.descendants).to eq([ australia, new_zeland ])
      expect(earth.descendants).to eq([oceania, australia, new_zeland])
    end

    it "test preorder" do
      expect([earth, oceania, australia, new_zeland]).to eq(Region.preorder)
    end

    it "test depth" do
      expect(earth.depth).to eq(0)
      expect(oceania.depth).to eq(1)
      expect(australia.depth).to eq(2)
      expect(new_zeland.depth).to eq(2)
    end

    it "test moving" do
      expect do
        oceania.parent = oceania
        oceania.save!
      end.to raise_error

      expect do
        oceania.parent = australia
        oceania.save!
      end.to raise_error

      australia; new_zeland

      moved = oceania
      moved.parent = pacific
      moved.save!
      moved.reload

      expect(moved.ancestors).to eq([earth, pacific])
      expect(moved.descendants).to eq([australia, new_zeland])
      expect(pacific.descendants).to eq([oceania, australia, new_zeland])

    end 

  end
end
