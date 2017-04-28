package com.aua30.util;


import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

public class GetUtil {
	public static String getContent(String uri) {
		HttpClient httpClient = new DefaultHttpClient();
		HttpGet httpGet = new HttpGet(uri);
		try {
			HttpResponse responseBody = httpClient.execute(httpGet);
			return EntityUtils.toString(responseBody.getEntity());
		} catch (Exception e) {
			return null;
		}
	}
}
