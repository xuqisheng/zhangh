drop  proc p_gl_pos_shiftdai;
create proc p_gl_pos_shiftdai
	@vpos				integer,
	@amount			money,
	@pc_id			char(4),
	@pccode			char(5),
	@menu				char(10),
	@type				char(3)
as
----------------------------------------------------------------------------------------------
--
--			餐饮交班表中的贷方数据生产
--
----------------------------------------------------------------------------------------------

if @vpos = 1
	update pos_shift_detail set dai1 = dai1 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 2
	update pos_shift_detail set dai2 = dai2 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 3
	update pos_shift_detail set dai3 = dai3 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 4
	update pos_shift_detail set dai4 = dai4 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 5
	update pos_shift_detail set dai5 = dai5 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 6
	update pos_shift_detail set dai6 = dai6 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu= @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 7
	update pos_shift_detail set dai7 = dai7 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 8
	update pos_shift_detail set dai8 = dai8 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 9
	update pos_shift_detail set dai9 = dai9 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 10
	update pos_shift_detail set dai10 = dai10 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 11
	update pos_shift_detail set dai11 = dai11 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 12
	update pos_shift_detail set dai12 = dai12 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 13
	update pos_shift_detail set dai13 = dai13 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 14
	update pos_shift_detail set dai14 = dai14 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 15
	update pos_shift_detail set dai15 = dai15 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 16
	update pos_shift_detail set dai16 = dai16 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu= @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 17
	update pos_shift_detail set dai17 = dai17 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 18
	update pos_shift_detail set dai18 = dai18 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 19
	update pos_shift_detail set dai19 = dai19 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 20
	update pos_shift_detail set dai20 = dai20 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 21
	update pos_shift_detail set dai21 = dai21 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 22
	update pos_shift_detail set dai22 = dai22 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计')and (type = @type or type = '0')
else if  @vpos = 23
	update pos_shift_detail set dai23 = dai23 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos =24
	update pos_shift_detail set dai24 = dai24 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 25
	update pos_shift_detail set dai25 = dai25 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 26
	update pos_shift_detail set dai26 = dai26 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 27
	update pos_shift_detail set dai27 = dai27 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 28
	update pos_shift_detail set dai28 = dai28 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else if  @vpos = 29
	update pos_shift_detail set dai29 = dai29 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
else
	update pos_shift_detail set dai30 = dai30 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
update pos_shift_detail set daittl = daittl + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and (type = @type or type = '0')
return 0

;