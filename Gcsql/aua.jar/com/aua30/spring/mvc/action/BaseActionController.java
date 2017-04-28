package com.aua30.spring.mvc.action;

import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.multiaction.MultiActionController;

import com.aua30.pojo.StaticInfo;
import com.aua30.util.PageUtil;
import com.aua30.util.StringUtil;

public class BaseActionController extends MultiActionController {
	public static final String PageOffset = "pageOffset";
	public static final String PageSize = "pageSize";

	public String velocityPath() {
		     String str= actionPath().replaceAll("Action", "");
	   return str.replaceFirst(str.substring(0,1), str.substring(0,1).toLowerCase());
	}

	public String actionPath() {
		return getClass().getSimpleName();
	}

	public String generatorUrl(String url) {
		return url;
	}

	protected StaticInfo staticInfo;

	public void setStaticInfo(StaticInfo staticInfo) {
		this.staticInfo = staticInfo;
	}

	public ModelAndView execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		Map<String, Object> modelMap = new HashMap<String, Object>();
		modelMap.put("request", request);
		modelMap.put("session", request.getSession());
		modelMap.put("StringUtil", StringUtil.class);
		request.setAttribute("staticInfo", staticInfo);
		return new ModelAndView("", modelMap);
	}

	protected void clacPaging(ModelAndView modelAndView, Integer totalRows, int pageSize, int offset) throws Exception {
		PageUtil pu = new PageUtil();
		pu.setTotalRows(totalRows);
		pu.setPageSize(pageSize);
		pu.setOffset(offset);
		pu.calcPage();
		modelAndView.addObject("pageUtil", pu);
	}

	public int getOffset(HttpServletRequest request) {
		String strOffset = request.getParameter(PageOffset);
		if (strOffset == null || strOffset.isEmpty()) {
			return 0;
		}
		int offset = Integer.parseInt(strOffset);
		return offset > 0 ? offset : 0;
	}

	public int getPageSize(HttpServletRequest request) {
		String ps = request.getParameter(PageSize);
		if (ps == null || ps.isEmpty()) {
			return staticInfo.getPageSize();
		} else {
			int ips = Integer.parseInt(ps);
			return ips > 0 ? ips : staticInfo.getPageSize();
		}
	}

	public ModelAndView add(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView modelAndView = execute(request, response);
		modelAndView.setViewName(velocityPath() + "/edit");
		return modelAndView;
	}

	public ModelAndView edit(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView modelAndView = execute(request, response);
		modelAndView.setViewName(velocityPath() + "/edit");
		return modelAndView;
	}

	public ModelAndView save(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String redirectPath = request.getParameter("redirectPath");
		ModelAndView modelAndView = execute(request, response);
		modelAndView.setViewName(generatorUrl("redirect:" + redirectPath));
		return modelAndView;
	}

	public ModelAndView delete(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String redirectPath = request.getParameter("redirectPath");
		ModelAndView modelAndView = execute(request, response);
		modelAndView.setViewName(generatorUrl("redirect:" + redirectPath));
		return modelAndView;
	}

	public ModelAndView list(HttpServletRequest request, HttpServletResponse response) throws Exception {
		ModelAndView modelAndView = execute(request, response);
		// 拼写redirectPath
		StringBuilder sb = new StringBuilder();
		sb.append(velocityPath() + ".htm");
		Map<String, String[]> map = request.getParameterMap();
		int i = 0;
		for (String key : map.keySet()) {
			if (!(PageOffset.equals(key))) {
				String[] vals = map.get(key);
				for (String val : vals) {
					sb.append(i == 0 ? "?" : "&");
					sb.append(key).append("=").append(URLEncoder.encode(val, "UTF-8"));
					i++;
				}
			}
		}
		request.setAttribute("pagePath", sb.toString());
		if (request.getParameter(PageOffset) != null) {
			sb.append("&").append(PageOffset).append("=").append(request.getParameter(PageOffset));
		}
		modelAndView.setViewName(velocityPath() + "/list");
		String redirectPath = URLEncoder.encode(sb.toString(), "UTF-8");
		modelAndView.getModelMap().addAttribute("redirectPath", redirectPath);
		return modelAndView;
	}

}
