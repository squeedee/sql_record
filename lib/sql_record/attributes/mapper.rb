# @author Rasheed Abdul-Aziz
module SQLRecord
  module Attributes
    module Mapper

      attr_reader :sql_select_columns

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
      #
      def with_opts opts, &block
        @default_opts = opts
        block.arity == 2 ? yield(self) : self.instance_eval(&block)
        @default_opts = nil
      end

      # Sugar for with
      def with_class klass, opts = {}, &block
        opts[:class] = klass
        with_opts opts, &block
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
      #
      def column attribute_name, opts = {}
        klass = opts[:class] || @default_opts[:class] || nil
        raise ArgumentError, 'You must specify a :class option, either explicitly, or using with_opts' if klass.nil?

        source_attribute = (opts[:from] || attribute_name).to_s

        define_method attribute_name do
          return YAML.load(@raw_attributes[attribute_name.to_s]) if klass.serialized_attributes.has_key?(source_attribute)
          klass.columns_hash[source_attribute].type_cast(@raw_attributes[attribute_name.to_s])
        end

        # bit mucky, a lot here that feels like it should be a little method of its own
        select_column = "#{klass.table_name}.#{source_attribute}"
        select_column += " as #{attribute_name}" if opts[:from]
        (@sql_select_columns ||= []) << select_column
      end

    end
  end
end
