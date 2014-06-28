module ActiveModel::Associations
  module ActiveRecordReflection
    extend ActiveSupport::Concern

    included do
      if ActiveRecord.version.to_s >= "4.1.2"
        class_attribute :_reflections
        self._reflections = ActiveSupport::HashWithIndifferentAccess.new
      else
        class_attribute :reflections
        self.reflections = {}
      end
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
        if ActiveRecord.version.to_s >= "4.1.2"
          _reflections[association.to_s]
        else
          reflections[association]
        end
      end
    end
  end
end
