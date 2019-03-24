require "kemal"
require "json"
require "sqlite3"
require "crecto"
require "./model/*"

module MyRepo
    extend Crecto::Repo

    config do |conf|
        conf.adapter = Crecto::Adapters::SQLite3
        conf.database = "my_database.db"
    end
end

get "/" do
	oyun = Oyun.new
	oyun.ad = "cCc"
	changeset = MyRepo.insert(oyun)
	changeset.errors.any?
	changeset.valid?

	res = OyunApiRes.new oyun.ad
	res.parse
end

alias JValue   = String | Int32 | Bool | Nil | Array(JValue) | Hash(String, JValue)

get "/d" do
	#hash = Hash(String, JValue).new()
	#hash["kod"] = "cCc"
	#hash["hatalar"] = Array(JValue).new()
	#hash["hatalar"] << {"code" => "hata_null", "message" => "ss"}
	#hash["hatalar"] << {"code" => "hata_null", "message" => "dd"}
	#hash.to_json
end

Kemal.run(ENV["PORT"].to_i32.not_nil!)
