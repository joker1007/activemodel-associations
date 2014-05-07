require 'spec_helper'

describe ActiveModel::Association do
  context "When included Comment class" do
    class Comment
      include ActiveModel::Model
      include ActiveModel::Association

      attr_accessor :body, :user_id

      belongs_to :user

      def [](attr)
        self.send(attr)
      end
    end

    it "Add belongs_to macro" do
      expect(Comment).to be_respond_to(:belongs_to)
    end

    it "extends constructor" do
      comment = Comment.new(body: "foo")
      expect(comment.body).to eq "foo"
      expect(comment.instance_variable_get("@association_cache")).to eq({})
    end

    describe ".belongs_to" do
      let(:comment) { Comment.new }

      it "defines association accessor" do
        expect(comment).to be_respond_to(:user)
        expect(comment).to be_respond_to(:user=)
      end

      describe "defined accessor" do
        let(:user) { User.create(name: "joker1007") }
        let(:comment) { Comment.new(user_id: user.id) }

        it "defined accessor loads target ActiveRecord instance" do
          expect(comment.user).to eq user
        end
      end
    end
  end
end
