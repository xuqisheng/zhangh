-- �ƺ�û������  simon 

IF OBJECT_ID('p_wz_reserve_descript_build') IS NOT NULL
    DROP PROCEDURE p_wz_reserve_descript_build
;
//create proc p_wz_reserve_descript_build
//			@accnt 		char(10),
//			@mode			char(1),  --Q:q_room   R:search room and report room
//			@langid		integer
//as
//declare
//		@resno			char(10),
//		@restype			char(3),
//		@restype_des	varchar(30),
//		@roomno			char(4),
//		@type				char(3),
//		@market			char(3),
//		@market_des    varchar(30),
//		@srccode			char(3),
//		@srccode_des	varchar(30),
//		@channel			char(3),
//		@channel_des	varchar(30),
//		@srqs				varchar(30),
//		@srqs_des		varchar(100),
//		@amenities		varchar(30),
//		@amenities_des varchar(100),
//		@cusno			char(7),
//		@agent			char(7),
//		@source			char(7),
//		@no				char(7),
//		@no_name			varchar(30),
//		@arr				datetime,
//		@dep				datetime,
//		@haccnt			char(7),
//		@name				varchar(20),
//		@nation			char(3),
//		@ratecode		char(10),
//		@ratecode_des  varchar(20),
//		@idcls			char(3),
//		@idcls_des		varchar(20),
//		@ident			varchar(20),
//		@mobile			varchar(20),
//		@vip				char(1),
//		@vip_des 		varchar(20)
//
//
//create table #woutput
//(	 des		varchar(100)  null
//)
//
//
//--if @mode = 'Q' is q_room descript
//if @mode = 'Q'
//begin
//	select @haccnt = haccnt,@type = type,@roomno = roomno ,
//		@resno = resno ,@ratecode = ratecode,@market = market,@srccode = src,@restype = restype,@channel = channel,
//		@srqs = srqs,@amenities = amenities,@cusno = cusno,@agent = agent,@source = source,	@arr = arr, @dep = dep
//	from master where accnt = @accnt
//	if @langid = 0
//	begin
//		select @ratecode_des = descript from rmratecode where code = @ratecode
//		select @name = name ,@nation = nation,@idcls = idcls,@ident = ident,@mobile=mobile,@vip = vip from guest where no= @haccnt
//		select @restype_des = descript from restype where code = @restype
//		select @idcls_des = descript from basecode where cat = 'idcode' and code = @idcls
//		select @vip_des = descript from basecode where cat = 'vip' and code = @vip
//		if ltrim(@cusno) is not null
//			select @no = @cusno,@no_name = 'Э�鵥λ:'
//		else if ltrim(@agent) is not null
//			select @no = @agent,@no_name = '������:'
//		else if ltrim(@source) is not null
//			select @no = @source,@no_name = '��������:'
//		select @no_name = @no_name + name from guest where no = @no
//
//		select @market_des = descript from mktcode where code = @market
//		select @srccode_des = descript from srccode where code = @srccode
//
//
//		exec p_wz_reserve_codes_splits @srqs,'srqs',@srqs_des out,0
//		exec p_wz_reserve_codes_splits @amenities,'amenities',@amenities_des out,0
//
//		insert #woutput select '�ʺ�:' + @accnt
//		insert #woutput select 'Ԥ����:'+@resno+ space(5) + 'Ԥ������:'+@restype_des
//		insert #woutput select '����:' + @roomno + space(5) + '����:' +@type+space(5)+'������:'+@ratecode_des + '('+ rtrim(@ratecode) + ')'
//		insert #woutput select '�г���:'+@market_des+'('+@market+')' +space(5) + '��Դ��:' + @srccode_des  +'(' + @srccode+')'
//		insert #woutput select '����:' + @name + space(5) + '����:' + @nation
//		if ltrim(@vip) is not null and @vip <> '0'
//			insert #woutput select 'VIP:' +@vip_des + '(' +@vip+')'
//		if ltrim(@mobile) is not null
//			insert #woutput select '�ֻ�����:' + @mobile
//		if ltrim(@idcls) is not null or ltrim(@ident) is not null
//			insert #woutput select '֤������:'+@idcls_des + '(' +@idcls+ ')' + space(5) + '֤������:' + @ident
//		if ltrim(@no_name) is not null
//			insert #woutput select  @no_name
//		insert #woutput select '����:' + convert(char(10),@arr,111) + '  ====�� ' + convert(char(10),@dep,111)
//		if ltrim(@srqs_des) is not null
//			insert #woutput select '����Ҫ��:'+@srqs_des
//		if ltrim(@amenities_des) is not null
//			insert #woutput select '�ͷ�����:'+@amenities_des
//	end
//	else
//	begin
//		select @ratecode_des = descript1 from rmratecode where code = @ratecode
//		select @name = name ,@nation = nation,@idcls = idcls,@ident = ident,@mobile=mobile,@vip = vip from guest where no= @haccnt
//		select @restype_des = descript1 from restype where code = @restype
//		select @idcls_des = descript1 from basecode where cat = 'idcode' and code = @idcls
//		select @vip_des = descript1 from basecode where cat = 'vip' and code = @vip
//		if ltrim(@cusno) is not null
//			select @no = @cusno,@no_name = 'Cusno:'
//		else if ltrim(@agent) is not null
//			select @no = @agent,@no_name = 'Agent:'
//		else if ltrim(@source) is not null
//			select @no = @source,@no_name = 'Source:'
//		select @no_name = @no_name + name from guest where no = @no
//
//		select @market_des = descript1 from mktcode where code = @market
//		select @srccode_des = descript1 from srccode where code = @srccode
//
//
//		exec p_wz_reserve_codes_splits @srqs,'srqs',@srqs_des out,0
//		exec p_wz_reserve_codes_splits @amenities,'amenities',@amenities_des out,0
//
//		insert #woutput select 'Account No:' + @accnt
//		insert #woutput select 'Reserve No:'+@resno+ space(5) + 'Reserve Type:'+@restype_des
//		insert #woutput select 'Room No:' + @roomno + space(5) + 'Room Type:' +@type+space(5)+'Ratecode:'+@ratecode_des + '('+ rtrim(@ratecode) + ')'
//		insert #woutput select 'Market code'+@market_des+'('+@market+')' +space(5) + 'source code:' + @srccode_des  +'(' + @srccode+')'
//		insert #woutput select 'Name:' + @name + space(5) + 'Nation:' + @nation
//		if ltrim(@vip) is not null and @vip <> '0'
//			insert #woutput select 'VIP:' +@vip_des + '(' +@vip+')'
//		if ltrim(@mobile) is not null
//			insert #woutput select 'Mobile:' + @mobile
//		if ltrim(@idcls) is not null or ltrim(@ident) is not null
//			insert #woutput select 'Document Type:'+@idcls_des + '(' +@idcls+ ')' + space(5) + 'Document No:' + @ident
//		if ltrim(@no_name) is not null
//			insert #woutput select  @no_name
//		insert #woutput select 'Arrival-->Departure:' + convert(char(10),@arr,111) + '  --> ' + convert(char(10),@dep,111)
//		if ltrim(@srqs_des) is not null
//			insert #woutput select 'Sepcial Request:'+@srqs_des
//		if ltrim(@amenities_des) is not null
//			insert #woutput select 'Room Laying-Out:'+@amenities_des
//	end
//end
//else if @mode = 'R'
//begin
//	select @haccnt = haccnt,@type = type,@roomno = roomno ,
//		@resno = resno ,@ratecode = ratecode,@market = market,@srccode = src,@restype = restype,@channel = channel,
//		@srqs = srqs,@amenities = amenities,@cusno = cusno,@agent = agent,@source = source,	@arr = arr, @dep = dep
//	from master where accnt = @accnt
//	if @@rowcount <> 0
//	begin
//		if @langid = 0
//		begin
//			select @ratecode_des = descript from rmratecode where code = @ratecode
//			select @name = name ,@nation = nation,@idcls = idcls,@ident = ident,@mobile=mobile,@vip = vip from guest where no= @haccnt
//			select @restype_des = descript from restype where code = @restype
//			select @idcls_des = descript from basecode where cat = 'idcode' and code = @idcls
//			select @vip_des = descript from basecode where cat = 'vip' and code = @vip
//			if ltrim(@cusno) is not null
//				select @no = @cusno,@no_name = 'Э�鵥λ:'
//			else if ltrim(@agent) is not null
//				select @no = @agent,@no_name = '������:'
//			else if ltrim(@source) is not null
//				select @no = @source,@no_name = '��������:'
//			select @no_name = @no_name + name from guest where no = @no
//
//			select @market_des = descript from mktcode where code = @market
//			select @srccode_des = descript from srccode where code = @srccode
//
//
//			exec p_wz_reserve_codes_splits @srqs,'srqs',@srqs_des out,0
//			exec p_wz_reserve_codes_splits @amenities,'amenities',@amenities_des out,0
//
//			insert #woutput select '�ʺ�:' + @accnt
//			insert #woutput select 'Ԥ����:'+@resno+ space(5) + 'Ԥ������:'+@restype_des
//			insert #woutput select '����:' + @roomno + space(5) + '����:' +@type+space(5)+'������:'+@ratecode_des + '('+ rtrim(@ratecode) + ')'
//			insert #woutput select '�г���'+@market_des+'('+@market+')' +space(5) + '��Դ��:' + @srccode_des  +'(' + @srccode+')'
//			insert #woutput select '����:' + @name + space(5) + '����:' + @nation
//			if ltrim(@vip) is not null and @vip <> '0'
//				insert #woutput select 'VIP:' +@vip_des + '(' +@vip+')'
//			if ltrim(@mobile) is not null
//				insert #woutput select '�ֻ�����:' + @mobile
//			if ltrim(@idcls) is not null or ltrim(@ident) is not null
//				insert #woutput select '֤������:'+@idcls_des + '(' +@idcls+ ')' + space(5) + '֤������:' + @ident
//			if ltrim(@no_name) is not null
//				insert #woutput select  @no_name
//			insert #woutput select '����:' + convert(char(10),@arr,111) + '  ====�� ' + convert(char(10),@dep,111)
//			if ltrim(@srqs_des) is not null
//				insert #woutput select '����Ҫ��:'+@srqs_des
//			if ltrim(@amenities_des) is not null
//				insert #woutput select '�ͷ�����:'+@amenities_des
//		end
//		else
//		begin
//			select @ratecode_des = descript1 from rmratecode where code = @ratecode
//			select @name = name ,@nation = nation,@idcls = idcls,@ident = ident,@mobile=mobile,@vip = vip from guest where no= @haccnt
//			select @restype_des = descript1 from restype where code = @restype
//			select @idcls_des = descript1 from basecode where cat = 'idcode' and code = @idcls
//			select @vip_des = descript1 from basecode where cat = 'vip' and code = @vip
//			if ltrim(@cusno) is not null
//				select @no = @cusno,@no_name = 'Cusno:'
//			else if ltrim(@agent) is not null
//				select @no = @agent,@no_name = 'Agent:'
//			else if ltrim(@source) is not null
//				select @no = @source,@no_name = 'Source:'
//			select @no_name = @no_name + name from guest where no = @no
//
//			select @market_des = descript1 from mktcode where code = @market
//			select @srccode_des = descript1 from srccode where code = @srccode
//
//
//			exec p_wz_reserve_codes_splits @srqs,'srqs',@srqs_des out,0
//			exec p_wz_reserve_codes_splits @amenities,'amenities',@amenities_des out,0
//
//			insert #woutput select 'Account No:' + @accnt
//			insert #woutput select 'Reserve No:'+@resno+ space(5) + 'Reserve Type:'+@restype_des
//			insert #woutput select 'Room No:' + @roomno + space(5) + 'Room Type:' +@type+space(5)+'Ratecode:'+@ratecode_des + '('+ rtrim(@ratecode) + ')'
//			insert #woutput select 'Market code'+@market_des+'('+@market+')' +space(5) + 'source code:' + @srccode_des  +'(' + @srccode+')'
//			insert #woutput select 'Name:' + @name + space(5) + 'Nation:' + @nation
//			if ltrim(@vip) is not null and @vip <> '0'
//				insert #woutput select 'VIP:' +@vip_des + '(' +@vip+')'
//			if ltrim(@mobile) is not null
//				insert #woutput select 'Mobile:' + @mobile
//			if ltrim(@idcls) is not null or ltrim(@ident) is not null
//				insert #woutput select 'Document Type:'+@idcls_des + '(' +@idcls+ ')' + space(5) + 'Document No:' + @ident
//			if ltrim(@no_name) is not null
//				insert #woutput select  @no_name
//			insert #woutput select 'Arrival-->Departure:' + convert(char(10),@arr,111) + '  --> ' + convert(char(10),@dep,111)
//			if ltrim(@srqs_des) is not null
//				insert #woutput select 'Sepcial Request:'+@srqs_des
//			if ltrim(@amenities_des) is not null
//				insert #woutput select 'Room Laying-Out:'+@amenities_des
//		end
//	end
//end
//
//
//
//select * from #woutput
//
//return 0
//;
//