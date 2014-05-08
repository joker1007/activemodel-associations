module ActiveRecord::Associations
  class HasManyForActiveModelAssociation < HasManyAssociation
    # remove conditions: owner.new_record?, foreign_key_present? 
    def find_target?
      !loaded? && klass
    end

    # no dependent action
    def null_scope?
      false
    end

    # full replace simplely
    def replace(other_array)
      other_array.each { |val| raise_on_type_mismatch!(val) }
      target_ids = reflection.options[:target_ids]
      owner[target_ids] = other_array.map(&:id)
    end

    # no need load_target, and transaction
    def concat(*records)
      flatten_records = records.flatten
      flatten_records.each { |val| raise_on_type_mismatch!(val) }
      target_ids = reflection.options[:target_ids]
      owner[target_ids] ||= []
      owner[target_ids].concat(flatten_records.map(&:id))
      reset
      reset_scope
    end
  end
end
