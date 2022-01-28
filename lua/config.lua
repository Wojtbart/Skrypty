local config = require("lapis.config")

config("development", {
  postgres = {
    backend = "pgmoon",
    host = "127.0.0.1",
    user = "postgres",
    password = "postgres",
    --database = "kategorie"
    database = "produkty"
  },
  port = 8080
})

config("production", {
  postgres = {
    backend = "pgmoon",
    host = "127.0.0.1",
    user = "postgres",
    password = "postgres",
    --database = "kategorie"
    database = "produkty"
  },
  port = 80,
  logging = {
    queries = true,
    request = true
  }
})
