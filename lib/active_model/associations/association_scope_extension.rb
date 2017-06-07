module ActiveModel::Associations
  module AssociationScopeExtension
    if ActiveRecord.version >= Gem::Version.new("5.1.0")
      def add_constraints(scope, owner, refl, chain_head, chain_tail)
        if refl.options[:active_model]
          target_ids = refl.options[:target_ids]
          return scope.where(id: owner[target_ids])
        end

        super
      end
    elsif ActiveRecord.version >= Gem::Version.new("5.0.0.beta")
      def add_constraints(scope, owner, association_klass, refl, chain_head, chain_tail)
        if refl.options[:active_model]
          target_ids = refl.options[:target_ids]
          return scope.where(id: owner[target_ids])
        end

        super
      end
    else
      def add_constraints(scope, owner, assoc_klass, refl, tracker)
        if refl.options[:active_model]
          target_ids = refl.options[:target_ids]
          return scope.where(id: owner[target_ids])
        end

        super
      end
    end
  end
end
