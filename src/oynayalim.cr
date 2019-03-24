require "kemal"
require "json"
require "mysql"
require "crecto"
require "./model/*"

module MyRepo
    extend Crecto::Repo

    config do |conf|
        conf.adapter = Crecto::Adapters::Mysql
		conf.uri = ENV["JAWSDB_URL"].not_nil!
    end
end

get "/" do
	oyun = Oyun.new
	oyun.ad = "cCc"
	changeset = MyRepo.insert(oyun)
	changeset.errors.any?
	changeset.valid?

	res = OyunApiRes.new oyun.ad.not_nil!
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
