<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ include file="../part/header.jspf"%>

<style>
	
	.DS_logo-box > img {
		margin:30px auto;
		display:block;
		width:300px;
	}
	
	.DS_btn-line {
		margin:30px;
		text-align:center;
	}
	
	.DS_btn-line #DS_btn{
		background-color:#061639;
		color:white;
		border-radius:5px;
	}
	
</style>
		
		<div class="DS_btn-line">
			<button class="main_btn" onclick="location.href='../home/crawlingData';">뉴스 수집 조회</button>
			<button class="main_btn" onclick="location.href='../home/analyzedData';">이슈 키워드 조회</button>
		</div>
		
			</br>
			<h1>"데이터 크롤링과 분석 결과를 확인하세요"</h1>
			<span>웹 상의 광범위한 데이터들을 직접 확인하기란 어렵습니다.</br></br>
			각종 사이트와 다양한 카테고리에서 컨텐츠들을 수집하고,</br>
			자연어 처리를 통한 단어를 분석하고 저장하여 제공합니다.</br></br>
			몇건의 데이터가 수집되었는지 어제의 이슈 키워드는 무엇이었는지</br>
			간단한 검색만으로 보기 쉬운 차트에서 확인 할 수 있습니다.</br></br>
			</span>
			
			<div>
				</br>
				<div class="DS_logo-box">
					<img alt="logo" src="/image/logo.png">
				</div>
				</br>
			</div>
			
			



<%@ include file="../part/footer.jspf"%>