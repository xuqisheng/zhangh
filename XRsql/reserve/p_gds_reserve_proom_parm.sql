

-- �ù��̲����ˣ��ٷ�����ʹ�� 


if exists(select * from sysobjects where name = "p_gds_reserve_proom_parm")
	drop proc p_gds_reserve_proom_parm
;
//create proc p_gds_reserve_proom_parm
//	@accnt				char(10),
//	@retmode				char(1) = 'S',
//	@pmuse				char(1)	output,  -- �Ƿ����� �ٷ�����
//	@pmtype				char(5)	output,  -- PM �ٷ���
//	@msg					varchar(60)	output
//as
//--------------------------------------------------------------------------------------
//--	Pseudo Rooms Parms �ٷ� ����
//--  ��� @accnt �ǿգ�ͬʱ�жϸ��ʻ��Ƿ����Ӧ�� �ٷ� 
//--------------------------------------------------------------------------------------
//declare	@ret 			int,
//			@type			char(5),
//			@class		char(1), 
//			@sc			char(1)
//
//--
//select @sc='F'
//if rtrim(@msg) is null
//	select @msg=''
//else if substring(@msg, 1, 3) = 'sc!'
//	select @sc='T', @msg=isnull(ltrim(stuff(@msg, 1, 3, '')), '')
//
//select @ret=0, @pmuse='F', @pmtype = '', @msg = ''
//
//-- �Ƿ�Ӧ�� �ٷ� 
//select @pmuse = substring(ltrim(rtrim(value)), 1, 1) from sysoption where catalog='hotel' and item='proom_inst' 
//if @@rowcount = 0 or @pmuse is null or charindex(@pmuse, 'TtYy')=0 
//	select @pmuse = 'F', @pmtype=''
//else
//begin
//	select @pmuse = 'T'
//	select @pmtype = isnull((select substring(ltrim(rtrim(value)), 1, 3) from sysoption where catalog='hotel' and item='proom_pm'), '')  
//	if not exists(select 1 from typim where type=@pmtype and tag='P') 
//		select @pmtype = '', @ret = 1, @msg='��ϵͳ����Ա���üٷ� - PM'
//end
//
//if @ret=0 and rtrim(@accnt) is not null
//begin
//	if @accnt like 'A%' 
//		select @ret=1, @msg='���˻��������ÿͷ���Ϣ'
//	else
//	begin
//		if @sc='F'
//			select @class=class, @type=type from master where accnt=@accnt 
//		else
//			select @class=class, @type=type from sc_master where accnt=@accnt 
//		if @@rowcount = 0 
//			select @ret=1, @msg='%1������^�˻�'
//		else
//		begin
//			if @pmuse = 'T'
//			begin
//				if charindex(@class, 'GMC')>0 
//				begin
//					if rtrim(@type) is null or @type<>@pmtype 
//						select @ret = 1, @msg='��ʹ�� PM ����'
//				end
//			end
//			else
//			begin
//				if @class <> 'F'
//					select @ret=1, @msg='���˻��������ÿͷ���Ϣ'
//			end
//		end
//	end
//end
//
//if @retmode = 'S'
//	select @pmuse, @pmtype, @msg 
//
//return @ret;