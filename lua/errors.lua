local config = require('lapis.config').get()
local cjson = require('cjson')

function data_errors(errors)
  if config.logging.requests == true then
    print('\nBlad danych: ' .. cjson.encode(errors) .. '\n')
  end
-- zwracam status 422, bledne dane wyslane w request
  return { json = { errors = errors }, status = 422 }
end

return {
  -- Autoryzacja
  unauthorized = function()
    return data_errors({ unauthorized = { 'Brak dostepu' } })
  end,

  -- Dane wejsciowe
  json = function(json_err)
    return data_errors({ json = { json_err } })
  end,

  post_params_empty = function()
    return data_errors({ post = { 'Brak parametrow dla metody POST' } })
  end,

  -- Baza danych
  unknown_model = function(model)
    return data_errors({ database = { 'Nieznany model: ' .. model } })
  end,

  invalid_id = function(id)
    return data_errors({ database = { 'Bledne ID: ' .. id } })
  end,

  database_operation = function(operation)
    return data_errors({ database = { operation } })
  end
}
