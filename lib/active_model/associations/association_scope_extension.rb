module ActiveModel::Associations
  module AssociationScopeExtension
    def add_constraints(scope, owner, assoc_klass, refl, tracker)
      if refl.options[:active_model]
        target_ids = refl.options[:target_ids]
        return scope.where(id: owner[target_ids])
      end

      super
    end
  end
end
