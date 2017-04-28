package com.aua30.util;


public class StringUtil {
	public static boolean isNotBlank(String str) {
		return str != null && !str.isEmpty();
	}

	public static boolean isBlank(String str) {
		return str == null || str.length() == 0;
	}

	public static boolean isNotTrimBlank(String str) {
		return str != null && !str.trim().isEmpty();
	}

	public static boolean isTrimBlank(String str) {
		return str == null || str.trim().isEmpty();
	}
    public static String substr(String str ,int length){
    	if(str!=null&&str.length()>length&&length>0){
    		return str.substring(0,length-1)+"..";
    	}else{
    		return str;
    	}
    }
	
    public static String html2text(String str){
    	if(str==null) return str;
    	String regHtml = "<[^>]+>";
    	str =str.replaceAll(regHtml, "");
    	return str;
    	
    }
}
