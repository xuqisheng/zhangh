package com.aua30.util;

import java.lang.reflect.Type;
import java.util.Map;

import com.aua30.util.StringUtil;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public class JsonUtil {
	public static Map<String, String> json2map(String json) {
		if (StringUtil.isTrimBlank(json)) {
			return null;
		}
		Type type = new TypeToken<Map<String, String>>() {}.getType();
		Gson gson = new Gson();
		return gson.fromJson(json, type);

	}
	public static Map<String, Map<String, String>> json2map2(String json) {
		if (StringUtil.isTrimBlank(json)) {
			return null;
		}
		Type type = new TypeToken<Map<String, Map<String, String>>>() {}.getType();
		Gson gson = new Gson();
		return gson.fromJson(json, type);
		
	}
}
