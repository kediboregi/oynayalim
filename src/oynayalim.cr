require "kemal"
require "json"
require "uuid"

#if ENV["JAWSDB_URL"]
	#dburl = ENV["JAWSDB_URL"].not_nil!
#else
	dburl = "mysql://oynayalim:194575322@localhost:3306/oynayalim"
#end

Granite::Adapters << Granite::Adapter::Mysql.new({name: "mysql", url: dburl.not_nil!})


require "granite/adapter/mysql"
require "./model/*"

class CorsHandler < Kemal::Handler
	def call(env)
		env.response.headers["Access-Control-Allow-Origin"] = "*"
		env.response.headers["Access-Control-Allow-Credentials"] = "true"
		env.response.headers["Access-Control-Allow-Methods"] = "HEAD, GET, PUT, POST, DELETE, OPTIONS"
		env.response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Origin, Content-Type, Cache-Control, Accept, accesstoken"
		return call_next(env)
	end
end

class AuthHandler < Kemal::Handler
	only ["/oyunlar"]

	def call(env)
		return call_next(env) unless only_match?(env)

		id = env.request.headers["accessToken"]?

		if id
			env.set "logged", true
			env.set "uuid", id.not_nil!
			return call_next(env)
		else
			#env.set "logged", false
			{"status" => "error", "message" => "not_logged"}.to_json
		end
	end

end

add_handler CorsHandler.new
add_handler AuthHandler.new


#before_all do |env|
#	id = env.request.headers["accessToken"]?
#
#	if id
#		env.set "logged", true
#		env.set "uuid", id.not_nil!
#	else
#		env.set "logged", false
#	end
#end

get "/" do |env|
	#env.redirect "index.html"
end

get "/login" do |env|
	id = UUID.random.to_s
	env.response.headers["accessToken"] = id
	{"accessToken" => id}.to_json
end

options "/oyunlar" do |env|

end

get "/oyunlar" do |env|
	if env.get("logged")
		uuid = env.get("uuid").as(String).not_nil!

		oyunlar = Oyun.all("WHERE user_uuid = ? ORDER BY created_at DESC", [uuid])

		if oyunlar
			res = Set(Hash(String, Int64 | Bool | Granite::AssociationCollection(Oyun, El) | String | Nil) | Oyun).new
			oyunlar.each do |oyun|
				#res << oyun
				res << {"id" => oyun.id, "ad" => oyun.ad, "bitti" => oyun.bitti, "user_uuid" => oyun.user_uuid, "eller" => oyun.eller}
			end
			res.to_json
		else
			{"status" => "error", "message" => "not_found"}.to_json
		end
	else
		{"status" => "error", "message" => "not_logged"}.to_json
	end
end

get "/oyunlar/:id" do |env|
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
options "/oyun" do |env|

end
post "/oyunlar" do |env|
	ad = env.params.json["ad"].as(String)
    #bitti = env.params.json["bitti"].as(Bool)

	oyun = Oyun.new
	oyun.ad = ad
	oyun.bitti = false
	oyun.user_uuid = env.get("uuid").as(String).not_nil!

	if oyun.save
		oyun.to_json
	else
		env.response.status_code = 400
	end
end

post "/oyunlar/skor/:id" do |env|
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
			oyun.to_json
		else
			env.response.status_code = 400
		end
	else
		env.response.status_code = 400
	end
end

put "/oyunlar/:id" do |env|
	id = env.params.url["id"].to_i64
	ad = env.params.json["ad"].as(String)

	oyun = Oyun.find_by(id: id, user_uuid: env.get("uuid"))

	if oyun
		oyun.ad = ad

		if oyun.save
			oyun.to_json
		else
			env.response.status_code = 401
		end
	end
end

delete "/oyunlar/:id" do |env|
	id = env.params.url["id"].to_i64

	oyun = Oyun.find_by(id: id, user_uuid: env.get("uuid"))

	if oyun
		if oyun.destroy
			{"status" => "success", "message" => "deleted"}.to_json
		else
			{"status" => "error", "message" => "not_deleted"}.to_json
		end
	else
		{"status" => "error", "message" => "not_found"}.to_json
	end
end

#Kemal.run(ENV["PORT"].to_i32.not_nil!)
Kemal.run(8081)
