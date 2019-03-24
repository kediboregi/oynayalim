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

	def to_json
		@ad.to_json
	end
end
