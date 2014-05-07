module ActiveRecord::Associations::Builder
  class HasManyForActiveModel < HasMany
    def valid_options
      super + [:active_model, :target_ids]
    end
  end
end
