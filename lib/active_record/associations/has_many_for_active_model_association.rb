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
      original_target = load_target.dup
      other_array.each { |val| raise_on_type_mismatch!(val) }
      target_ids = reflection.options[:target_ids]
      owner[target_ids] = other_array.map(&:id)

      old_records = original_target - other_array
      old_records.each do |record|
        @target.delete(record)
      end

      other_array.each do |record|
        if index = @target.index(record)
          @target[index] = record
        else
          @target << record
        end
      end
    end

    # no need transaction
    def concat(*records)
      load_target
      flatten_records = records.flatten
      flatten_records.each { |val| raise_on_type_mismatch!(val) }
      target_ids = reflection.options[:target_ids]
      owner[target_ids] ||= []
      owner[target_ids].concat(flatten_records.map(&:id))

      flatten_records.each do |record|
        if index = @target.index(record)
          @target[index] = record
        else
          @target << record
        end
      end

      target
    end

    private

    def get_records
      return scope.to_a if reflection.scope_chain.any?(&:any?)

      target_ids = reflection.options[:target_ids]
      klass.where(id: owner[target_ids]).to_a
    end
  end
end
