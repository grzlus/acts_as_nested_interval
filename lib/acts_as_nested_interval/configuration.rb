module ActsAsNestedInterval
  class Configuration

    attr_reader :foreign_key 

    # multiple_roots - allow more than one root
    def initialize( virtual_root: false, foreign_key: :parent_id, dependent: :restrict_with_exception, scope_columns: [] )
      @multiple_roots = !!multiple_roots
      @foreign_key = foreign_key
    end

    def multiple_roots?
      @multiple_roots
    end

  end
end
