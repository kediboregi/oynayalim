require "kemal"
require "json"
require "uuid"

Granite::Adapters << Granite::Adapter::Mysql.new({name: "mysql", url: ENV["JAWSDB_URL"].not_nil!})

require "granite/adapter/mysql"
require "./model/*"


before_all do |env|
	id = env.request.headers["accessToken"]?

	if id
		env.set "logged", true
		env.set "uuid", id.not_nil!
	else
		env.set "logged", false
	end
end

get "/" do |env|

end

get "/login" do |env|
	id = UUID.random.to_s
	env.response.headers["accessToken"] = id
	{"accessToken" => id}.to_json
end

get "/oyunlar" do |env|
	uuid = env.get("uuid")

	oyunlar = Oyun.find_by(user_uuid: env.get("uuid").as(String).not_nil!)

	if oyunlar
		oyunlar.to_json
	else
		{"status" => "error", "message" => "not_found"}.to_json
	end
end

get "/oyun/:id" do |env|
	id = env.params.url["id"].to_i64
	#ad = env.params.url["ad"].as(String)
	uuid = env.get("uuid")

	oyun = Oyun.find_by(id: id, user_uuid: env.get("uuid").as(String).not_nil!)

	if oyun
		{"ad" => oyun.ad, "bitti" => oyun.bitti, "user_uuid" => oyun.user_uuid, "eller" => oyun.eller}.to_json
	else
		{"status" => "error", "message" => "not_found"}.to_json
	end
end

post "/oyun" do |env|
	ad = env.params.json["ad"].as(String)
    #bitti = env.params.json["bitti"].as(Bool)

	oyun = Oyun.new
	oyun.ad = ad
	oyun.bitti = false
	oyun.user_uuid = env.get("uuid").as(String).not_nil!

	if oyun.save
		env.response.status_code = 201
		oyun.to_json
	else
		env.response.status_code = 400
	end
end

post "/oyun/skor/:id" do |env|
	id = env.params.url["id"].to_i64
	#ad = env.params.json["ad"].as(String)
	skor1 = env.params.json["skor1"].as(String)
	skor2 = env.params.json["skor2"].as(String)
	skor3 = env.params.json["skor3"].as(String)
	skor4 = env.params.json["skor4"].as(String)

	oyun = Oyun.find_by(id: id, user_uuid: env.get("uuid"))

	if oyun
		el = El.new
		el.skor1 = skor1
		el.skor2 = skor2
		el.skor3 = skor3
		el.skor4 = skor4
		el.oyun = oyun

		if el.save
			env.response.status_code = 201
			oyun.to_json
		else
			env.response.status_code = 400
		end
	else
		env.response.status_code = 400
	end
end

put "/oyun/:id" do |env|
	id = env.params.url["id"].to_i64
	ad = env.params.json["ad"].as(String)

	oyun = Oyun.find_by(id: id, user_uuid: env.get("uuid"))

	if oyun
		oyun.ad = ad

		if oyun.save
			env.response.status_code = 201
			oyun.to_json
		else
			env.response.status_code = 401
		end
	end
end

Kemal.run(ENV["PORT"].to_i32.not_nil!)
