require 'active_model/associations/initialize_extension'
require 'active_model/associations/active_record_reflection'
require 'active_model/associations/autosave_association'
require 'active_model/associations/override_methods'
require 'active_record/associations/builder/has_many_for_active_model'
require 'active_record/associations/has_many_for_active_model_association'

module ActiveModel
  module Associations
    extend ActiveSupport::Concern

    include InitializeExtension
    include AutosaveAssociation
    include ActiveRecordReflection
    include OverrideMethods

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
    end
  end
end
