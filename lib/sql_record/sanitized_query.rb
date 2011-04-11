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

    # Specifies the query to execute
    # @yield the block that will be executed with each {#find}
    # @yieldparam [Hash] params the parametrs passed in from {#find}
    # @yieldreturn [Array, String] Either the sql string or a sanitize array to be executed.
    # @note
    #   do not try to sanitize identifiers, only values will sanitize well
    #     ["where id = ?", 1] => "where id = 1"
    #     ["where name = ?", "hello"] => "where id = 'hello'"
    #     ["ORDER BY ? ASC", "id"] => "ORDER BY 'id' ASC"  << not legitimate SQL
    def query &deferred
      @query_proc = deferred
    end

    protected

    # @todo check that this logs the sql
    # @todo Write own sanitizer: (http://www.ruby-forum.com/topic/187658)
    #   sanitize_sql_array sanitizes values correctly, not identifiers, eg:
    #   ["where id = ?", 1] => "where id = 1"
    #   ["where name = ?", "hello"] => "where id = 'hello'"
    #   ["ORDER BY ? ASC", "id"] => "ORDER BY 'id' ASC"  << not legitimate SQL
    def execute_query params={}
      sql = get_query(params)
      sql = ActiveRecord::Base.send(:sanitize_sql_array, sql) if sql.is_a?(Array)
      ActiveRecord::Base.connection.execute(sql)
    end

    def get_query(params)
        @query_proc.call(params)
    end

  end
end