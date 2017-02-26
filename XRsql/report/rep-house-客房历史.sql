/*
报表: 客房历史 

_com_p_客房历史;(select b.descript, a.old, a.new, a.empno, a.date from lgfl a, lgfl_des b where a.accnt='rm:#char05!请输入房号#' and a.date>='#date1!请输入开始日期!#Bdate1##' and a.date<='#date2!请输入结束日期!#Bdate0##' and a.columnname=b.columnname order by a.date);
b.descript:项目=20;a.old:原值=20;a.new:新值=20;a.empno:工号=10;a.date:时间=18=yyyy/mm/dd hh|mm|ss;
headerds=[header=4 summary=1]
sp=p_gl_lgfl 'rmsta', '#char05#'!!! 
texttext=t_title:#hotel#:header:1::b.descript:a.date::border="0" alignment="2" font.height="-12"!
texttext=t_title1:客房历史:header:2::b.descript:a.date::border="0" alignment="2" font.height="-12"!
texttext=t_rmno:房号 #char05#:header:3::b.descript:a.old::alignment="0" border="0"! 
texttext=t_bdate:打印时间 #pdate#:header:3::a.empno:a.date::alignment="0" border="0"! 
texttext=t_sum:房务中心:summary:1::b.descript:b.eccocode::border="0" alignment="0"  font.italic="2"!



*/
