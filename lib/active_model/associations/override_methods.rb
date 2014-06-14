module ActiveModel::Associations
  module OverrideMethods
    extend ActiveSupport::Concern

    included do
      # borrow method definition from ActiveRecord::Inheritance
      # use in Rails internal
      mod = Module.new do
        unbound = ActiveRecord::Inheritance::ClassMethods.instance_method(:compute_type)
        define_method(:compute_type, unbound)
        protected :compute_type
      end
      extend mod
    end

    module ClassMethods
      def generated_association_methods
        @generated_association_methods ||= begin
          mod = const_set(:GeneratedAssociationMethods, Module.new)
          include mod
          mod
        end
      end
      alias :generated_feature_methods :generated_association_methods \
        if ActiveRecord.version.to_s < "4.1"

      # override
      def dangerous_attribute_method?(name)
        false
      end

      # dummy table name
      def pluralize_table_names
        self.to_s.pluralize
      end
    end

    # use by association accessor
    def association(name) #:nodoc:
      association = association_instance_get(name)

      if association.nil?
        reflection  = self.class.reflect_on_association(name)
        if reflection.options[:active_model]
          association = ActiveRecord::Associations::HasManyForActiveModelAssociation.new(self, reflection)
        else
          association = reflection.association_class.new(self, reflection)
        end
        association_instance_set(name, association)
      end

      association
    end

    def read_attribute(name)
      send(name)
    end

    private

    # override
    def validate_collection_association(reflection)
      if association = association_instance_get(reflection.name)
        if records = associated_records_to_validate_or_save(association, false, reflection.options[:autosave])
          records.each { |record| association_valid?(reflection, record) }
        end
      end
    end

    # use in Rails internal
    def association_instance_get(name)
      @association_cache[name]
    end

    # use in Rails internal
    def association_instance_set(name, association)
      @association_cache[name] = association
    end
  end
end
