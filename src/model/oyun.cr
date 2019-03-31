class Oyun < Granite::Base
	adapter mysql
	table_name oyuns
	field ad : String
	field bitti : Bool
	field user_uuid : String
	timestamps

	has_many eller : El
end

class El < Granite::Base
	adapter mysql
	table_name els
	field skor1 : String
	field skor2 : String
	field skor3 : String
	field skor4 : String
	timestamps

	belongs_to oyun : Oyun
end

class OyunApiRes
	def initialize(oyun : Oyun)
		@oyun = oyun
	end

	def ad
		@ad
	end

	def bitti
		@ad
	end

	def parse
		res = {"ad" => @oyun.ad, "bitti" => @oyun.bitti, "eller" => @oyun.eller}
		res.to_json
	end
end

class ElApiRes
	def initialize(skor1 : String, skor2 : String, skor3 : String, skor4 : String)
		@skor1 = skor1
		@skor2 = skor2
		@skor3 = skor3
		@skor4 = skor4
	end

	def parse
		res = {"skor1" => @skor1, "skor2" => @skor2, "skor3" => @skor3, "skor4" => @skor4}
		res.to_json
	end
end
