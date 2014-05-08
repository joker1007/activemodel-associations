require 'active_model/associations/initialize_extension'
require 'active_model/associations/active_record_reflection'
require 'active_model/associations/autosave_association'
require 'active_record/associations/builder/has_many_for_active_model'
require 'active_record/associations/has_many_for_active_model_association'

module ActiveModel
  module Associations
    extend ActiveSupport::Concern

    include InitializeExtension
    include AutosaveAssociation
    include ActiveRecordReflection

    included do
      # borrow method definition from ActiveRecord::Inheritance
      # use in Rails internal
      mod = Module.new do
        unbound = ActiveRecord::Inheritance::ClassMethods.instance_method(:compute_type)
        protected define_method(:compute_type, unbound)
      end
      extend mod
    end

    module ClassMethods
      # define association like ActiveRecord
      def belongs_to(name, scope = nil, options = {})
        reflection = ActiveRecord::Associations::Builder::BelongsTo.build(self, name, scope, options)
        if ActiveRecord.version.to_s >= "4.1"
          ActiveRecord::Reflection.add_reflection self, name, reflection
        end
      end

      # define association like ActiveRecord
      def has_many(name, scope = nil, options = {}, &extension)
        options.reverse_merge!(active_model: true, target_ids: "#{name.to_s.singularize}_ids")
        if scope.is_a?(Hash)
          options.merge!(scope)
          scope = nil
        end

        reflection = ActiveRecord::Associations::Builder::HasManyForActiveModel.build(self, name, scope, options, &extension)
        if ActiveRecord.version.to_s >= "4.1"
          ActiveRecord::Reflection.add_reflection self, name, reflection
        end

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
      alias :generated_feature_methods :generated_association_methods # for ActiveRecord-4.0.x

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

    private

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
