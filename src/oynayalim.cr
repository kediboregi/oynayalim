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
		cook = HTTP::Cookie.new(name: "uuid", value: UUID.random.to_s, expires: Time.now + 24.years, secure: true)
		env.request.cookies << cook
		env.response.cookies << cook
	end
end

get "/" do |env|
	id = env.request.cookies["uuid"]?.try &.value
  	{"uuid" => id}.to_json
end

get "/oyun" do |env|
	#query = Query.new
	#query = query.where(ad: "cCc").limit(1)
	#queryres = Repo.all(Oyun, query)

	oyun = MyRepo.get_by(Oyun, ad: "cCc")

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
	oyun = Oyun.new
	oyun.ad = "cCc"
	oyun.bitti = false
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

Kemal.run(ENV["PORT"].to_i32.not_nil!)
