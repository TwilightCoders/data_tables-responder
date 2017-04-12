require 'spec_helper'

require 'pry'

describe DataTables::Modules::Order do

  before(:each) do
    # Make everything public :P
    DataTables::Modules::Order.send(:public, *DataTables::Modules::Order.protected_instance_methods)
  end

  let!(:complex_params) do
    HashWithIndifferentAccess.new({
      "columns": [
        {
          "data": "id",
          "name": "",
          "orderable": true,
          "search": { "regex": false, "value": "" },
          "searchable": true
        },
        {
          "data": "post.user.email",
          "name": "",
          "orderable": true,
          "search": { "regex": false, "value": "foo@bar.baz" },
          "searchable": true
        },
        {
          "data": nil,
          "name": "",
          "orderable": false,
          "search": { "regex": false, "value": "" },
          "searchable": true
        }
      ],
      "draw": 3,
      "length": 10,
      "order": [
        { "column": 1, "dir": "asc" }
      ],
      "sRangeSeparator": "~",
      "search": { "regex": false, "value": "" },
      "start": 0
    })
  end

  xit 'handles multi nested requests' do

  end

  it 'transmutes datatable order' do

    order = DataTables::Modules::Order.new(Post, Post.all, complex_params)

    transmuted = order.orderable_columns(complex_params[:order], complex_params[:columns])

    expect(transmuted).to eq({"post.user.email"=>"asc"})
  end

end

