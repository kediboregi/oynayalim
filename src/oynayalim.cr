require "kemal"
require "json"

class ResponseWrapper(T)
      JSON.mapping(code: Int32?,
        status: String?,
        data: Container(T)?)
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

class MissingParameter
  JSON.mapping(code: String, message: String)
end

alias ComicRequest = ResponseWrapper(Comic) | MissingParameter
alias CharacterRequest = ResponseWrapper(CharacterRequest) | MissingParameter

get "/" do
	req = ComicRequest.from_json(%({"status": "cCc", "data": {"offset": 5, "limit": 1, "total": 20, "count": 100, "results": [{"id": 1, "title": "sss"}, {"id": 2, "title": "ddd"}]}}))
	#uyeler = [{"ad" => "ss"}, {"ad" => "dd"}]
	#hashd = {} of String => JSON::Any::Type
	#hashd["cCc"] = "hata"
	#hashd["uyeler"] = []
	#hashd.to_json
	req.to_json
end

Kemal.run(ENV["PORT"].to_i32.not_nil!)
