require "kemal"

get "/" do
  "Hello World!"
end

Kemal.run(ENV["PORT"].not_nil!)
