module ActiveModel::Associations
  module Hooks
    def self.init
      ActiveSupport.on_load(:active_record) do
        require 'active_model/associations/association_scope_extension'
        ActiveRecord::Associations::AssociationScope.send(:prepend, ActiveModel::Associations::AssociationScopeExtension)
      end
    end
  end
end
