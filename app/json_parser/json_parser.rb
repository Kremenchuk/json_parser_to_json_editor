class JsonParser
  attr_accessor :path_to_enum

  def initialize
    @path_to_enum = Hash.new
    path_to_enum[:path_to_enum] = Array.new
  end

  def parse_json(incoming_json, title)
    schema = create_json_schema(incoming_json, title)
    seeds = create_json_seeds(incoming_json)
    return [schema, incoming_json]
  end


  def create_json_schema(incoming_json, parent_name)
    {
        type: "object",
        title: parent_name,
        properties: incoming_json.collect { |k2, te2| create_slave_json(k2, te2) }.reduce({}, :merge)
    }
  end


  def create_slave_json(key, tree_element, parent = nil, enum_field = nil, enum_value = nil)
    if parent.present? && parent != path_to_enum[:old_parent]
      path_to_enum[:old_parent] = parent
      path_to_enum[:path] = path_to_enum[:path].to_s + "['" + parent.to_s + "']"
    elsif parent.nil?
      path_to_enum[:old_parent] = nil
      path_to_enum[:path] = nil
    end
    if key == 'enum'
      path_to_enum[:path_to_enum] << path_to_enum[:path]
      @enum_field = tree_element['field']
      @enum_value = tree_element['value']
      return {}
    end
    if @enum_field.present?
      enum_field = @enum_field
      enum_value = @enum_value
    end
    if tree_element.is_a? Hash
      hash_element_type(key, tree_element, enum_field, enum_value)
    elsif tree_element.is_a? Array
      if tree_element[0].present?
        if tree_element[0].is_a? Hash
          array_element_type(key, tree_element, enum_field, enum_value)
        elsif tree_element[0].is_a?(String) || tree_element[0].is_a?(Fixnum)
          single_element(key, tree_element, enum_field, enum_value, 'string')
        else
          array_element_type(key, tree_element, enum_field, enum_value)
        end
      else
        array_element_type(key, tree_element, enum_field, enum_value)
      end
    else
      single_element(key, tree_element, enum_field, enum_value)
    end
  end


  def create_json_seeds(incoming_json)
    if path_to_enum[:path_to_enum].present?
      path_to_enum[:path_to_enum].each do |path_elements|

      end
    end
  end
  foo = nil
  eval 'foo = "bar"'
  foo  #=> "bar"
  binding.local_variable_set :foo, 'baz'
  foo

  # def create_json_seeds(incoming_json)
  #   if path_to_enum[:path_to_enum].present?
  #     path_to_enum[:path_to_enum].each do |path_elements|
  #       enum_data = delete_enum_element(incoming_json, path_elements[1..-1])
  #       if enum_data.is_a? Array
  #         enum_data.delete_at(0)
  #         a=2
  #       end
  #     end
  #   end
  #   a=2
  # end
  #
  # def delete_enum_element(incoming_json, *key)
  #   from_hash_by_path(incoming_json, key.collect{|i| i.to_s.split('.')}.flatten)
  # end
  #
  # def from_hash_by_path(hash, path)
  #   begin
  #     path.inject(hash) do |acc, value|
  #       acc[value]
  #     end
  #   rescue
  #     nil
  #   end
  # end



private

  def single_element(key, tree_element, enum_field = nil, enum_value = nil, element_type = nil)
    if enum_field.present? && key == enum_field
      {
          "#{key}": {
              type: element_type || return_element_type(tree_element.class.name),
              default: tree_element,
              enum: enum_value
          }
      }
    else
      {
          "#{key}": {
              type: element_type || return_element_type(tree_element.class.name),
              default: tree_element
          }
      }
    end

  end

  def hash_element_type(key, tree_element, enum_field = nil, enum_value = nil)
    {
        "#{key}": {
            type: "object",
            properties: tree_element.collect { |k2, te2| create_slave_json(k2, te2, key ,enum_field, enum_value) }.reduce({}, :merge)
        }
    }
  end

  def array_element_type(key, tree_element,  enum_field = nil, enum_value = nil)
    {
        "#{key}": {
            type: "array",
            format: "table",
            uniqueItems: true,
            items: {
                type: "object",
                properties: tree_element.collect do |array_element|
                  if array_element.present? && (array_element.is_a?(Hash) || array_element.is_a?(Array))
                    array_element.collect { |k2, te2| create_slave_json(k2, te2, key ,enum_field, enum_value) }.reduce({}, :merge)
                  end
                end.reduce({}, :merge)
            }
        }
    }
  end


  def return_element_type(element_type)
    case element_type
      when 'Fixnum'
        "integer"
      when 'String'
        "string"
      when 'TrueClass'
        "boolean"
    end
  end

end
