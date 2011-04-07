module SQLRecord
  class Base
    extend SQLRecord::SanitizedQuery
    extend SQLRecord::Attributes::Mapper

    attr_accessor :raw_attributes

    def initialize raw_attributes = {}
      @raw_attributes = raw_attributes
    end

  end
end