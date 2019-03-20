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
        },
        {
          "data": "engagement_rate",
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
      Post.create(title: 'foo', views: 4, engagement_rate: 0.5)
      Post.create(title: 'bar', views: 3, engagement_rate: 1.0)
      Post.create(title: 'baz', views: 2, engagement_rate: 2.0)
    end

    it 'integers' do

      complex_params[:columns][2][:search] = {
        "value": "4",
        "regex": false
      }

      dt_module = DataTables::Modules::Search.new(Post, Post.all, complex_params)

      posts = dt_module.search

      expect(posts.count).to eq(1)
      expect(posts[0].views).to eq(4)

    end

    it 'integers for any of many values' do

      complex_params[:columns][2][:search] = {
        "value": ["4", "3", "1"],
        "regex": false
      }

      dt_module = DataTables::Modules::Search.new(Post, Post.all, complex_params)

      posts = dt_module.search

      expect(posts.count).to eq(2)

    end

    it 'floats' do

      complex_params[:columns][3][:search] = {
        "value": ".5",
        "regex": false
      }

      dt_module = DataTables::Modules::Search.new(Post, Post.all, complex_params)

      posts = dt_module.search

      expect(posts.count).to eq(1)
      expect(posts[0].views).to eq(4)

    end

    it 'floats for any of many values' do

      complex_params[:columns][3][:search] = {
        "value": ["1", ".5", "1.5"],
        "regex": false
      }

      dt_module = DataTables::Modules::Search.new(Post, Post.all, complex_params)

      posts = dt_module.search

      expect(posts.count).to eq(2)

    end

    it 'strings' do

      complex_params[:columns][1][:search] = {
        "value": "foo",
        "regex": false
      }

      dt_module = DataTables::Modules::Search.new(Post, Post.all, complex_params)

      posts = dt_module.search

      expect(posts.count).to eq(1)
      expect(posts[0].title).to eq('foo')

    end

    it 'strings for any of many values' do

      complex_params[:columns][1][:search] = {
        "value": ["foo", "bar"],
        "regex": false
      }

      dt_module = DataTables::Modules::Search.new(Post, Post.all, complex_params)

      posts = dt_module.search

      expect(posts.count).to eq(2)

    end

    it 'uuids' do

      complex_params[:columns][0][:search] = {
        "value": User.find_by(email: 'foo@bar.com').id,
        "regex": false
      }

      dt_module = DataTables::Modules::Search.new(User, User.all, complex_params)

      users = dt_module.search

      expect(users.count).to eq(1)
      expect(users[0].email).to eq('foo@bar.com')

    end
  end

end
