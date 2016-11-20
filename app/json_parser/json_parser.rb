module JsonParser
  def self.parse_json(incoming_json)
    return [create_json_schema(incoming_json, 'CSV json editor'), incoming_json]
  end

  def self.create_json_schema(incoming_json, parent_name)
    {
        type: "object",
        title: parent_name,
        properties: incoming_json.collect { |k2, te2| create_slave_json(k2, te2) }.reduce({}, :merge)
    }
  end


  def self.create_slave_json(key, tree_element)
    if tree_element.is_a? Hash
      hash_element_type(key, tree_element)
    elsif tree_element.is_a? Array
      if tree_element[0].present?
        if tree_element[0].is_a? Hash
          array_element_type(key, tree_element)
        elsif tree_element[0].is_a?(String) || tree_element[0].is_a?(Fixnum)
          single_element(key, tree_element, 'string')
        else
          array_element_type(key, tree_element)
        end
      else
        array_element_type(key, tree_element)
      end
    else
      single_element(key, tree_element)
    end
  end


private

  def self.single_element(key, tree_element, element_type = nil)
    {
        "#{key}": {
            type: element_type || return_element_type(tree_element.class.name),
            default: tree_element
        }
    }
  end

  def self.hash_element_type(key, tree_element)
    {
        "#{key}": {
            type: "object",
            properties: tree_element.collect { |k2, te2| create_slave_json(k2, te2) }.reduce({}, :merge)
        }
    }
  end

  def self.array_element_type(key, tree_element)
    {
        "#{key}": {
            type: "array",
            format: "table",
            uniqueItems: true,
            items: {
                type: "object",
                properties: tree_element.collect do |array_element|
                  if array_element.present? && (array_element.is_a?(Hash) || array_element.is_a?(Array))
                    array_element.collect do |k2, te2|
                      create_slave_json(k2, te2)
                    end.reduce({}, :merge)
                  end
                end.reduce({}, :merge)
            }
        }
    }
  end


  def self.return_element_type(element_type)
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
