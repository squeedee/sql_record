module SQLRecord
  module SanitizedQuery
    # Executes the {#query} proc on your database, building SQLRecords with the results.
    # @param params [Hash] a hash of parameters that are yielded to the {#query} proc
    # @return [Array] {SQLRecord::Base}s with their raw_attributes set to the row results.
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
        @query_proc.call(params)
    end

  end
end