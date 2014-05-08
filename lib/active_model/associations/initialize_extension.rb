module ActiveModel::Associations
  module InitializeExtension
    extend ActiveSupport::Concern

    included do
      prepend WithAssociationCache
    end

    module WithAssociationCache
      def initialize(*args)
        @association_cache = {}
        super
      end
    end
  end
end
