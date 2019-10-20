package com.company.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableScheduling
@SpringBootApplication
public class DsCrawlingSolrTest6Application {

	public static void main(String[] args) {
		SpringApplication.run(DsCrawlingSolrTest6Application.class, args);
	}

}
