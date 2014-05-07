require 'active_model/active_record_reflection'
require 'active_model/autosave_association'

module ActiveModel
  module Association
    extend ActiveSupport::Concern

    include AutosaveAssociation
    include ActiveRecordReflection

    included do
      prepend InitializeExtension
      attr_reader :association_cache

      mod = Module.new do
        unbound = ActiveRecord::Inheritance::ClassMethods.instance_method(:compute_type)
        meth = define_method(:compute_type, unbound)
        protected meth
      end

      extend mod
    end

    module ClassMethods
      def belongs_to(name, scope = nil, options = {})
        reflection = ActiveRecord::Associations::Builder::BelongsTo.build(self, name, scope, options)
        ActiveRecord::Reflection.add_reflection self, name, reflection
      end

      def generated_association_methods
        @generated_association_methods ||= begin
          mod = const_set(:GeneratedAssociationMethods, Module.new)
          include mod
          mod
        end
      end

      # override
      def dangerous_attribute_method?(name)
        false
      end

      # dummy
      def pluralize_table_names
        self.to_s.pluralize
      end
    end

    module InitializeExtension
      def initialize(*args)
        @association_cache = {}
        super
      end
    end

    def association(name) #:nodoc:
      association = association_instance_get(name)

      if association.nil?
        reflection  = self.class.reflect_on_association(name)
        association = reflection.association_class.new(self, reflection)
        association_instance_set(name, association)
      end

      association
    end

    private

    def association_instance_get(name)
      @association_cache[name]
    end

    # Set the specified association instance.
    def association_instance_set(name, association)
      @association_cache[name] = association
    end
  end
end
