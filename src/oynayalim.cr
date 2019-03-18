require "kemal"

get "/" do
  "Hello World!"
end

Kemal.run(ENV["PORT"].to_i32.not_nil!)
