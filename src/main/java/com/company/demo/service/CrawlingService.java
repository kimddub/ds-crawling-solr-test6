package com.company.demo.service;

import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import java.util.List;
import java.util.Map;

import com.company.demo.dto.Article;
import com.company.demo.dto.Category;
import com.company.demo.dto.Media;
import com.company.demo.dto.Site;

public interface CrawlingService {

	public void resetCrawlingDB();
	
	public Date getLastDate(int siteCode, int categoryCode);

	public List<Site> getSiteList();

	public List<Category> getCategoryList(int siteCode);

	public List<Media> getMediaList();

	public List<Map<String, Object>> getCrawlingData(Map<String, Object> param);

	public void writeHistory(String content);
	
	public String getSiteName(int siteCode);
	
	public void crawling(int siteCode);

	public void naverCrawling(int siteCode, int categoryCode, Date limitDate);
	
	public void daumCrawling(int siteCode, int categoryCode, Date limitDate);
	
	public void collectData(List<Article> articles, int siteCode, int categoryCode);


}
