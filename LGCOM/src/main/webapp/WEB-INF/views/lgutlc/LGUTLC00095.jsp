<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00095.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Dynamic Query 미리보기 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Dynamic Query</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
/**
 * TODO DQ 프로그램 복제시 해당 Context 명을 변경함으로써 적용가능하다.
 */
var DQ_CONTEXT_PATH = 'lgcom';

var LGUTLC00095 = function() {
	var myForm = this;
	var _popupInfo;
	var formUtil = new FormUtil(myForm,'.dataBlock form');
	
	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		dataBlock:{ left:10, top:0 , right:10 },
		controls :{ left:10, right:10 , bottom:0, height:28 }
	});
	*/
	myForm.setLayout( [ 
		           		{ name : "dataBlock", left : 0, right : 0, top : 0},
		           		{ name : "controls",  left : 0, right : 0, top : "dataBlock", bottom : 0 }		
		               ]);	
	/*** OnLoad 이벤트 **/
	myForm.initMyForm = function() {
		_popupInfo = myForm.getParent().popupInfo;
		// Query ID 세팅
		formUtil.setValue({queryId: $.trim(_popupInfo['queryId'])});
		var param = {
			queryMode: 'VIEW',
			queryId: $.trim(formUtil.getValue('queryId')),
			sqlArg: {}
		};
		if(_popupInfo.selData) {
			for(key in _popupInfo.selData) {
				param['sqlArg'][key] = $.trim(_popupInfo.selData[key]);
			}
		}
		// Dynamic Query Preview를 조회한다.
		transaction_sync(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00090/retrieveDynamicQueryPreview',param,function(data) {
			if(data.result) {
				formUtil.setValue({generatedQuery: $.trim(data.result.generatedSql)});
				myForm.select(".dataBlock form textarea[name='generatedQuery']").select();
			}
		});
	};
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'close':
				Popup.closePopup( myForm, true);
				break;
		}
	});
};

LGUTLC00095.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGUTLC00095();
		form.init();
		form.initMyForm();
	});
});
</script>
</head>

<body>
<div class="mdi-container popup">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Preview Dynamic Query</h2>
	</div>
	<div class="dataBlock">
		<form class="form" method="post" action="">
			<input type="hidden" name="queryId" value=""/>
			<textarea name="generatedQuery" class="form-control input-sm" style="height:500px;" data-action="previewQuery"></textarea>
		</form>
	</div>
	<%-- 서버 버튼 영역 --%>
	<div class="controls modal-footer">
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="close"><lgcom:message code="Close"/></button>
	</div>
	</section>
</div>
</body>
</html>
