require "kemal"
require "json"
require "uuid"
require "CrSerializer"
require "granite/adapter/mysql"

begin
	dburl = ENV["JAWSDB_URL"].not_nil!
rescue
	dburl = "mysql://oynayalim:194575322@localhost:3306/oynayalim"
end

Granite::Adapters << Granite::Adapter::Mysql.new({name: "mysql", url: dburl.not_nil!})

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
	only ["/oyunlar"], "GET"
	only ["/oyun/:id/"], "GET"
	only ["/oyun"], "POST"
	only ["/oyun"], "PUT"
	only ["/oyun/:id/"], "DELETE"
	only ["/oyun/oyuncu"], "POST"
	only ["/oyun/oyuncu/:id/"], "DELETE"
	only ["/oyun/skor"], "POST"
	only ["/oyun/skor"], "DELETE"

	def call(env)
		#pp env
		return call_next(env) unless only_match?(env)

		if only_match?(env)
			puts "ccc"
		end

		id = env.request.headers["accessToken"]?
		begin
			uuid = UUID.new(id.not_nil!).v4?
		rescue
			uuid = false
		end

		if id && uuid
			env.set "logged", true
			env.set "uuid", id.not_nil!
			call_next(env)
		else
			env.set "logged", false
			{"status" => "error", "message" => "not_logged"}.to_json
		end
	end

end

add_handler CorsHandler.new
add_handler AuthHandler.new

#before_all "/oyunlar" do |env|
#	id = env.request.headers["accessToken"]?
#
#	if id
#		env.set "logged", true
#		env.set "uuid", id.not_nil!
#	else
#		#env.set "logged", false
#		{"status" => "error", "message" => "not_logged"}.to_json
#	end
#end

get "/" do |env|
	#env.redirect "index.html"
end

get "/login" do |env|
	id = UUID.random.to_s
	puts id
	env.response.headers["accessToken"] = id
	{"accessToken" => id}.to_json
end

options "/oyunlar/" do |env|
end

get "/oyunlar" do |env|
	if env.get("logged")
		uuid = env.get("uuid").as(String).not_nil!

		oyunlar = Oyun.all("WHERE user_uuid = ? ORDER BY created_at DESC", [uuid])

		if oyunlar
			oyunlar.to_json
		else
			{"status" => "error", "message" => "not_found"}.to_json
		end
	else
		{"status" => "error", "message" => "not_logged"}.to_json
	end
end

options "/oyun/:id/" do |env|
end

get "/oyun/:id/" do |env|
	id = env.params.url["id"].to_i64
	uuid = env.get("uuid")

	oyun = Oyun.find_by(id: id, user_uuid: env.get("uuid").as(String).not_nil!)

	if oyun
		oyun.to_json
	else
		{"status" => "error", "message" => "not_found"}.to_json
	end
end

options "/oyun" do |env|
end

post "/oyun" do |env|
	ad = env.params.json["ad"].as(String)

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

put "/oyun" do |env|
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

delete "/oyun/:id/" do |env|
	id = env.params.url["id"].to_i64

	oyun = Oyun.find_by(id: id, user_uuid: env.get("uuid"))

	if oyun
		oid = oyun.id
		if oyun.destroy
			{"id" => oid, "status" => "success", "message" => "deleted"}.to_json
		else
			{"status" => "error", "message" => "not_deleted"}.to_json
		end
	else
		{"status" => "error", "message" => "not_found"}.to_json
	end
end

options "/oyun/oyuncu" do |env|
end

post "/oyun/oyuncu" do |env|
	oyunid = env.params.json["oyun_id"].as(Int64)
	ad = env.params.json["ad"].as(String)

	oyun = Oyun.find_by(id: oyunid, user_uuid: env.get("uuid"))

	if oyun
		oyuncu = Oyuncu.new
		oyuncu.ad = ad
		oyuncu.oyun = oyun

		if oyuncu.save
			oyuncu.to_json
		else
			env.response.status_code = 400
		end
	else
		env.response.status_code = 400
	end
end

options "/oyun/skor" do |env|
end

post "/oyun/skor" do |env|
	oyunid = env.params.json["oyun_id"].as(Int64)
	oyuncuid = env.params.json["oyuncu_id"].as(Int64)
	#sira = env.params.json["sira"].as(Int64)
	sira : Int64 = 0
	deger = env.params.json["deger"].as(Int64)

	oyun = Oyun.find_by(id: oyunid, user_uuid: env.get("uuid"))

	if oyun

		oyuncu = Oyuncu.find_by(oyun_id: oyun.id, id: oyuncuid)

		if oyuncu
			sonsira = Skor.first("WHERE oyuncu_id = ? ORDER BY sira DESC", [oyuncu.id])

			if sonsira
				sira = sonsira.sira.not_nil! + 1
			end

			skor = Skor.new
			skor.sira = sira
			skor.deger = deger
			skor.oyuncu = oyuncu

			if skor.save
				skor.to_json
			else
				env.response.status_code = 400
			end
		else
			env.response.status_code = 400
		end
	else
		env.response.status_code = 400
	end
end

delete "/oyun/skor" do |env|
	id = env.params.json["id"].as(Int64)

	skor = Skor.find_by(id: id)

	if skor && skor.oyuncu.oyun.user_uuid == env.get("uuid")
		if skor.destroy
			{"id" => skor.id, "status" => "success", "message" => "deleted"}.to_json
		else
			{"status" => "error", "message" => "not_deleted"}.to_json
		end
	else
		{"status" => "error", "message" => "not_found"}.to_json
	end
end

begin
	Kemal.run(ENV["PORT"].to_i32.not_nil!)
rescue
	Kemal.run(8081)
end
