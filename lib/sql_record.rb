# @author Rasheed Abdul-Aziz
module SQLRecord

  def initialize(row)
    @row = row
  end

  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end

  module ClassMethods

    # with_opts blocks specify default options for calls to {#column}
    #
    # @param opts [Hash] anything that {#column} supports. Currently this should only be :class
    #
    # @example Longhand (not using with_opts)
    #   column :name, :class => Account
    #   column :id, :class => Account
    #   ...snip...
    #   column :created_at, :class => Account
    #
    # @example Shorthand (using with_opts)
    #   with_opts :class => Account
    #     column :name
    #     column :id
    #     ...snip...
    #     column :created_at
    #   end

    def with_opts opts, &block
      @default_opts = opts
      block.arity == 2 ? yield(self) : self.instance_eval(&block)
      @default_opts = nil
    end


    # Specifies the mapping from an ActiveRecord#column_definition to an SQLRecord instance attribute.
    # @param [Symbol] attribute_name the attribute you are defining for this model
    # @option opts [Class] :class the active record this attribute will use to type_cast from
    # @option opts [Symbol,String] :from if it differs from the attribute_name, the schema column of the active record
    #   to use for type_cast
    #
    # @example Simple mapping
    #   # Account#name column maps to the "name" attribute
    #   column :name, :class => Account
    #
    # @example Mapping a different column name
    #   # Account#name column maps to the "account name" attribute
    #   column :account_name, :class => Account, :from => :name
    def column attribute_name, opts = {}
      klass = opts[:class] || @default_opts[:class] || nil
      raise ArgumentError, 'You must specify a :clas soption, either explicitly, or using with_opts' if klass.nil?

      source_attribute = (opts[:from] || attribute_name).to_s

      define_method attribute_name do
        klass.columns_hash[source_attribute].type_cast(@row[attribute_name.to_s])
      end

      # bit mucky, a lot here that feels like it should be a little method of its own
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
      # does this log?
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
