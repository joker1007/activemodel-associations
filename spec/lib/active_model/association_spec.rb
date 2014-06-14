require 'spec_helper'

describe ActiveModel::Associations do
  context "When included Comment class" do
    class Comment
      include ActiveModel::Model
      include ActiveModel::Associations

      attr_accessor :body, :user_id

      belongs_to :user

      def [](attr)
        self.send(attr)
      end

      def []=(attr, value)
        self.send("#{attr}=", value)
      end
    end

    it "extends constructor" do
      comment = Comment.new(body: "foo")
      expect(comment.body).to eq "foo"
      expect(comment.instance_variable_get("@association_cache")).to eq({})
    end

    describe "belongs_to" do
      it "Add belongs_to macro" do
        expect(Comment).to be_respond_to(:belongs_to)
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

          it "can validate" do
            expect(comment.valid?).to be_truthy
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

    describe "has_many" do
      class Group
        include ActiveModel::Model
        include ActiveModel::Associations

        attr_accessor :name
        attr_reader :user_ids

        has_many :users

        def [](attr)
          self.send(attr)
        end

        def []=(attr, value)
          self.send("#{attr}=", value)
        end
      end

      let(:group) { Group.new }

      it "Add has_many macro" do
        expect(Group).to be_respond_to(:has_many)
      end

      describe ".has_many" do
        it "defines association accessor" do
          expect(group).to be_respond_to(:users)
          expect(group).to be_respond_to(:users=)
        end

        describe "defined accessor" do
          let!(:user1) { User.create(name: "joker1007") }
          let!(:user2) { User.create(name: "kakyoin") }
          let(:group) { Group.new(user_ids: [user1.id, user2.id]) }

          it "returns ActiveRecord CollectionProxy of target class" do
            expect(group.users).to eq [user1, user2]
            expect(group.users.find_by(id: user1.id)).to eq user1
          end

          it "receives target ActiveRecord instance Array, and set target_ids attributes" do
            group = Group.new
            expect(group.users).to be_empty
            group.users = [user1, user2]
            expect(group.users).to eq [user1, user2]
          end

          it "replace target, and set target_ids attributes" do
            expect(group.users).to eq [user1, user2]
            group.users = [user1]
            expect(group.users).to eq [user1]
            group.users = []
            expect(group.users).to be_empty
          end

          it "receives target ActiveRecord CollectionProxy, and set target_ids attributes" do
            group = Group.new
            expect(group.users).to be_empty
            group.users = User.all
            expect(group.users).to eq [user1, user2]
          end

          it "can replace having association" do
            user3 = User.create(name: "jotaro")
            group = Group.new
            expect(group.users).to be_empty
            group.users = [user1, user2]
            group.users = [user3]
            expect(group.users).to eq [user3]
          end

          it "can concat records" do
            expect(group.users).to eq [user1, user2]
            user3 = User.create(name: "jotaro")
            group.users << user3
            expect(group.users).to eq [user1, user2, user3]
          end

          it "can validate" do
            expect(group.valid?).to be_truthy
          end
        end

        context "When set target_ids manually" do
          let!(:user) { User.create(name: "joker1007") }
          let(:group) { Group.new }

          it "can access target ActiveRecord instance" do
            expect(group.users).to be_empty
            group.user_ids = [user.id]
            expect(group.users).to eq [user]
          end
        end

        context "When ids attribute is nil" do
          let!(:user) { User.create(name: "joker1007") }
          let(:group) { Group.new }

          it "can concat" do
            expect(group.users).to be_empty
            group.users << user
            expect(group.users).to eq [user]
          end
        end

        it "can define different class_name association" do
          class DiffClassNameHasManyGroup < Group
            attr_reader :member_ids
            has_many :members, class_name: "User"
          end

          user = User.create(name: "joker1007")
          group = DiffClassNameHasManyGroup.new(members: [user])
          expect(group.member_ids).to eq [user.id]
          expect(group.members).to eq [user]
        end

        %i(through dependent source source_type counter_cache as).each do |option_name|
          it "#{option_name} option is unsupported" do
            expect {
              eval <<-CODE
                class #{option_name.to_s.classify}Group
                  include ActiveModel::Model
                  include ActiveModel::Associations

                  has_many :users, #{option_name}: true
                end
              CODE
            }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
