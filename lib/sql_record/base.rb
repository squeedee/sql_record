module SQLRecord
  # Base provides a class that has a collection of raw_attributes.
  # These can be set from a database abstraction (SQLRecord::SanitizedQuery), and are expected to be type_cast by a mixin
  #   (SQLRecord::Attributes::Mapper)
  #
  # @todo Does it sound like the database abstraction could be a whole other class?
  class Base
    extend SQLRecord::SanitizedQuery
    extend SQLRecord::Attributes::Mapper

    # the raw attributes returned from a db query
    attr_reader :raw_attributes

    def initialize raw_attributes = {}
      @raw_attributes = raw_attributes
    end

  end
end