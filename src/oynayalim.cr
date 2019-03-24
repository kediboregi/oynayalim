require "kemal"
require "session"
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

session_handler = Session::Handler(Hash(String, String)).new(session_key: "cCc", secret: "cCc32132ananzaaxd3823")
add_handler session_handler

before_all do |req|
	req.session["ilk_giris"] ||= Time.now.to_s
	req.session["uuid"] ||= UUID.random.to_s
	{"ilk_giris" => req.session["ilk_giris"], "uuid" => req.session["uuid"]}.to_json
end

get "/oyun" do |req|
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

post "/oyun" do |req|
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
