package com.aua30.pojo;

import java.io.Serializable;

public class StaticInfo implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 7537172436054426579L;
	private String imgPath;
	private String staticPath;
	private Integer pageSize;
	private String filePath;
	public String getFilePath() {
		return filePath;
	}
	public void setFilePath(String filePath) {
		this.filePath = filePath;
	}
	public String getImgPath() {
		return imgPath;
	}
	public void setImgPath(String imgPath) {
		this.imgPath = imgPath;
	}
	public String getStaticPath() {
		return staticPath;
	}
	public void setStaticPath(String staticPath) {
		this.staticPath = staticPath;
	}
	public Integer getPageSize() {
		return pageSize;
	}
	public void setPageSize(Integer pageSize) {
		this.pageSize = pageSize;
	}
}
