-- biblioteki
local lapis = require("lapis")
local config = require("lapis.config").get()

local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local cjson = require("cjson.safe")
local underscore = require("underscore")
local errors = require("./errors")

--start 
local app = lapis.Application()

rules=  {
    test_model = {
      write = true,
      read = true
    },
    tabela_produkty = {
      write = true,
      read = true
    }
}

--funkcja do autoryzacji
function authenticator(model, operation_name)
  local model_rules = rules[model]
  if not model_rules then
    return function() return false end
  else
    local rule = model_rules[operation_name]
    if not rule then
      return function() return false end
    else
      return function(record, newRecord)
        return rule == true or (type(rule) == "function" and rule(record, newRecord) == true)
      end
    end
  end
end

-- Odbieramy dane
function getPostData()
  ngx.req.read_body()
  local validJson, data = pcall(function() return cjson.decode(ngx.req.get_body_data()) end)
  if not validJson then
    return nil
  elseif not data then
    return {}
  else
    return underscore.first(underscore.values(data))
  end
end

-- Main Page /
app:get("/", function()
  return "<h1>REST API pod sklep E-commerce, wersja Lapisa " .. require("lapis.version") .. " , werjsa " .. tostring(_VERSION) .. "</h1><br>Dostepne metody to GET i POST, dokumentacja w README :)"
end)

-- Create
app:post("/:model", function(self)
  local model = Model:extend(self.params.model)
  local data = getPostData()
  if not data or data == {} then
    return errors.post_params_empty()
  else
    local authenticate = authenticator(self.params.model, 'write')
    if not authenticate(nil, data) then
      return errors.unauthorized()
    else
      local create_successful = pcall(function() model:create(data) end)
      if not create_successful then
        return errors.database_operation("Rekord nie moe zosta utworzony!!!")
      else
        return { json = { [self.params.model] = { data } } }
      end
    end
  end
end)

-- Update, Delete
app:post("/:model/:id", function(self)
  local model = Model:extend(self.params.model)
  local find_successful, find_result = pcall(function() return model:find(self.params.id) end)
  if not find_successful then
    return errors.unknown_model(self.params.model)
  else
    local record = find_result
    if not record then
      return errors.invalid_id(self.params.id)
    else
      local data = getPostData()
      if not data then
        return errors.post_params_empty()
      else
        local authenticate = authenticator(self.params.model, 'write')
        if not authenticate(record, data) then
          return errors.unauthorized()
        else
          local database_operation_successful, info = pcall(function()
            if underscore.is_empty(data) then
              record:delete()
            else
              record:update(data)
            end
          end)
          if not database_operation_successful then
            return errors.database_operation("Nie mozna usunac lub zaktualizowac rekordu!!!")
          else
            return { json = { [self.params.model] = data } }
          end
        end
      end
    end
  end
end)

-- Read one
app:get("/:model/:id", function(self)
  local model = Model:extend(self.params.model)
  local find_successful, find_result = pcall(function() return model:find(self.params.id) end)
  if not find_successful then
    return errors.unknown_model(self.params.model)
  else
    local record = find_result
    if not record then
      return errors.invalid_id(self.params.id)
    else
      local authenticate = authenticator(self.params.model, 'read')
      if not authenticate(record) then
        return errors.unauthorized()
      else
        return { json = { [self.params.model] = { record } } }
      end
    end
  end
end)

-- Read Many
app:get("/:model", function(self)
  local authenticate = authenticator(self.params.model, 'read')
  if not authenticate then
    return errors.unauthorized()
  else
    local model = Model:extend(self.params.model)
    local query, required_values = nil, {}
    for key, value in pairs(self.req.params_get) do
      if string.sub(key, 1, 1) ~= "_" then
        required_values[key] = value
        if query == nil then
          query = "where "
        else
          query = query .. ' AND '
        end
        query = query .. db.escape_identifier(key) .. ' = ' .. db.escape_literal(value)
      end
    end

    local paginated = model:paginated(query, {
      per_page = self.params._per_page
    });

    local res
    if self.params._page then
      res = paginated:get_page(self.params._page)
    else
      res = paginated:get_all()
    end

    if not res then
      return data_errors({ query = { "Niepoprawny model albo id" } })
    else
      local records = underscore.select(res, function(record)
        return authenticate(record)
      end)
      return { json = { [self.params.model] = records } }
    end
  end
end)

return app
