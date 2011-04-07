module SQLRecord
  module SanitizedQuery
    def find params={}
      rows = execute_query params

      rows.map do |row|
        new row
      end
    end

    def query &deferred
      @query_proc = deferred
    end

    protected

    # @todo check that this logs the sql
    def execute_query params={}
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