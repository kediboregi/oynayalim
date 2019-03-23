require "kemal"
require "json"

get "/" do
	uyeler = [{ad: "ss"}, {ad: "dd"}]
	hashd = {} of String => JSON::Any
	hashd["cCc"] = "hata"
	hashd["uyeler"] = uyeler
	hashd.to_json
end

Kemal.run(ENV["PORT"].to_i32.not_nil!)
