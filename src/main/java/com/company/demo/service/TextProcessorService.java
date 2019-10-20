package com.company.demo.service;

import java.util.Date;
import java.util.List;
import java.util.Map;

import com.company.demo.dto.Article;

public interface TextProcessorService {

	public void resetKeyword();
	
	public List<Map<String, Object>> getAnalyzedData(Map<String, Object> param);
	
	public void analyzeArticleText();

}
