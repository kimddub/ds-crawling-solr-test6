package com.company.demo.service;

import java.util.List;
import java.util.Map;

import com.company.demo.dto.Article;

public interface ArticleService {

	public List<Article> getArticles(Map<String, Object> param);

}
