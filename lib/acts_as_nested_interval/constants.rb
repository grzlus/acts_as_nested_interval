module ActsAsNestedInterval
  module Constants
    # Required fields by gem
    REQUIRED_COLUMNS = [:rgtp, :rgtq, :lftp, :lftq]

    class MissingColumn < Exception; end
  end
end
