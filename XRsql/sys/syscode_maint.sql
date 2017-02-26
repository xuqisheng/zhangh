//exec sp_rename syscode_maint, aa_syscode_maint;
//exec sp_rename syscode_maint_detail, aa_syscode_maint_detail;

// ------------------------------------------------------------------------------
// 系统代码维护	-- 合并原来两个表的功能
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "syscode_maint")
	drop table syscode_maint;
create table syscode_maint
(
	code				char(10)							not null,
   descript   		varchar(40)    				not null,
   descript1  		varchar(60) default ''   	not null,
	wtype				char(10)		default ''		not null,	// 编辑类型: response, hry, sheet, event-系统主窗口事件
	auth				varchar(20)	default ''		not null,
   show  			text        default ''		not null,	// 显示
   source  			text        default ''		not null,   // 编辑
   parm  			text  		default '' 		not null,   // 编辑参数
	lic				varchar(20)	default ''		not null,
	appid				varchar(20)	default '2'		not null,		// 
   genput  			text        default ''		not null,   // 打印语法，一般使用id=rep!001对应到auto_report
	genput_wtype				char(3)		default 'tab'		not null,
	genput_show				char(1)		default 'C'		not null,	// 在报表专家中显示类型: C=报表类别 D=报表明细 H=隐藏内容
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

