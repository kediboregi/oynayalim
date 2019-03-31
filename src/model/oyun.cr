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
