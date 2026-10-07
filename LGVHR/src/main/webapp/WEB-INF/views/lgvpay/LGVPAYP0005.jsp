<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAYP0005.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Code List를 조회하는 팝업 화면입니다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="Code"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAYP0005 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	var codePopData = myForm.getParent().popupInfo.codePopup;
	
	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".searchBlock").parents("._div_popup_holder_").css({"width": "512px", "height":"412px"});
	
    // 화면 레이아웃 정의(달력 그린 후 레이아웃 지정하기 위해 마지막에 수행함.)
	myForm.setLayout( [
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },
		{ name : "contentBlock", left : 0, right : 0, top : "searchBlock",  bottom : "controlBlock" },
	    { name : "controlBlock", left : 0, right : 0, bottom : 0 }
	]);

    // 그리드선언
	var grid = buildGrid(".listGrid");
	// 체크박스 숨기기
	grid.getGridBase().setCheckBar({visible:false});

    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
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
				fncRetrieveCodeList();
				break;
			case 'ok':
				fncAddDataList(grid.getGridBase().getValues(grid.getGridBase().getCurrent().itemIndex));
				Popup.closePopup(myForm,true);
				break;
			case 'cancel':
				Popup.closePopup(myForm);
				break;
		}
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/*** 내부 함수  ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
			{ fieldName:'commonCode' , dataType:'text'  },
			{ fieldName:'commonCodeName'     , dataType:'text'  }
		]);
		// Grid Column Set
		grid.setColumns([
			{
				name:'commonCode',
				fieldName:'commonCode',
				width:150,
				header: {text:'<lgcom:message code="Code"/>'},
				editable: false
			},
			{
				name:'commonCodeName',
				fieldName:'commonCodeName',
				width:200,
				header: {text:'<lgcom:message code="CommonCodeDesc"/>'},
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
			display: { fitStyle: 'auto' }
		});
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
	//행 더블클릭 이벤트
	grid.getGridBase().onDataCellDblClicked = function(cgrid, index) {
		fncAddDataList(cgrid.getValues(index.itemIndex));
		Popup.closePopup(myForm,true);
	};
	// parent화면에 Data Bind
	function fncAddDataList(jsonData) {
		if ( codePopData.codeData ) {
			codePopData.codeData = [];
		}
		codePopData.codeData.push(jsonData);
	}
	//데이터 조회
	function fncRetrieveCodeList() {
		grid.getGridBase().cancel();
		grid.loadData("lgvhr", "lgvpay/LGVPAYP0005/retrieveCodeList", srchFormUtil.getValue());
	}
	
	if ( codePopData ) {
		//검색조건 기본값 셋팅
		srchFormUtil.setValue({ 
			codeTypeCode   : nvl(codePopData["codeTypeCode"])
		  , commonCodeName : nvl(codePopData["commonCodeName"])
		});
	    //팝업 데이터 조회할지 여부
	    if ( nvl(codePopData["searchFlag"]) == "Y" ) {
	    	myForm.select(".searchBlock button[data-action='search']").trigger('click');
	    }
	}
}

LGVPAYP0005.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAYP0005();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="Code"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<input type="hidden" name="codeTypeCode" />
				<table class="table" >
					<colgroup>
						<col width="050"></col>
						<col width="100"></col>
						<col width="090"></col>
						<col width="120"></col>
						<col width="*"></col>
					</colgroup>
					<tbody>
						<tr>
		                	<th><label><lgcom:message code="Code" /></label></th>
							<td><input type="text" class="form-control input-sm" name="commonCode" /></td>
		                	<th><label><lgcom:message code="CommonCodeDesc" /></label></th>
							<td><input type="text" class="form-control input-sm" name="commonCodeName" /></td>
		                	<td></td>
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- //searchBlock --%>

		<div class="contentBlock grid-wrap">
			<div class="grid listGrid"></div>
		</div>

		<div class="controlBlock modal-footer">
			<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="ok"><lgcom:message code="ok"/></button>
			<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>
		</div>
		
	</section>
</div>
</body>
</html>
