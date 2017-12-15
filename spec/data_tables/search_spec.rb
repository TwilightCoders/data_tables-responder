require 'spec_helper'

describe DataTables::Modules::Search do

  let!(:complex_params) do
    HashWithIndifferentAccess.new({
      "columns": [
        {
          "data": "id",
          "name": "",
          "searchable": true,
          "orderable": true,
          "search": { "value": "", "regex": false }
        },
        {
          "data": "title",
          "name": "",
          "searchable": true,
          "orderable": true,
          "search": { "value": "", "regex": false }
        },
        {
          "data": "views",
          "name": "",
          "searchable": true,
          "orderable": true,
          "search": { "value": "", "regex": false }
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

  context 'can search' do

    before(:each) do
      User.create(email: 'foo@bar.com')
      User.create(email: 'foo2@bar.com')
      Post.create(title: 'foo', views: 4)
      Post.create(title: 'bar', views: 3)
    end

    it 'integers' do

      complex_params[:columns][2][:search] = {
        "value": "4",
        "regex": false
      }

      dt_module = DataTables::Modules::Search.new(Post, Post.all, complex_params)

      posts = dt_module.search

      # expect{dt_module.search}.to_not raise_error()
      expect(posts.count).to eq(1)
      expect(posts[0].views).to eq(4)

    end

    it 'strings' do

      complex_params[:columns][1][:search] = {
        "value": "foo",
        "regex": false
      }

      dt_module = DataTables::Modules::Search.new(Post, Post.all, complex_params)

      posts = dt_module.search

      # expect{dt_module.search}.to_not raise_error()
      expect(posts.count).to eq(1)
      expect(posts[0].title).to eq('foo')

    end

    it 'uuids' do

      complex_params[:columns][0][:search] = {
        "value": User.find_by(email: 'foo@bar.com').id,
        "regex": false
      }

      dt_module = DataTables::Modules::Search.new(User, User.all, complex_params)

      users = dt_module.search

      # expect{dt_module.search}.to_not raise_error()
      expect(users.count).to eq(1)
      expect(users[0].email).to eq('foo@bar.com')

    end
  end

end
