require "kemal"
require "jennifer"
require "jennifer/adapter/mysql"
require "json"
require "uuid"
require "./model/*"

Jennifer::Config.from_uri(ENV["JAWSDB_URL"].not_nil!)

before_all do |env|
	id = env.request.cookies["uuid"]?.try &.value
	if id.nil?
		#id = Random::Secure.hex
		id = UUID.random.to_s
		cook = HTTP::Cookie.new(name: "uuid", value: id, expires: Time.now + 24.years, secure: true)
		env.request.cookies << cook
		env.response.cookies << cook
	end

	if id
		env.set "uuid", id.not_nil!
	end
end

get "/" do |env|
	id = env.request.cookies["uuid"]?.try &.value
  	{"uuid" => id}.to_json
end

get "/oyun/:ad" do |env|
	ad = env.params.url["ad"].as(String)
	uuid = env.get("uuid")
	oyun = Oyun.where { _ad == ad & (_user_uuid == uuid) }.first

	if oyun
		eller = El.where { _oyun_id == oyun.id }.first

		res = OyunApiRes.new oyun.ad.not_nil!, oyun.bitti.not_nil!
		res.parse
	else

	end
end

post "/oyun" do |env|
	ad = env.params.json["ad"].as(String)
    #bitti = env.params.json["bitti"].as(Bool)

	oyun = Oyun.build({:ad => ad, :bitti => false, :user_uuid => env.get "uuid"})

	if oyun.save
		res = OyunApiRes.new oyun.ad.not_nil!, oyun.bitti.not_nil!
		res.parse
	else

	end
end

post "/oyun/skor" do |env|
	ad = env.params.json["ad"].as(String)
	skor1 = env.params.json["skor1"].as(String)
	skor2 = env.params.json["skor2"].as(String)
	skor3 = env.params.json["skor3"].as(String)
	skor4 = env.params.json["skor4"].as(String)

	oyun = Oyun.where { _ad == ad }.first

	if oyun
		el = El.build({:skor1 => skor1, :skor2 => skor2, :skor3 => skor3, :skor4 => skor4, :oyun_id => oyun.id})

		if el.save
			res = ElApiRes.new el.skor1.not_nil!, el.skor2.not_nil!, el.skor3.not_nil!, el.skor4.not_nil!
			res.parse
		else

		end
	end
end

put "/oyun" do |env|

end

Kemal.run(ENV["PORT"].to_i32.not_nil!)
