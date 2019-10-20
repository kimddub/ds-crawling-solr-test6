package com.company.demo.dto;

import java.util.Date;
import java.util.Map;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Category {
	private int code;
	private String sectionId;
	private String subSectionId;
	private String section;
	private String subSection;
	private int siteCode;
	private boolean popState;
}
