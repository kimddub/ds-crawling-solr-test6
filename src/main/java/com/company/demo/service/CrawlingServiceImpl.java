package com.company.demo.service;

import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.groovy.util.Maps;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.company.demo.crawler.DaumCrawler;
import com.company.demo.crawler.NaverCrawler;
import com.company.demo.dao.ArticleDao;
import com.company.demo.dto.Article;
import com.company.demo.dto.Category;
import com.company.demo.dto.Media;
import com.company.demo.dto.Site;

@Service
public class CrawlingServiceImpl implements CrawlingService {
	@Autowired
	ArticleDao articleDao;
	@Autowired
	NaverCrawler naverCrawler;
	@Autowired
	DaumCrawler daumCrawler;
	@Value("${custom.filelPath}")
	private String filePath;
	
	public void setForeignKeyChecks(int val) {
		articleDao.setForeignKeyChecks(val);
	}
	
	public void resetCrawlingDB() {
		setForeignKeyChecks(0);
		articleDao.truncateArticle();
		setForeignKeyChecks(1);
		
		articleDao.truncateCategorize();
	}

	public Date getLastDate(int siteCode, int categoryCode) {
		return articleDao.getLastDate(siteCode, categoryCode);
	}

	public List<Site> getSiteList() {
		return articleDao.getSiteList();
	}
	
	public List<Category> getCategoryList(int siteCode) {
		return articleDao.getCategoryList(siteCode);
	}
	
	public List<Media> getMediaList() {
		return articleDao.getMediaList();
	}
	
	public List<Map<String, Object>> getCrawlingData(Map<String, Object> param) {
		return articleDao.getCrawlingData(param);
	}
	
	public void writeHistory(String content) {
		
		try {
			BufferedWriter bw = new BufferedWriter(new FileWriter(filePath + "\\crawling.txt",true));
			PrintWriter pw = new PrintWriter(bw,true);
			
			System.out.println(content);
			pw.println(content);
			pw.close();

		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public String getSiteName(int siteCode) {
		return articleDao.getSiteName(siteCode);
	}
	
	public void crawling(int siteCode) {
		List<Category> categoryList = getCategoryList(siteCode);
		
		String textLine = ""; //기록에 출력할 문자열
		
		for (Category category:categoryList) {
			writeHistory("===" + new Date().toString() + "==="
					+ "\n target: " + getSiteName(siteCode) + "-"+category.getSection()+">"+category.getSubSection());
			
			Date limitDate = getLastDate(siteCode, category.getCode()); // null이면 크롤러가 알아서 7일전 설정
			
			if (limitDate != null) {
				writeHistory("period to crawling: " + limitDate.toString() + "~  " + new Date().toString());
				
			} else {
				// 각 크롤러에서 7일 전 ~ 현재 시간 계산한 문자열 가지고와서 출력
			}
			
			if (siteCode == 1) {
				naverCrawling(siteCode,category.getCode(),limitDate);
			} else if (siteCode == 2) {
				daumCrawling(siteCode,category.getCode(),limitDate);
			}
		}
	}
	
	public void naverCrawling(int siteCode, int categoryCode, Date limitDate) {

		// url 셋팅에 필요한 카테고리 url id
		Map<String,Object> sectionIdPair = articleDao.getSectionId(categoryCode);
		String sectionId = (String)sectionIdPair.get("sectionId");
		String subSectionId = (String)sectionIdPair.get("subSectionId");
		
		// crawler
		List<Article> articles = naverCrawler.crawling(sectionId,subSectionId,limitDate);
		
		writeHistory("period to crawling: " + naverCrawler.getPeriodToCrawling()
						+ "\n - crawling data: " + articles.size()
						+ "\n - uncrawling data(DOM error):" );
		
		
		List<Article> uncrawlArticles = naverCrawler.getUncrawlingArticles();
		
		for(Article uncrawlingData:uncrawlArticles) {
			writeHistory("\t" + uncrawlingData.getWebPath());
			System.out.println(uncrawlingData);
		}
		
		collectData(articles,siteCode,categoryCode);
	}
	
	public void daumCrawling(int siteCode, int categoryCode, Date limitDate) {

		// url 셋팅에 필요한 카테고리 url id
		Map<String,Object> sectionIdPair = articleDao.getSectionId(categoryCode);
		String sectionId = (String)sectionIdPair.get("sectionId");
		String subSectionId = (String)sectionIdPair.get("subSectionId");
		
		// crawler
		List<Article> articles = daumCrawler.crawling(sectionId,subSectionId,limitDate);
		
		writeHistory("period to crawling: " + daumCrawler.getPeriodToCrawling()
						+ "\n - crawling data: " + articles.size()
						+ "\n - uncrawling data(DOM error):" );
		
		
		List<Article> uncrawlArticles = daumCrawler.getUncrawlingArticles();
		
		for(Article uncrawlingData:uncrawlArticles) {
			writeHistory("\t" + uncrawlingData.getWebPath());
			System.out.println(uncrawlingData);
		}
		
		collectData(articles,siteCode,categoryCode);
	}

	public void collectData(List<Article> articles, int siteCode, int categoryCode) {
		int insertData = 0;
		int updateData = 0;
		int insertMedia = 0;
		
		List<String> uninsertedArticle = new ArrayList<>();
		
		// 하나씩 insert
		for (Article article:articles) {
			
			try {
				//media -> 있으면 code 가져오고, 없으면 추가한 후에 가져오기
				Integer mediaCode = articleDao.getMediaCode((String)article.getExtra().get("media"));
				
				if (mediaCode == null) {
					
					Map<String,Object> mediaInfo = new HashMap<>();
					mediaInfo.put("media", (String)article.getExtra().get("media"));
					articleDao.addMediaCode(mediaInfo); 
					
					mediaCode = (int)(long)mediaInfo.get("code");
					
					insertMedia++;
				} 
				
				//Article
				//Code(AI), Id, siteCode*, mediaCode*, webPath, regDate, colDate, body
				article.setSiteCode(siteCode);
				article.setMediaCode(mediaCode);
				
				articleDao.addArticle(article); // article + code
				
				Integer articleCode = null;
				
				if (article.getCode() != 0) {
					
					articleCode = article.getCode();
					
					insertData++;
					
				} else { //게시물 id, siteCode,mediaCode 중복
					
					// 중복된 조건으로 게시물 code 검색해서 가져온 후 body, date, analyzeState 업데이트 해줌
					// analyzeState 초기화로 형태소 분석기가 다시 분석하도록 함
					// 그러려면 이 게시물을 분석했던 키워드들도 지워둬야 한다
					
					articleCode = (int)articleDao.getArticleCode(article);
					article.setCode(articleCode);
					
					articleDao.updateArticle(article);
					articleDao.resetArticleKeyword(article);
					
					System.out.println(article.getWebPath());
					
					updateData++;
				}
	
				/* 팝 카테고리 추가시
				category -> code, popState 가져오기
				category popState 1 이면
				
				state 1인 애들은 지난 애들
				0인 애들은 현재 등록중인 애들
				Categorize -> 0인 애들중에 코드관계 겹치면 그냥두고 없으면 추가
				Code(AI), articleCode*, categoryCode*, regDate(NOW), unregDate(X)
				*/
				
				// 기사-카테고리 관계가 중복 아닌 데이터들만 관계 추가
				// 있어서 업데이트 된 기사라도 다른 카테고리에서 발견됐다면 그 관계는 추가된다.
				articleDao.addCategorize(Maps.of("categoryCode", categoryCode,"articleCode",articleCode));
				
			} catch (Exception e) {
				uninsertedArticle.add(article.getWebPath());
				System.out.println(article.getWebPath() + "경로의 게시물을 DB 삽입할 수 없음");
				System.out.println(e.getMessage());
				continue;
			}
		}

		writeHistory(" - new media: " + insertMedia
				+ "\n - new data: " + insertData
				+ "\n - update data: " + updateData
				+ "\n - uninserted data(DB error):" + uninsertedArticle.size());
		
		for(String uncrawlingData:uninsertedArticle) {
			writeHistory("\t" + uncrawlingData);
		}
		
	}
}
