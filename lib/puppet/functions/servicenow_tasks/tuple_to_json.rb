require 'json'

#This custom function takes in a tuple datatype and returns JSON.
Puppet::Functions.create_function(:'servicenow_tasks::tuple_to_json') do
  dispatch :tuple_to_json do
    required_param 'Tuple',  :data
  end

  def tuple_to_json(data)
    data.to_json
  end
end
