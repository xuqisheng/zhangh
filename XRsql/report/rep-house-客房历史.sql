/*
����: �ͷ���ʷ 

_com_p_�ͷ���ʷ;(select b.descript, a.old, a.new, a.empno, a.date from lgfl a, lgfl_des b where a.accnt='rm:#char05!�����뷿��#' and a.date>='#date1!�����뿪ʼ����!#Bdate1##' and a.date<='#date2!�������������!#Bdate0##' and a.columnname=b.columnname order by a.date);
b.descript:��Ŀ=20;a.old:ԭֵ=20;a.new:��ֵ=20;a.empno:����=10;a.date:ʱ��=18=yyyy/mm/dd hh|mm|ss;
headerds=[header=4 summary=1]
sp=p_gl_lgfl 'rmsta', '#char05#'!!! 
texttext=t_title:#hotel#:header:1::b.descript:a.date::border="0" alignment="2" font.height="-12"!
texttext=t_title1:�ͷ���ʷ:header:2::b.descript:a.date::border="0" alignment="2" font.height="-12"!
texttext=t_rmno:���� #char05#:header:3::b.descript:a.old::alignment="0" border="0"! 
texttext=t_bdate:��ӡʱ�� #pdate#:header:3::a.empno:a.date::alignment="0" border="0"! 
texttext=t_sum:��������:summary:1::b.descript:b.eccocode::border="0" alignment="0"  font.italic="2"!



*/
