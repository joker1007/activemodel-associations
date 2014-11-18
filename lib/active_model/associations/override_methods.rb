module ActiveModel::Associations
  module OverrideMethods
    extend ActiveSupport::Concern

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

      protected

      def compute_type(type_name)
        if type_name.match(/^::/)
          # If the type is prefixed with a scope operator then we assume that
          # the type_name is an absolute reference.
          ActiveSupport::Dependencies.constantize(type_name)
        else
          # Build a list of candidates to search for
          candidates = []
          name.scan(/::|$/) { candidates.unshift "#{$`}::#{type_name}" }
          candidates << type_name

          candidates.each do |candidate|
            begin
              constant = ActiveSupport::Dependencies.constantize(candidate)
              return constant if candidate == constant.to_s
              # We don't want to swallow NoMethodError < NameError errors
            rescue NoMethodError
              raise
            rescue NameError
            end
          end

          raise NameError.new("uninitialized constant #{candidates.first}", candidates.first)
        end
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

    # dummy
    def new_record?
      false
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
