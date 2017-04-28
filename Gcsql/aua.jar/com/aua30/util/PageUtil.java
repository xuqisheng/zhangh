package com.aua30.util;

public class PageUtil {
	private Integer totalRows;
	private Integer pageCur;
	private Integer pageSize;
	private Integer totalPages;
	private Integer length;
	private Integer offset;
	private Integer startPage;
	private Integer endPage;

	public Integer getTotalRows() {
		return totalRows;
	}
	public void setTotalRows(Integer totalRows) {
		this.totalRows = totalRows;
	}
	public Integer getPageCur() {
		return pageCur;
	}
	public void setPageCur(Integer pageCur) {
		this.pageCur = pageCur;
	}
	public Integer getPageSize() {
		return pageSize;
	}
	public void setPageSize(Integer pageSize) {
		this.pageSize = pageSize;
	}
	public Integer getTotalPages() {
		return totalPages;
	}
	public void setTotalPages(Integer totalPages) {
		this.totalPages = totalPages;
	}
	public Integer getLength() {
		return length;
	}
	public void setLength(Integer length) {
		this.length = length;
	}
	public Integer getOffset() {
		return offset;
	}
	public void setOffset(Integer offset) {
		this.offset = offset;
	}
	public Integer getStartPage() {
		return startPage;
	}
	public void setStartPage(Integer startPage) {
		this.startPage = startPage;
	}
	public Integer getEndPage() {
		return endPage;
	}
	public void setEndPage(Integer endPage) {
		this.endPage = endPage;
	}
	public int calcOffset(int pageCur ,int step,int pageSize){
	  return	(pageCur+step)*pageSize;
	}
	public void calcPage() {
		if (totalRows == null) {
			return;
		}
		totalPages = (totalRows % pageSize == 0) ? (totalRows / pageSize) : (totalRows / pageSize + 1);
		if(totalPages==0)
			totalPages=1;
		pageCur = (offset / pageSize + 1);
		if (pageCur < 6) {
			startPage = 1;
			endPage = totalPages < 10 ? totalPages : 10;
		} else {
			startPage=pageCur-3;
			endPage=((startPage+7)<totalPages)?(startPage+7):totalPages;
		}
		if(startPage<4){
			startPage=1;
		}
	}
	public String linkSymbol(String url){
		return url.indexOf("?")==-1?"?":"&";
	}
}
