package com.company.demo.repository;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.solr.repository.Query;
import org.springframework.data.solr.repository.SolrCrudRepository;
import org.springframework.stereotype.Repository;

import com.company.demo.dto.Article;

@Repository
@Qualifier("solrArticleRepo")
public interface SolrArticleRepository extends SolrCrudRepository<Article, String> {

    @Query(value = "*:*")
    public List<Article> test(Map<String, Object> param);
    
    @Query(value = "title:?0 or body:?0")
	List<Article> getArticles(String keyword);

}

//public interface SolrArticleRepository extends SolrCrudRepository<Article, String>{
//	
//	Page<Content> findByPriority(Integer priority, Pageable page);
//
//	Page<Content> findByHeadingOrDescription(@Boost(2) String heading, String description, Pageable page);
//
//	@Highlight(prefix = "<highlight>", postfix = "</highlight>")
//	HighlightPage<Content> findByCityIn(Collection<String> city, Page page);
//
//	@Query(value = "name:?0")
//	@Facet(fields = { "cat" }, limit=20)
//	FacetPage<Content> findByLocalityAndFacetOnCity(String locality, Pageable page);
//}