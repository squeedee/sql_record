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
      sql = ActiveRecord::Base.send(:sanitize_sql_array, @query_proc.call(params))
      ActiveRecord::Base.connection.execute(sql)
    end

  end

end
