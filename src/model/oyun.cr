class Oyun < Crecto::Model
    schema "oyunlar" do
        field :ad, String
		field :bitti, Bool
    end
end

class EksikRes
	def initialize()
		@eksikler =  Array(Hash(String, String | Int32).new)
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
