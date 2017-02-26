//exec sp_rename syscode_maint, aa_syscode_maint;
//exec sp_rename syscode_maint_detail, aa_syscode_maint_detail;

// ------------------------------------------------------------------------------
// ϵͳ����ά��	-- �ϲ�ԭ��������Ĺ���
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "syscode_maint")
	drop table syscode_maint;
create table syscode_maint
(
	code				char(10)							not null,
   descript   		varchar(40)    				not null,
   descript1  		varchar(60) default ''   	not null,
	wtype				char(10)		default ''		not null,	// �༭����: response, hry, sheet, event-ϵͳ�������¼�
	auth				varchar(20)	default ''		not null,
   show  			text        default ''		not null,	// ��ʾ
   source  			text        default ''		not null,   // �༭
   parm  			text  		default '' 		not null,   // �༭����
	lic				varchar(20)	default ''		not null,
	appid				varchar(20)	default '2'		not null,		// 
   genput  			text        default ''		not null,   // ��ӡ�﷨��һ��ʹ��id=rep!001��Ӧ��auto_report
	genput_wtype				char(3)		default 'tab'		not null,
	genput_show				char(1)		default 'C'		not null,	// �ڱ���ר������ʾ����: C=������� D=������ϸ H=��������
	genput_orientation	char(1)	default '0' not null 
)
exec sp_primarykey syscode_maint,code
create unique index index1 on syscode_maint(code)
;

insert syscode_maint(code, descript) select code, des from aa_syscode_maint;
update syscode_maint set wtype=a.wtype, show=a.show, source=a.source, parm=a.parm 
	from aa_syscode_maint_detail a where syscode_maint.code=a.dept;
update syscode_maint set wtype ='response' where wtype='win';
update syscode_maint set wtype ='sheet' where wtype='sht';
update syscode_maint set wtype ='event' where wtype='evt';

