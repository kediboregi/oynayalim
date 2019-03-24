class Oyun < Crecto::Model
    schema "oyunlar" do
        field :ad, String
    end
end

class ApiRes
	def initialize()
		@eksikler = Nil
	end

	def eksik : Bool
		if @eksikler.nil?
			False
		else
			True
		end
	end

	def eksikler
		@eksikler
	end
end

class OyunApiRes < ApiRes
	def initialize(ad : String, bitti : Bool)
		super
		@ad = ad
		@bitti = bitti
	end

	def ad
		@ad
	end

	def parse
		res = {"ad" => @ad, "bitti" => @bitti}
		if @eksik
			res.merge!({"eksikler" => eksikler})
		end
		res.to_json
	end
end
