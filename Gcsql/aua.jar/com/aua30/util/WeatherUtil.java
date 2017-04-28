package com.aua30.util;

import java.util.Map;

import org.htmlparser.NodeFilter;
import org.htmlparser.Parser;
import org.htmlparser.filters.AndFilter;
import org.htmlparser.filters.HasAttributeFilter;
import org.htmlparser.filters.HasChildFilter;
import org.htmlparser.filters.HasParentFilter;
import org.htmlparser.filters.TagNameFilter;
import org.htmlparser.tags.ImageTag;
import org.htmlparser.tags.LinkTag;
import org.htmlparser.tags.TableColumn;
import org.htmlparser.tags.TableRow;
import org.htmlparser.tags.TableTag;
import org.htmlparser.util.NodeList;
import org.htmlparser.util.ParserException;
public class WeatherUtil {
	public static Map<String, String> getProvince(String uri) {
		String proviceStr = GetUtil.getContent(uri);
		return JsonUtil.json2map(proviceStr);
	}

	public static Map<String, String> getCity(String uri) {
		String cityStr = GetUtil.getContent(uri);
		return JsonUtil.json2map(cityStr);
	}

	public static Map<String, String> getDistrict(String uri) {
		String districtStr = GetUtil.getContent(uri);
		return JsonUtil.json2map(districtStr);
	}

	public static String getHtmlContent(String uri) {
		return GetUtil.getContent(uri);
	}
	public static   Map<String, String>  getTemperatureHumidity(String uri){
		String temperatureHumidity = GetUtil.getContent(uri);
		Map<String, Map<String, String>> temperatureHumidityMap= JsonUtil.json2map2(temperatureHumidity);
		return temperatureHumidityMap.get("weatherinfo");
	}

	public static void parseWeatherTopleft(Parser parser) throws ParserException {
		parser.reset();
		NodeFilter weatherTopleft = new AndFilter(new TagNameFilter("div"), new HasAttributeFilter("class",
				"weatherTopleft"));
		NodeFilter leftTitle = new AndFilter(new TagNameFilter("h1"), new HasParentFilter(weatherTopleft));
		NodeList nodeList = parser.parse(leftTitle);
		// 城市名和拼音
		String title = nodeList.elementAt(0).toPlainTextString();
		System.out.println(title);
		parser.reset();
		NodeFilter nodeFilter = new AndFilter(new TagNameFilter("dl"), new HasParentFilter(weatherTopleft));
		nodeFilter = new AndFilter(new TagNameFilter("dt"), new HasParentFilter(nodeFilter));
		nodeFilter = new AndFilter(new TagNameFilter("a"), new HasParentFilter(nodeFilter));
		NodeFilter imgFilter = new AndFilter(new TagNameFilter("img"), new HasParentFilter(nodeFilter));
		nodeList = parser.parse(imgFilter);
		ImageTag imageTag = (ImageTag) nodeList.elementAt(0);
		System.out.println(imageTag.getImageURL());
	}
	public static void parseWeatherTopright(Parser parser) throws ParserException {
		parser.reset();
		NodeFilter weatherTopright = new AndFilter(new TagNameFilter("div"), new HasAttributeFilter("class","weatherTopright"));
		weatherTopright= new AndFilter(new TagNameFilter("dl"), new HasParentFilter(weatherTopright));
		weatherTopright = new AndFilter(new TagNameFilter("dd"), new HasParentFilter(weatherTopright));
		NodeFilter sunriseNodeFilter = new AndFilter(new TagNameFilter("a"), new HasParentFilter(weatherTopright));
	 	 NodeFilter postCodeNodeFilter= new AndFilter(weatherTopright,new HasChildFilter(new TagNameFilter("b")));
		NodeList nodeList = parser.parse(sunriseNodeFilter);
		//今日日出时间
		String rise =nodeList.elementAt(0).toPlainTextString();
		String sunset =nodeList.elementAt(1).toPlainTextString();
		//明日日出时间
        String tomorrowRise = nodeList.elementAt(2).toPlainTextString();
		String tomorrowSunset= nodeList.elementAt(3).toPlainTextString();
		parser.reset();
		nodeList = parser.parse(postCodeNodeFilter);
		String postCode=nodeList.elementAt(0).toPlainTextString();
	}
	private static void parseWeatherForecast(Parser parser) throws ParserException {
		parser.reset();
		NodeFilter weatherForecastNodeFilter = new AndFilter(new TagNameFilter("table"), new HasAttributeFilter("class","yuBaoTable"));
		NodeList nodeList = parser.parse(weatherForecastNodeFilter);
		 for(int i=0;i<nodeList.size();i++){
			TableTag tableTag = (TableTag) nodeList.elementAt(i);
			 int rowCount=tableTag.getRowCount();
			 for(int j=0;j<rowCount;j++){
				 TableRow tableRow = tableTag.getRow(j);
				  TableColumn []tableColumns = tableRow.getColumns();
				  int k=0;
				  //解析日期
				   if(tableColumns.length==7){
					 LinkTag linkTag= (LinkTag) tableColumns[0].childAt(0);
					  String chinaCalendar= linkTag.getAttribute("title");
					  String calendar= linkTag.getLinkText();
					  k=1;
				   }
				   //解析 白天/黑夜
				  String dayNight= tableColumns[k].toPlainTextString();
				  LinkTag linkTag = (LinkTag) tableColumns[k+1].childAt(1);
				  ImageTag imageTag=  (ImageTag) linkTag.childAt(1);
				  String imageUrl=imageTag.getImageURL();
				  String weatherStr=tableColumns[k+2].toPlainTextString().trim();
				  String temperatureStr=tableColumns[k+3].toPlainTextString().trim();
				  String windDirection = tableColumns[k+4].toPlainTextString().trim();
				  String windPower = tableColumns[k+5].toPlainTextString().trim();

			 }
		 }
	}
	//天气生活指数
	private static void parseWeatherTodayLiving(Parser parser) throws ParserException {
		parser.reset();
		NodeFilter weatherTodayLivingNodeFilter = new AndFilter(new TagNameFilter("div"), new HasAttributeFilter("class","todayLiving"));
		weatherTodayLivingNodeFilter = new AndFilter(new TagNameFilter("dl"), new HasParentFilter(weatherTodayLivingNodeFilter));
        //图片		
		NodeFilter imgNodeFilter =  new AndFilter(new TagNameFilter("dt"), new HasParentFilter(weatherTodayLivingNodeFilter));
		 imgNodeFilter =  new AndFilter(new TagNameFilter("a"), new HasParentFilter(imgNodeFilter));
		 imgNodeFilter =  new AndFilter(new TagNameFilter("img"), new HasParentFilter(imgNodeFilter));
	     NodeList imgNodeList = parser.parse(imgNodeFilter);
	    ImageTag imageTag = (ImageTag) imgNodeList.elementAt(0);
	    System.out.println(imageTag.getImageURL());
	     parser.reset();
		//标题
		 NodeFilter ddNodeFilter = new AndFilter(new TagNameFilter("dd"),new HasParentFilter(weatherTodayLivingNodeFilter));
		 NodeFilter titleNodeFilter = new AndFilter(new TagNameFilter("h2"),new HasParentFilter(ddNodeFilter));
		 titleNodeFilter = new AndFilter(new TagNameFilter("a"),new HasParentFilter(titleNodeFilter));
		 NodeList titleNodeList=parser.parse(titleNodeFilter);
		//说明
		 parser.reset();
		 NodeList explainNodeList =  parser.parse(ddNodeFilter);
		System.out.println( explainNodeList.elementAt(0).toPlainTextString().replace(titleNodeList.elementAt(0).toPlainTextString(), ""));

		//BLOCKQUOTE
	}
  
	public static void main(String[] args) throws ParserException {

		String provinceUri = "http://www.weather.com.cn/data/citydata/china.html";
		String cityUri = "http://www.weather.com.cn/data/citydata/district/$.html";
		String districtUri = "http://www.weather.com.cn/data/citydata/city/$.html";
		String districtContentUri = "http://www.weather.com.cn/weather/$.shtml";
		String temperatureHumidityUri="http://www.weather.com.cn/data/sk/$.html";
		String cityintroUri="http://www.weather.com.cn/cityintro/$.shtml";
		
		Map<String, String> provinceMap = getProvince(provinceUri);
		for (String provinceCode : provinceMap.keySet()) {
			System.out.println(provinceCode + "===" + provinceMap.get(provinceCode));
			Map<String, String> cityMap = getCity(cityUri.replace("$", provinceCode));
			for (String cityCode : cityMap.keySet()) {
				System.out.println(cityCode + "===" + cityMap.get(cityCode));
				Map<String, String> districtMap = getDistrict(districtUri.replace("$", provinceCode + cityCode));
				for (String districtCode : districtMap.keySet()) {
					System.out.println(districtCode + "====" + districtMap.get(districtCode));
					String strDistrictContentUri = null;
					String strTemperatureHumidityUri=null;
					String strCityintroUri=null;
					if (cityMap.size() == 1) {
						strDistrictContentUri = districtContentUri.replace("$", provinceCode + districtCode + cityCode);
						strCityintroUri=cityintroUri.replace("$", provinceCode + districtCode + cityCode);
						strTemperatureHumidityUri = temperatureHumidityUri.replace("$", provinceCode + districtCode + cityCode);
					} else {
						strDistrictContentUri = districtContentUri.replace("$", provinceCode + cityCode + districtCode);
						strCityintroUri=cityintroUri.replace("$", provinceCode + cityCode + districtCode);
						strTemperatureHumidityUri = temperatureHumidityUri.replace("$", provinceCode + cityCode + districtCode);
					}
					String districtContent = getHtmlContent(strDistrictContentUri);
					Parser parser = Parser.createParser(districtContent, "UTF-8");
					// 把天气内容中的扣下来
					NodeFilter nodeFilter = new AndFilter(new TagNameFilter("div"), new HasAttributeFilter("class","weatherLeft"));
					NodeList nodeList = parser.parse(nodeFilter);
					String str = nodeList.elementAt(0).toHtml();
					str=str.replaceAll("<script language=\"javaScript\" type=\"text/javascript\" src=\"/m2/j/sk.js\" />", "");
					System.out.println(str);
				    // 以天气内容作为解析模板
					parser = Parser.createParser(str, "UTF-8");
					// 这里有城市名和城市图片
					parseWeatherTopleft(parser);
					 Map<String, String> temperatureHumidityMap = getTemperatureHumidity(strTemperatureHumidityUri);
					System.out.println(temperatureHumidityMap.get("temp"));
					parseWeatherTopright(parser);
					parseWeatherForecast(parser);
					parseWeatherTodayLiving(parser);
				    String cityIntroContent = getHtmlContent(strCityintroUri);
				    parser = Parser.createParser(cityIntroContent, "UTF-8");
				    parseCityIntro(parser);
					
				}
			}

		}
	}

	private static void parseCityIntro(Parser parser) throws ParserException {
		parser.reset();
		NodeFilter cityIntroNodeFilter = new AndFilter(new TagNameFilter("div"), new HasAttributeFilter("class","LBeijingCityIntroduction1"));
		NodeList nodeList = parser.parse(cityIntroNodeFilter);
	    System.out.println(	nodeList.elementAt(0).toPlainTextString().replaceAll("&nbsp;", "").trim());
	}




}
