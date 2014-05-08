module ActiveModel::Associations
  module ActiveRecordReflection
    extend ActiveSupport::Concern

    included do
      class_attribute :reflections
      self.reflections = {}
    end

    module ClassMethods
      if ActiveRecord.version.to_s < "4.1"
        def create_reflection(macro, name, scope, options, active_record)
          case macro
          when :has_many, :belongs_to
            klass =  ActiveRecord::Reflection::AssociationReflection
            reflection = klass.new(macro, name, scope, options, active_record)
          end

          self.reflections = self.reflections.merge(name => reflection)
          reflection
        end
      end

      def reflect_on_association(association)
        reflections[association]
      end
    end
  end
end
