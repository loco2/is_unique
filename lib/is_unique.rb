require 'digest/sha1'

module IsUnique
  def self.included(base)
    base.extend IsUnique::ClassMethods
  end

  module ClassMethods
    def is_unique(options = {})

      write_inheritable_attribute :is_unique_hash_column, options[:hash_column] || 'unique_hash'
      class_inheritable_reader    :is_unique_hash_column

      write_inheritable_attribute :is_unique_ignore, [
        primary_key,
        is_unique_hash_column.to_s,
        'created_at',
        'updated_at'
      ].concat(Array(options[:ignore]).map(&:to_s))

      unless self.include?(IsUnique::InstanceMethods)
        self.class_eval do
          include IsUnique::InstanceMethods

          before_save :calculate_unique_hash
        end
      end
    end
  end

  module InstanceMethods
    private

      def is_unique_hash
        send(self.class.is_unique_hash_column)
      end

      def is_unique_hash=(value)
        send("#{self.class.is_unique_hash_column}=", value)
      end

      def create
        if existing = self.class.find(:first, :conditions => {self.class.is_unique_hash_column => is_unique_hash})
          self.id = existing.id
          @new_record = false
          reload
          id
        else
          super
        end
      end

      def calculate_unique_hash
        self.is_unique_hash = Digest::SHA1.hexdigest(
          unique_attribute_names.inject('') do |r, e|
            r + "#{e}#{read_attribute_before_type_cast(e)}"
          end
        )
      end

      def unique_attribute_names
        attribute_names - self.class.read_inheritable_attribute(:is_unique_ignore)
      end
  end
end

ActiveRecord::Base.class_eval do
  include IsUnique
end
