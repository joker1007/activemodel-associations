require 'active_model/associations/active_record_reflection'
require 'active_model/associations/autosave_association'
require 'active_record/associations/builder/has_many_for_active_model'
require 'active_record/associations/has_many_for_active_model_association'

module AssociationScopeExtension
  def add_constraints(scope, owner, assoc_klass, refl, tracker)
    if refl.options[:active_model]
      target_ids = refl.options[:target_ids]
      return scope.where(id: owner[target_ids])
    end

    super
  end
end

ActiveRecord::Associations::AssociationScope.prepend AssociationScopeExtension

module ActiveModel
  module Associations
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

      def has_many(name, scope = nil, options = {}, &extension)
        options.reverse_merge!(target_ids: "#{name.to_s.singularize}_ids")
        options.merge!(active_model: true)

        reflection = ActiveRecord::Associations::Builder::HasManyForActiveModel.build(self, name, scope, options, &extension)
        ActiveRecord::Reflection.add_reflection self, name, reflection

        mixin = generated_association_methods
        mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{options[:target_ids]}=(other_ids)
            @#{options[:target_ids]} = other_ids
            association(:#{name}).reset
            association(:#{name}).reset_scope
            @#{options[:target_ids]}
          end
        CODE
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
        if reflection.options[:active_model]
          association = ActiveRecord::Associations::HasManyForActiveModelAssociation.new(self, reflection)
        else
          association = reflection.association_class.new(self, reflection)
        end
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
