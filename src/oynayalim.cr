require "kemal"
require "json"

class ResponseWrapper(T)
	JSON.mapping(
		code: Int32?,
		status: String?,
		data: Container(T)?
	)
end

class Container(T)
	JSON.mapping(
		offset: Int32?,
        limit: Int32?,
        total: Int32?,
        count: Int32?,
		results: Array(T)
	)
end

class Character
	JSON.mapping(id: Int32?, name: String?)
end

class Comic
	JSON.mapping(id: Int32?, title: String?)
end

class MissingParameters
	JSON.mapping(code: String, parameters: Array(Parameter?))
end

class Parameter
	JSON.mapping(code: String, message: String)
end

alias ComicResponse = ResponseWrapper(Comic) | MissingParameters
alias CharacterResponse = ResponseWrapper(Character) | MissingParameters

get "/" do
	req = ComicResponse.from_json(%({"status": "cCc", "data": {"offset": 5, "limit": 1, "total": 20, "count": 100, "results": [{"id": 1, "title": "sss"}, {"id": 2, "title": "ddd"}]}}))
	req.to_json
end

alias JValue   = String | Int32 | Bool | Nil | Array(JValue) | Hash(String, JValue)
alias KeyValue = {String, JValue}

get "/d" do
	hash = KeyValue.new
	hash["kod"] = "cCc"
	#hash["hatalar"] = Array(Parameter).new
	hash["hatalar"] << {"code" => "hata_null", "message" => "ss"}
	hash["hatalar"] << {"code" => "hata_null", "message" => "dd"}
	#req = ComicResponse.from_json(%({"code": "hata_null"))
	hash.to_json
end

Kemal.run(ENV["PORT"].to_i32.not_nil!)
