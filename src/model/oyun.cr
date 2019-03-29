class Oyun < Jennifer::Model::Base
	with_timestamps
	mapping(
		id: Primary32, # same as {type: Int32, primary: true}
	    ad: String,
    	bitti: Int8,
		user_uuid: String,
		created_at: Time?,
		updated_at: Time?
	)

	has_many :eller, El
end

class El < Jennifer::Model::Base
	with_timestamps
	mapping(
		id: Primary32, # same as {type: Int32, primary: true}
	    skor1: String?,
	    skor2: String?,
		skor3: String?,
		skor4: String?,
		oyun_id: Int32?,
		created_at: Time?,
		updated_at: Time?
	)

	belongs_to :oyun, Oyun
end

class EksikRes
	def initialize()
		@eksikler =  Array(Hash(String, String | Int32)).new
	end

	def eksik()
		if @eksikler.size > 0
			true
		else
			false
		end
	end

	def addeksik(ad : String, deger : String)
		@eksikler << {ad => deger}
	end

	def eksikler
		@eksikler
	end

	def parse
		res = {"eksikler" => @eksikler}
		res.to_json
	end
end

class OyunApiRes
	def initialize(ad : String, bitti : Bool)
		@ad = ad
		@bitti = bitti
	end

	def ad
		@ad
	end

	def bitti
		@ad
	end

	def parse
		res = {"ad" => @ad, "bitti" => @bitti}
		res.to_json
	end
end

class ElApiRes
	def initialize(skor1 : String, skor2 : String, skor3 : String, skor4 : String)

	end

	def parse
		res = {"skor1" => @skor1, "skor2" => @skor2, "skor3" => @skor3, "skor4" => @skor4}
		res.to_json
	end
end
