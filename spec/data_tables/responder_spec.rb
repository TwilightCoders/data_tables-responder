require 'spec_helper'

require 'pry'

describe DataTables::Responder do

  before(:each) do
    user = User.create(email: 'foo@bar.baz')
    post = Post.create(user: user, title: 'foo')
    comment = Comment.create(post: post, user: user)
  end

  let!(:simple_params) do
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
          "data": "title",
          "name": "",
          "orderable": true,
          "search": { "regex": false, "value": "foo" },
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

  let!(:simple_bad_params) do
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
          "data": "missing_column",
          "name": "",
          "orderable": true,
          "search": { "regex": false, "value": "foo" },
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

  let!(:complex_bad_params) do
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
          "data": "post.foo.email",
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

  let!(:complex_params_with_order_and_empty_search) do
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
          "search": { "regex": false, "value": "" },
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

  it 'responds when given activerecord::base model' do
    response = DataTables::Responder.respond(Comment, complex_params)
      response_sql = response.to_sql

      expect(response.count).to eq(1)
      expect(response_sql).to include('"comments".* FROM "comments"')
  end

  describe 'handles complex' do
    it 'nested requests' do

      response = DataTables::Responder.respond(Comment.all, complex_params)
      response_sql = response.to_sql

      expect(response.count).to eq(1)
      expect(response_sql).to include('"comments".* FROM "comments"')
      expect(response_sql).to include('INNER JOIN "posts" ON "posts"."id" = "comments"."post_id"')
      expect(response_sql).to include('JOIN "users" ON "users"."id" = "posts"."user_id"')
      expect(response_sql).to include('WHERE ("users"."email" ILIKE \'%foo@bar.baz%\')')
      expect(response_sql).to include('ORDER BY "users"."email" ASC')
      expect(response_sql).to include('LIMIT 10 OFFSET 0')
    end

    it 'nested requests with bad data' do

      response = DataTables::Responder.respond(Comment.all, complex_bad_params)
      response_sql = response.to_sql

      expect(response.count).to eq(1)
      expect(response_sql).to include('"comments".* FROM "comments"')
      expect(response_sql).to include('LIMIT 10 OFFSET 0')
    end

    it 'nested requests when sorting without searching' do

      response = DataTables::Responder.respond(Comment.all, complex_params_with_order_and_empty_search)
      response_sql = response.to_sql

      expect(response.count).to eq(1)
      expect(response_sql).to include('"comments".* FROM "comments"')
      expect(response_sql).to include('INNER JOIN "posts" ON "posts"."id" = "comments"."post_id"')
      expect(response_sql).to include('JOIN "users" ON "users"."id" = "posts"."user_id"')
      expect(response_sql).to include('ORDER BY "users"."email" ASC')
      expect(response_sql).to include('LIMIT 10 OFFSET 0')
    end
  end

  describe 'handles simple' do
    it 'nested requests' do

      response = DataTables::Responder.respond(Post.all, simple_params)
      response_sql = response.to_sql

      expect(response.count).to eq(1)
      expect(response_sql).to include('WHERE ("posts"."title" ILIKE \'%foo%\')')
      expect(response_sql).to include('ORDER BY "posts"."title" ASC')
      expect(response_sql).to include('LIMIT 10 OFFSET 0')
    end

    it 'nested requests with bad data' do

      response = DataTables::Responder.respond(Post.all, simple_bad_params)
      response_sql = response.to_sql

      expect(response.count).to eq(1)
      expect(response_sql).to include('"posts".* FROM "posts"')
      expect(response_sql).to_not include('"posts"."missing_column"')
      expect(response_sql).to include('LIMIT 10 OFFSET 0')
    end
  end

end
