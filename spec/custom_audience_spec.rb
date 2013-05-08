require 'spec_helper'

describe CustomAudience::CustomAudience do
  describe "#initialize" do
    it "creates with a name" do
      described_class.new("name").name.should eq("name")
    end

    it "creates with a hash" do
      described_class.new('name' => "abc").name.should eq("abc")
    end

    it "fetches attributes with an account id" do
      Koala::Facebook::API.stubs(:new).with('token').returns(api = stub)
      api.expects(:get_connections).with("act_account_id", 'customaudiences').
        returns([{"name" => "test", "id" => 5}, {"name" => "foo", "id" => 6}])

      audience = described_class.new("name" => "test", "account_id" => "account_id", 'token' => 'token')

      audience.id.should eq(5)
    end
  end

  describe "#account_id=" do
    it "fetches the attributes" do
      Koala::Facebook::API.stubs(:new).with('token').returns(api = stub)
      api.expects(:get_connections).with("act_account_id", 'customaudiences').
        returns([{"name" => "test", "id" => 5}, {"name" => "foo", "id" => 6}])

      audience = described_class.new("name" => "test", 'token' => 'token')
      audience.account_id = "account_id"

      audience.id.should eq(5)
    end

    it "sets the account id" do
      subject.account_id = 5

      subject.account_id.should eq('5')
    end
  end

  describe "#token=" do
    it "fetches the attributes" do
      Koala::Facebook::API.stubs(:new).with('token').returns(api = stub)
      api.expects(:get_connections).with("act_account_id", 'customaudiences').
        returns([{"name" => "test", "id" => 5}, {"name" => "foo", "id" => 6}])

      audience = described_class.new("name" => "test", 'account_id' => 'account_id')
      audience.token = 'token'

      audience.id.should eq(5)
    end

    it "sets the token" do
      subject.token = 'abc'

      subject.token.should eq('abc')
    end
  end

  describe "#exists?" do
    it "is true when there is an id" do
      subject.stubs(id: 1)

      subject.should be_exists
    end

    it "is false when there is no id" do
      subject.should_not be_exists
    end
  end

  describe "#name" do
    it "returns the name" do
      subject.attributes['name'] = 'name'
      subject.name.should eq('name')
    end
  end

  describe "#id" do
    it "returns the id" do
      subject.attributes['id'] = 'id'
      subject.id.should eq('id')
    end
  end

  describe "#account_id" do
    it "strips act_ from the front" do
      subject.attributes['account_id'] = 'act_123'

      subject.account_id.should eq('123')
    end

    it "handles non-string values" do
      subject.attributes['account_id'] = 123

      subject.account_id.should eq('123')
    end

    it "handles nil" do
      subject.account_id.should eq('')
    end
  end

  describe "#save" do
    let(:api) { stub }

    before do
      Koala::Facebook::API.stubs(new: api)

      subject.attributes.merge!('name' => 'name', 'account_id' => '123')
      subject.users = [10]
    end

    it "creates if it doesn't exist, and adds users" do
      subject.stubs(exists?: false)

      api.expects(:put_connections).with('act_123', 'customaudiences', name: 'name').
        returns({"id" => 1})
      api.expects(:get_object).with(1).returns({"id" => 1})
      api.expects(:put_connections).with(1, 'users', users: [{"id" => 10}].to_json)

      subject.save
    end

    it "adds users if it already exists" do
      subject.stubs(exists?: true, id: 1)

      api.expects(:put_connections).with(1, 'users', users: [{"id" => 10}].to_json)

      subject.save
    end

    it "adds users in batches of 1000 if there are more" do
      batch1 = 1.upto(1000).to_a
      batch2 = 1001.upto(2000).to_a

      subject.users = (batch1 + batch2)
      subject.stubs(exists?: true, id: 1)

      api.expects(:put_connections).with(1, 'users', users: batch1.map {|i| {"id" => i}}.to_json)
      api.expects(:put_connections).with(1, 'users', users: batch2.map {|i| {"id" => i}}.to_json)

      subject.save
    end
  end
end
