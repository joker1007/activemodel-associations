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

      def []=(attr, value)
        self.send("#{attr}=", value)
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

        it "receives target ActiveRecord instance, and set foreign_key attributes" do
          other_user = User.create(name: "kakyoin")
          expect { comment.user = other_user }.to change { [comment.user, comment.user_id] }
            .from([user, user.id]).to([other_user, other_user.id])
        end
      end

      describe "defined builder" do
        it "sets foreign_key" do
          comment.create_user(name: "joker1007")
          expect(comment.user).to be_a(User)
          expect(comment.user).to be_persisted
          expect(comment.user_id).not_to be_nil
        end
      end

      context "When set foreign_key manually" do
        let!(:user) { User.create(name: "joker1007") }
        let(:comment) { Comment.new }

        it "can access target ActiveRecord instance" do
          expect { comment.user_id = user.id }.to change { comment.user }
            .from(nil).to(user)
        end
      end

      it "can define polymorphic association" do
        class PolymorhicBelongsToComment < Comment
          attr_accessor :commenter_id, :commenter_type
          belongs_to :commenter, polymorphic: true
        end

        user = User.create(name: "joker1007")
        comment = PolymorhicBelongsToComment.new(commenter_id: user.id, commenter_type: "User")
        expect(comment.commenter).to eq user
      end

      it "can define different class_name association" do
        class DiffClassNameBelongsToComment < Comment
          attr_accessor :commenter_id
          belongs_to :commenter, class_name: "User"
        end

        user = User.create(name: "joker1007")
        comment = DiffClassNameBelongsToComment.new(commenter: user)
        expect(comment.commenter_id).to eq user.id
      end
    end
  end
end
