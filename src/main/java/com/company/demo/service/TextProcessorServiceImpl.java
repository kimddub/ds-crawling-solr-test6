package com.company.demo.service;

import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;

import org.apache.groovy.util.Maps;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.company.demo.dao.ArticleDao;
import com.company.demo.dto.Article;

import kr.co.shineware.nlp.komoran.constant.DEFAULT_MODEL;
import kr.co.shineware.nlp.komoran.core.Komoran;
import kr.co.shineware.nlp.komoran.model.KomoranResult;

@Service
public class TextProcessorServiceImpl implements TextProcessorService {
	@Autowired
	ArticleDao articleDao;
	@Value("${custom.filelPath}")
	private String filePath;
	
	public void resetKeyword() {
		articleDao.truncateKeyword();
	}
	
	public List<Map<String, Object>> getAnalyzedData(Map<String, Object> param) {
		return articleDao.getAnalyzedData(param);
	}
	
	public void writeHistory(String content) {
		
		try {
			BufferedWriter bw = new BufferedWriter(new FileWriter(filePath + "\\text-processing.txt",true));
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
	
	public void analyzeArticleText() {
		writeHistory("===" + new Date().toString() + "===");
		
		int analyzeArticle = 0;
		int unanalyzeArticle = 0;
		List<Integer> unanalyzeArticleCode = new ArrayList<>();
		
		// 형태소 분석이 되지 않은 데이터를 가져옴
		List<Article> articles = articleDao.getArticles();
		
		if (articles == null || articles.size() < 1) {
			writeHistory("new processed data: 0");
			
			return ;
		}
		
		for (Article article:articles) {

			Komoran komoran = new Komoran(DEFAULT_MODEL.LIGHT);
			String strToAnalyze = article.getBody();
	
			KomoranResult analyzeResultList = komoran.analyze(strToAnalyze);
			List<String> duplicateList = analyzeResultList.getNouns();

//			for(String noun:duplicateList) {
//				System.out.println("'"+ noun + "'");
//			}
			
			//-------한 게시물에서 중복 키워드 제거---------
			TreeSet<String> treeSetList = new TreeSet<String>();
	        List<String> keywordList = new ArrayList<String>();

	        for (String dupl : duplicateList) {

	            treeSetList.add(dupl);
	        }
	        
	        Iterator<String> it = treeSetList.iterator();

	        while(it.hasNext()) {

	        	keywordList.add(it.next());
	        }
	        
	        //-------한 게시물에서 중복 키워드 제거---------
			
			if (keywordList==null || keywordList.size()==0) {
				System.out.println("Article[" + article.getCode() + "]의 형태소를 분석 할 수 없음");
				unanalyzeArticleCode.add(article.getCode());
				
				unanalyzeArticle++;
				
			} else {

				try {
					articleDao.addKeyword(Maps.of("articleCode",article.getCode(),"keywordList",keywordList));
					articleDao.updateAnalysisState(article);
					
					//System.out.println("Article[" + article.getCode() + "]의 형태소 분석 완료");
					analyzeArticle++;
				} catch (Exception e) {
					
					//이미 해당 게시물의 해당 키워드가 있을때
					//System.out.println("Article[" + article.getCode() + "]의 분석된 키워드를 DB 입력할 수 없음");
					//System.out.println(e.getMessage());
				}
			}
			
		}
		
		
		writeHistory("unprocessed data: " + unanalyzeArticle 
				+ "\n new processed data: " + analyzeArticle
				+ "\n processed data: (" + getAnalyzedArticle() + "/" + getTotalArticleData() + ")");
		
		for (Integer code:unanalyzeArticleCode) {
			writeHistory("\t - code: " + code);
		}
	}
	
	private int getAnalyzedArticle() {
		return articleDao.getAnalyzedArticle();
	}
	
	private int getTotalArticleData() {
		return articleDao.getTotalArticleData();
	}
}
