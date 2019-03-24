class Oyun < Crecto::Model
    schema "oyunlar" do
        field :ad, String
    end
end

class OyunApiRes
	def initialize(ad : String)
		@ad = ad
	end

	def ad
		@ad
	end

	def parse
		{"ad" => @ad}.to_json
	end
end
