package com.company.demo.dao;

import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.company.demo.dto.Article;
import com.company.demo.dto.Category;
import com.company.demo.dto.Media;
import com.company.demo.dto.Site;

@Mapper
public interface ArticleDao {
	public Integer getArticleCode(Article articles);
	
	public List<Article> getArticles();
	
	public Integer getMediaCode(String media);
	
	public Map<String, Object> getSectionId(int categoryCode);

	public Date getLastDate(int siteCode, int categoryCode);

	public List<Map<String, Object>> getAllSourceInfo();

	public List<Site> getSiteList();

	public List<Category> getCategoryList(int siteCode);

	public List<Media> getMediaList();

	public List<Map<String, Object>> getAnalyzedData(Map<String, Object> param);
	
	public List<Map<String, Object>> getCrawlingData(Map<String, Object> param);
	
	public void addMediaCode(Map<String, Object> mediaInfo);

	public void addArticle(Article articles);
	
	public void addCategorize(Map<String, Object> param);
	
	public void addKeyword(Map<String, Object> param);

	public void updateArticle(Article article);
	
	public void updateAnalysisState(Article article);

	public void truncateArticle();

	public void truncateCategorize();
	
	public void truncateKeyword();

	public int getAnalyzedArticle();

	public int getTotalArticleData();

	public String getSiteName(int siteCode);

	public void setForeignKeyChecks(int value);

	public void resetArticleKeyword(Article article);



}
