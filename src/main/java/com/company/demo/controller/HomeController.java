package com.company.demo.controller;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.json.simple.JSONObject;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StopWatch;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.company.demo.DsCrawlingSolrTest6Application;
import com.company.demo.crawler.NaverCrawler;
import com.company.demo.dto.Category;
import com.company.demo.dto.Media;
import com.company.demo.dto.Site;
import com.company.demo.service.CrawlingService;
import com.company.demo.service.TextProcessorService;

import jline.internal.Log;

@Controller
public class HomeController { //+재탐색 +유동카테고리
	@Autowired
	CrawlingService crawlingService;
	@Autowired
	TextProcessorService tpService;
	@Autowired
	NaverCrawler tmpCrawler;
	
	private static Logger logger = LoggerFactory.getLogger(DsCrawlingSolrTest6Application.class);
	
	// 초기 크롤러
	//@EventListener(ApplicationReadyEvent.class)
	public void setUp() {
		Log.info("setup crawling");
		
		// DB 초기화 - 크롤링(article, categorize)
		//crawlingService.resetCrawlingDB(); //Article, categorize truncate
		// DB 초기화 - 자연어처리(keyword)
		//tpService.resetKeyword();
		
		// 초기 크롤링 (7일치) 각 사이트-카테고리 범위 전부
		// DB 상 사이트-카테고리의 데이터가 null이면 초기 크롤링 실행
		// 아닌 경우는 이어서 실행
		executeNaverCrawling();
		//executeDaumCrawling();

		// 자연어 처리?
		// 1. 크롤링 후 실행되도록 + 긴 주기적 실행
		// 2. 짧은 주기적 실행
		
		// 주기적 크롤링
		// 사이트별 크롤링 메소드(카테고리 순차적) 독립적으로 실행
		// 매 30분 마다
	} 
	
	@RequestMapping("/home")
	public String showMain() {
		return "home/main";
	}
	
	@RequestMapping("/home/main")
	public String showMain2() {
		return "home/main";
	}
	
	@RequestMapping("/home/analyzedData")
	public String showAnalyzedData(Model model,@RequestParam Map<String,Object> param) {
		
		List<Site> siteList = crawlingService.getSiteList();
		
		model.addAttribute("siteList", siteList);
		
		List<Media> mediaList = crawlingService.getMediaList();
		
		model.addAttribute("mediaList", mediaList);
		
		return "home/analyzedData";
	}
		

	@RequestMapping("/home/crawlingData")
	public String showCrawlingData(Model model,@RequestParam Map<String,Object> param) {
		
		List<Site> siteList = crawlingService.getSiteList();
		
		model.addAttribute("siteList", siteList);
		
		List<Media> mediaList = crawlingService.getMediaList();
		
		model.addAttribute("mediaList", mediaList);
		
		return "home/crawlingData";
	}
	
	@RequestMapping("/home/getCategoryList")
	@ResponseBody
	public List<Category> getCategoryList(@RequestParam Map<String,Object> param) {
		
		if (!param.containsKey("siteCode")) {
			return null;
		}
		
		int siteCode = Integer.parseInt((String)param.get("siteCode"));
		List<Category> categoryList = crawlingService.getCategoryList(siteCode);
				
		return categoryList; 
	}
	
	@RequestMapping("/home/getAnalyzedData")
	@ResponseBody
	public List<JSONObject> getAnalyzedData(@RequestParam Map<String,Object> param) {
		
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm");
		
		String startDateStr = param.get("startDate") + " " + param.get("startTime");
		String endDateStr = param.get("endDate") + " " + param.get("endTime");
		
		try {
			Date startDateTime = formatter.parse(startDateStr);
			Date endDateTime = formatter.parse(endDateStr);
			
			param.put("startDateTime", startDateTime);
			param.put("endDateTime", endDateTime);
			
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		
		//파라미터 잘못 넘어왔는지 예외처리
		
		// 날짜가 잘못 가져와졌을 때? -> null? ''?
		if (param.containsKey("startDateTime") && param.containsKey("endDateTime")) {
			param.put("dateCondition","true");
		}
		
		//사이트,카테고리,언론사 입력하면
		//날짜별로 이슈키워드와 건 출력해야 함
		List<Map<String,Object>> crawlingData = tpService.getAnalyzedData(param);
		
		// 출력할 데이터들을 담을 리스트
		List<JSONObject> result = new ArrayList<>();

		// 맵으로 담긴 데이터들을 JSON 형태로 결과리스트에 옮기기
		for (Map<String,Object> data : crawlingData) {
			
			JSONObject jsonObject = new JSONObject();
			
	        for( Map.Entry<String, Object> entry : data.entrySet() ) {
	        	
	            String key = entry.getKey();
	            Object value = entry.getValue();
	            jsonObject.put(key, value);
	        }
			
	        result.add(jsonObject);
		}
		
		return result;
	}
	
	@RequestMapping("/home/getCrawlingData")
	@ResponseBody
	public List<JSONObject> getCrawlingData(@RequestParam Map<String,Object> param) {
		// 파라미터 잘못 넘어왔는지 예외처리
		
		//사이트,카테고리,언론사 입력하면
		//날짜별로 데이터가 몇건 수집되었는지 출력해야 함
		List<Map<String,Object>> crawlingData = crawlingService.getCrawlingData(param);
		
		// 출력할 데이터들을 담을 리스트
		List<JSONObject> result = new ArrayList<>();

		// 맵으로 담긴 데이터들을 JSON 형태로 결과리스트에 옮기기
		for (Map<String,Object> data : crawlingData) {
			
			JSONObject jsonObject = new JSONObject();
			
	        for( Map.Entry<String, Object> entry : data.entrySet() ) {
	        	
	            String key = entry.getKey();
	            Object value = entry.getValue();
	            jsonObject.put(key, value);
	        }
			
	        result.add(jsonObject);
		}
		
		return result;
	}
	
	//@Scheduled(cron = "0 0/20 * * * *")
	@RequestMapping("textAnalysis")
	@ResponseBody
	public String executeTextAnalysis() {
		Log.info("execute text analysis");
		
		StopWatch sw = new StopWatch();
		
		sw.start();

		// 현재 DB에 있는 분석된 적이 없는 기사들을 모두 형태소분석함
		tpService.analyzeArticleText();
		
		sw.stop();//
		double textAnalysisTime = sw.getTotalTimeMillis()/1000.0;
		System.out.println("Text Analysis Time: " + textAnalysisTime);//
				
		
		return "textAnalysis done successfully";
	}
	
	//@Scheduled(cron = "0 30 * * * *") // 30분 마다 돌아감
	public String executeNaverCrawling() {
			
		Log.info("execute Naver Crawling");
		
		StopWatch sw = new StopWatch();
		sw.start();
		crawlingService.crawling(1); // 1:naver
		
		sw.stop();//
		double crawlingTime = sw.getTotalTimeMillis()/1000.0;
		
		System.out.println("Naver 3category crawling and inserting time: " + crawlingTime);//
		
		// executeTextAnalysis(); //따로하는게 나은듯
		
		return "Crawling done successfully";
	}
	
	//@Scheduled(cron = "50 33 * * * *") // 평일 정각마다 돌아감
	public String executeDaumCrawling() {
			
		Log.info("execute Daum Crawling");
		
		StopWatch sw = new StopWatch();
		sw.start();
		crawlingService.crawling(2); // 2:Daum
		
		sw.stop();//
		double crawlingTime = sw.getTotalTimeMillis()/1000.0;
		
		System.out.println("Daum 3category crawling and inserting time: " + crawlingTime);//
		
		//executeTextAnalysis();
		
		return "Crawling done successfully";
	}
	

	@RequestMapping("test")
	@ResponseBody
	public String test() {
		/*
		 DOM 구조 추가 test
		 https://sports.news.naver.com/kbaseball/news/read.nhn?oid=003&aid=0009502377
		 +dateSelector: #content > div > div.content > div > div.news_headline > div.info > span:last-of-type
		 https://news.naver.com/main/read.nhn?mode=LS2D&mid=shm&sid1=102&sid2=276&oid=029&aid=0002559196
		 +bodySelector
		 */
		
		Document page = null;
		try {
			
			page = Jsoup.connect("https://news.naver.com/main/read.nhn?mode=LS2D&mid=shm&sid1=102&sid2=276&oid=003&aid=0009504743")
							.get();
			
		} catch (IOException e) {
			e.printStackTrace();
		}
		String bodySelector = "#articleBodyContents, #articeBody";
		Elements body = page.select(bodySelector);
		
		return body.html();
	}
	
	/*
	@Scheduled(fixedDelay = 172800000) // 2틀마다 실행 (수정 가능성 큰 주기)
	public void executeUpdateCrawlingEveryTwoDays() {
		
		logger.info("Start Scheduling Thread : {}", Thread.currentThread().getName());
		
		// 모든 사이트 수정 크롤러
		// 그냥 정해진 시작점부터 쭉 수정해나가는 크롤러 (경우의 수? 또는 모두 업데이트 해버리기?)
		// 끼어들기, 삭제, 수정

		logger.info("End Scheduling Thread");
	}
	
	@Scheduled(cron = " 0 0 10 ? * 6")  // 매월 마지막 금요일 아무날이나 10시에 실행 (수정 가능성 희박한 주기)
	public void executeUpdateCrawling1stDayOfEveryMonth() {
		
		logger.info("Start Scheduling Thread : {}", Thread.currentThread().getName());
		
		// 모든 사이트 수정 크롤러

		logger.info("End Scheduling Thread");
	}
	
	@RequestMapping("checkAll")
	@ResponseBody
	public Map<String,Object> showAllCrawlingProgress() {
		
//	작동하고 있는 스케줄링된 인사이트 크롤러들의 히스토리를 모두 체크
		
		Map<String,Object> allProgress = new HashMap<>();
		
		allProgress.put("insight-history",insightCrawler.getHistory());
		allProgress.put("wikitree-history",wikitreeCrawler.getHistory());
		
		return allProgress;
	}
	
	@RequestMapping("checkInsight")
	@ResponseBody
	public List<CrawlingInfo> showInsightCrawlingProgress() {
		
//		작동하고 있는 스케줄링된 인사이트 크롤러들의 히스토리를 모두 체크
		
		return insightCrawler.getHistory();
	}
	
	@RequestMapping("checkWikitree")
	@ResponseBody
	public List<CrawlingInfo> showWikitreeCrawlingProgress() {
		
//		작동하고 있는 스케줄링된 위키트리 크롤러들의 히스토리를 모두 체크
		System.out.println(wikitreeCrawler.getHistory());
		
		return wikitreeCrawler.getHistory();
	}
	*/
}