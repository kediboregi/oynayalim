class Oyun < Crecto::Model
    schema "oyunlar" do
        field :ad, String
		field :bitti, Bool
        field :uuid, String
		has_many :eller, El
    end
end

class El < Crecto::Model
    schema "eller" do
        field :skor1, String
		field :skor2, String
		field :skor3, String
		field :skor4, String
		belongs_to :oyun, Oyun
    end
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
