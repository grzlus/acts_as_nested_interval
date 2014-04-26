module ActsAsNestedInterval
  class Configuration

    attr_reader :foreign_key, :dependent

    # multiple_roots - allow more than one root
    def initialize( model, virtual_root: false, foreign_key: :parent_id, dependent: :restrict_with_exception, scope_columns: [] )
      @multiple_roots = !!virtual_root
      @foreign_key = foreign_key
      @dependent = dependent

      check_model_columns( model )
    end

    def multiple_roots?
      @multiple_roots
    end

    def fraction_cache?
      @fraction_cache
    end

    private

    def check_model_columns( model )
      if missing_column = Constants::REQUIRED_COLUMNS.detect { |col| !model.columns_hash.has_key?( col.to_s ) }
        raise Constants::MissingColumn.new( missing_column )
      end

      @fraction_cache = [:lft, :rgt].all? { |col| model.columns_hash.has_key?( col.to_s ) }
    end

  end
end
