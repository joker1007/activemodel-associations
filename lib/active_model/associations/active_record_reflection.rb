module ActiveModel::Associations
  module ActiveRecordReflection
    extend ActiveSupport::Concern

    included do
      class_attribute :reflections
      self.reflections = {}
    end

    module ClassMethods
      def reflect_on_association(association)
        reflections[association]
      end
    end
  end
end
