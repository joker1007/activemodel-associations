module ActiveModel::Associations
  module AssociationScopeExtension
    if ActiveRecord.version.to_s < "4.1"
      def add_constraints(scope)
        if reflection.options[:active_model]
          target_ids = reflection.options[:target_ids]
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
