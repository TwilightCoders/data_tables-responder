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
          "data": "created_at",
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

  context 'when searching' do

    before(:each) do
      User.create(email: 'foo@bar.com')
      User.create(email: 'foo2@bar.com')
      Post.create(title: 'foo', views: 4, created_at: DateTime.now + 30.minutes)
      Post.create(title: 'bar', views: 3, created_at: DateTime.now)
      Post.create(title: 'biz', views: 8, created_at: DateTime.now + 1.hour + 30.minutes)
      Post.create(title: 'baz', views: 93, created_at: DateTime.now + 1.hour)
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

      expect(posts.count).to eq(1)
      expect(posts[0].title).to eq('foo')

    end

    context 'datetimes' do

      xit 'should return error for incorrect formats' do

      end

      it 'should find hours' do
        date_format = DataTables::Modules::Search.date_parts.slice(:year, :month, :day, :hour).values.join

        # binding.pry
        complex_params[:columns][3][:search] = {
          "value": DateTime.current.strftime(date_format),
          "regex": false
        }

        dt_module = DataTables::Modules::Search.new(Post, Post.all, complex_params)

        posts = dt_module.search

        expect(posts.count).to eq(2)
        expect(posts[0].title).to eq('foo')
      end

      it 'should find minutes' do
        date_format = DataTables::Modules::Search.date_format(:year, :month, :day, :hour, :minute)

        # binding.pry
        complex_params[:columns][3][:search] = {
          "value": DateTime.current.strftime(date_format),
          "regex": false
        }

        dt_module = DataTables::Modules::Search.new(Post, Post.all, complex_params)

        posts = dt_module.search
        puts posts.to_sql

        expect(posts.count).to eq(1)
        expect(posts[0].title).to eq('bar')
      end

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

    it 'supports dates' do
      date_format = DataTables::Modules::Search.date_format(:year, :month, :day, :hour)
      date_string = DateTime.current.strftime(date_format)
      expect(DataTables::Modules::Search.find_date_precision(date_string)).to eq([:hour, DateTime.parse(date_string)])
    end

  end

end
