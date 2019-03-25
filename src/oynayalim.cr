require "kemal"
require "json"
require "mysql"
require "crecto"
require "uuid"
require "./model/*"

module MyRepo
    extend Crecto::Repo

    config do |conf|
        conf.adapter = Crecto::Adapters::Mysql
		conf.uri = ENV["JAWSDB_URL"].not_nil!
    end
end

Query = Crecto::Repo::Query

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

	#query = Query.new
	#query = query.where(ad: "cCc").limit(1)
	#queryres = Repo.all(Oyun, query)

	oyunq = Query.new
	oyunq = oyunq.where(ad: ad).where(uuid: env.get("uuid")).limit(1)
	oyun = Repo.all(Oyun, oyunq)

	if oyun
		res = OyunApiRes.new oyun.ad.not_nil!, oyun.bitti.not_nil!
		res.parse
	else
		res = EksikRes.new
		res.addeksik("cCc", "lol")
		res.parse
	end
end

post "/oyun" do |env|
	ad = env.params.json["ad"].as(String)
    #bitti = env.params.json["bitti"].as(Bool)

	oyun = Oyun.new
	oyun.ad = ad
	oyun.bitti = false
	oyun.uuid = env.get "uuid"
	changeset = MyRepo.insert(oyun)
	changeset.errors.any?
	changeset.valid?

	if oyun
		res = OyunApiRes.new oyun.ad.not_nil!, oyun.bitti.not_nil!
		res.parse
	else
		res = EksikRes.new
		res.addeksik("cCc", "lol")
		res.parse
	end
end

post "/oyun/skor" do |env|
	ad = env.params.json["ad"].as(String)
	skor1 = env.params.json["skor1"].as(String)
	skor2 = env.params.json["skor2"].as(String)
	skor3 = env.params.json["skor3"].as(String)
	skor4 = env.params.json["skor4"].as(String)

	oyunq = Query.new
	oyunq = oyunq.where(ad: ad).where(uuid: env.get("uuid")).limit(1)
	oyun = Repo.all(Oyun, oyunq)

	if oyun
		el = El.new
		el.skor1 = skor1
		el.skor2 = skor2
		el.skor3 = skor3
		el.skor4 = skor4
		el.oyun = oyun.not_nil!

		changeset = MyRepo.insert(el)
		changeset.errors.any?
		changeset.valid?
	end

	if el
		res = ElApiRes.new el.skor1.not_nil!, el.skor2.not_nil!, el.skor3.not_nil!, el.skor4.not_nil!
		res.parse
	else
		res = EksikRes.new
		res.addeksik("cCc", "lol")
		res.parse
	end
end

put "/oyun" do |env|

end

Kemal.run(ENV["PORT"].to_i32.not_nil!)
