module SQLRecord

  def initialize(row)
    @row = row
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def with_class klass, &block
      @current_class = klass
      block.arity == 2 ? yield(self) : self.instance_eval(&block)
      @current_class = nil
    end

    def column attribute_name, opts = {}
      klass = opts[:class] || @current_class || nil
      raise ArgumentError, 'Either opts[:class] is not defined or you have not specified a with_class block' if klass.nil?

      source_attribute = (opts[:from] || attribute_name).to_s

      define_method attribute_name do
        klass.columns_hash[source_attribute].type_cast(@row[attribute_name.to_s])
      end

      select_column = "#{klass.table_name}.#{source_attribute}"
      select_column += " as #{attribute_name}" if opts[:from]

      (@sql_select_columns ||= []) << select_column
    end

    def query &deferred
      @query_proc = deferred
    end

    def find params={}
      rows = execute_query params

      rows.map do |row|
        new row
      end
    end

    protected

    def execute_query params={}
      # does this log (hope so)
      sql = ActiveRecord::Base.send(:sanitize_sql_array, get_query_array(params))
      ActiveRecord::Base.connection.execute(sql)
    end

    def get_query_array(params)
      if @query_proc.arity == 2
        @query_proc.call(params, @sql_select_columns.join(", "))
      else
        @query_proc.call(params)
      end
    end

  end

end
