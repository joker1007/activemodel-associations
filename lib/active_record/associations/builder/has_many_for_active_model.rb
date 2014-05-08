module ActiveRecord::Associations::Builder
  class HasManyForActiveModel < HasMany
    def valid_options
      super + [:active_model, :target_ids] - [:through, :dependent, :source, :source_type, :counter_cache, :as]
    end
  end
end
