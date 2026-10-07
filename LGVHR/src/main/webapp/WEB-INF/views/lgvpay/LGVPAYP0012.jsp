<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAYP0012.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Payment Master by Employee-Dependant Info 조회하는 팝업 화면입니다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.dependantInfo"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAYP0012 = function() {
	var myForm = this;
	// Form Util 선언
	
	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".contentBlock").parents("._div_popup_holder_").css({"width": "800px", "height":"494px"});
	
    // 화면 레이아웃 정의(달력 그린 후 레이아웃 지정하기 위해 마지막에 수행함.)
	myForm.setLayout( [
		{ name : "contentBlock", left : 0, right : 0, top : 0,  bottom : 0 }
	]);

    // 그리드선언
	var grid = buildGrid(".listGrid");
	// 체크박스 숨기기
	grid.getGridBase().setCheckBar({visible:false});

    // 개인화조건
    
    // 조회조건 저장 처리
    //myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)

    // 그리드형 테이블 TR
    
    // 코드 데이터 조회
	
	//콤보 초기화
	
    // 날짜 팝업창
    
    // 필수항목 체크

    // 일반함수	
    
    // Event 처리
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}                                                                                                                                                                                                                                             
		var action = $.trim(item.data('action'));
		switch( action ){
			case "search" :
				fncRetrieveDependantList();
				break;
		}
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	/*** 내부 함수  ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
			{ fieldName:'employeeNo'       , dataType:'text'  },
			{ fieldName:'familyName'       , dataType:'text'  },
			{ fieldName:'relationDesc'	   , dataType:'text'  },
			{ fieldName:'relationStartDate', dataType:'text'  },
			{ fieldName:'dependentFlag'	   , dataType:'text'  }
		]);
		// Grid Column Set
		grid.setColumns([
			{
				name:'familyName',
				fieldName:'familyName',
				width:100,
				header: {text:'<lgcom:message code="label.pay.dependantName"/>'},
				editable: false
			}
			,
			{
				name:'relationDesc',
				fieldName:'relationDesc',
				width:100,
				header: {text:'<lgcom:message code="label.pay.relation"/>'},
				editable: false
			}
			,
			{
				name:'relationStartDate',
				fieldName:'relationStartDate',
				width:100,
				header: {text:'<lgcom:message code="label.pay.relationStartDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			}
			,
			{
				name:'dependentFlag',
				fieldName:'dependentFlag',
				width:100,
				header: {text:'<lgcom:message code="label.pay.dependantFlag"/>'},
				styles: {textAlignment:'center'},
				editable: false
			}
		]);
		// Grid Option Set
		grid.setOptions({
			grid: {
				hideDeletedRows: true,
				indicator: {visible:false},
				panel: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
	            sortMode : "explicit",
				edit: {
					insertable: false, /* INSERT 키 또는 방향키로 행삽입 불가능 */
					appendable: false, /* INSERT 키 또는 방향키로 행추가 불가능 */
					updatable: true,
					deletable: true
				},
				header: {
					height: 30
				}
			},
			dataProvider: {
				insertable: true,
				updatable: true,
				deletable: true,
				softDeleting: true,
				deleteCreated: true
			},
			display: { fitStyle: 'evenFill' }
		});
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
	//데이터 조회
	function fncRetrieveDependantList() {
		grid.getGridBase().cancel();
		grid.loadData("lgvhr", "lgvpay/LGVPAYP0012/retrieveDependantList", { employeeNo : nvl(popupData["employeeNo"]) });
	}
	
	var popupData = myForm.getParent().popupInfo.dependantPopup;
	if ( popupData ) {
	    //팝업 데이터 조회할지 여부
	    if ( nvl(popupData["searchFlag"]) == "Y" ) {
	    	fncRetrieveDependantList();
	    }
	}
}

LGVPAYP0012.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAYP0012();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.dependantInfo"/></h2>
		</div>

		<div class="contentBlock grid-wrap">
			<div class="grid listGrid"></div>
		</div>
		
	</section>
</div>
</body>
</html>
