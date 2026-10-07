<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00093.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Dynamic Query Input Parameter Popup
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

var LGUTLC00093 = function() {
	var myForm = this;
	var _popupInfo;
	myForm.popupInfo = {};

	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.dataBlock form');
	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		dataBlock:{ left:10, top:0 , right:10 },
		controls :{ left:10, right:10 , bottom:0, height:28 }
	});
	*/
	myForm.setLayout( [ 
		           		{ name : "dataBlock",  left : 0, right : 0, top : 0, bottom : "controls" },		
		           		{ name : "controls", left : 0, right : 0, bottom : 0}
		               ]);	
	
	/*** OnLoad 이벤트 **/
	myForm.initMyForm = function() {
		_popupInfo = myForm.getParent().popupInfo;
		// Dynamic Query Parameter를 조회한다.
		transaction_sync(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00090/retrieveParamValueListForInput',{queryId:$.trim(_popupInfo['queryId'])},function(data) {
			if(data.result) {
				myForm.select(".dataBlock form table tbody").empty();
				var list = data.result;
				if(list.length == 0) {
					_popupInfo['selData'] = {};
					Popup.closePopup( myForm, true);
					return;
				}
				for(var i=0; i < list.length; i++) {
					var tr = $('<tr></tr>');
					var th = $('<th></th>');
					th.attr('scope','col');
					th.html(list[i].paraName);
					tr.append(th);
					var td = $('<td></td>');
					if($.trim(list[i].isCodeType) == 'Y') {
						var div = $('<div></div>');
						div.addClass('input-group');
						div.addClass('input-group-sm');
						div.addClass('input-search');
						if($.trim(list[i].requiredFlag) == 'Y') {
							div.addClass('input-require');
						}
						var input = $('<input type="text"/>');
						input.attr('name',$.trim(list[i].paraName));
						input.addClass('form-control');
						input.val($.trim(list[i].initialValue));
						div.append(input);
						var span = $('<span></span>');
						span.addClass('input-group-btn');
						var button = $('<button></button>');
						button.attr('type','button');
						button.addClass('btn');
						button.addClass('btn-default');
						button.addClass('ico-lgd');
						button.addClass('find');
						button.attr('data-action','popup');
						button.attr('data-query-id',$.trim(list[i].queryId));
						button.attr('data-para-name',$.trim(list[i].paraName));
						button.html($('<span class="fa fa-search" aria-hidden="true"></span>'));
						span.append(button);
						div.append(span);
						td.append(div);
					}
					// Parameter Type이 Date일 경우
					else if($.trim(list[i].paraType) == 'D') {
						var div = $('<div></div>');
						div.addClass('form-inline');
						var input = $('<input type="text"/>');
						input.addClass('form-control');
						input.addClass('input-sm');
						input.addClass('date');
						input.addClass('text-center');
						input.addClass('size_80');
						if($.trim(list[i].requiredFlag) == 'Y') {
							input.addClass('input-require');
						}
						input.attr('name',$.trim(list[i].paraName));
						input.val($.trim(list[i].initialValue));
						var button = $('<button></button>');
						button.addClass('btn');
						button.addClass('btn-ico');
						button.attr('aria-label','calendar');
						button.attr('type','button');
						var inspan = $('<span></span>');
						inspan.addClass('ico');
						inspan.addClass('ico-calendar');
						inspan.attr('aria-hidden','true');
						button.append(inspan);
						// Calendar Bind
						uxp.datepicker.single( $(button), $(input), { language:SESSION_USER.languageCode, format: 'YYYYMMDD' } );
						div.append(input);
						div.append(button);
						td.append(div);
					}
					// Parameter Type이 Date Time 일 경우
					else if($.trim(list[i].paraType) == 'DT') {
						var div = $('<div></div>');
						div.addClass('form-inline');
						var input = $('<input type="text"/>');
						input.addClass('form-control');
						input.addClass('input-sm');
						if($.trim(list[i].requiredFlag) == 'Y') {
							input.addClass('input-require');
						}
						if($.trim(list[i].paraType) == 'D') {
							input.addClass('size_100');
						}
						input.attr('name',$.trim(list[i].paraName));
						input.val($.trim(list[i].initialValue));
						var button = $('<button></button>');
						button.addClass('btn');
						button.addClass('btn-ico');
						button.attr('aria-label','calendar');
						button.attr('type','button');
						var inspan = $('<span></span>');
						inspan.addClass('ico');
						inspan.addClass('ico-calendar');
						inspan.attr('aria-hidden','true');
						button.append(inspan);
						div.append(input);
						div.append(button);
						td.append(div);
					}
					else {
						var input = $('<input type="text"/>');
						input.addClass('form-control');
						input.addClass('input-sm');
						if($.trim(list[i].requiredFlag) == 'Y') {
							input.addClass('input-require');
						}
						input.attr('name',$.trim(list[i].paraName));
						input.val($.trim(list[i].initialValue));
						td.append(input);
					}
					tr.append(td);
					myForm.select(".dataBlock form table tbody").append(tr);
				}
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
			case 'ok':
				/* 필수입력 항목 체크 */
				var msg;
				myForm.select('.dataBlock form table .input-require').each(function(idx) {
					var itemVal;
					if($(this)[0].tagName.toUpperCase() == 'DIV') {
						itemVal = $.trim($(this).find("input[type='text']").val());
					} else {
						itemVal = $.trim($(this).val());
					}
					if(itemVal == '') {
						var itemName;
						if($(this).parent()[0].tagName.toUpperCase() == 'DIV') {
							itemName = $.trim($(this).parent().parent().prev().html());
						} else {
							itemName = $.trim($(this).parent().prev().html());
						}
						msg = {};
						msg['itemName'] = itemName;
						msg['inputName'] = $.trim($(this).attr('name'));
						return false;
					}
				});
				if(typeof(msg) != 'undefined') {
					Message.alert('<lgcom:message code="error.required" arguments="'+msg.itemName+'"/>');
					myForm.select(".dataBlock form table input[name='"+msg.inputName+"']").focus();
					return;
				}
				_popupInfo['selData'] = formUtil.getValue();
				Popup.closePopup( myForm, true);
				break;
			case 'cancel':
				Popup.closePopup( myForm );
				break;
		}
	});
	// Parameter Search Popup
	myForm.addEvent('click',"button[data-action='popup']",function(event) {
		var queryId = $.trim($(this).data('queryId'));
		var paraName = $.trim($(this).data('paraName'));
		trace($(this).parent().prev().val());
		myForm.popupInfo['queryId'] = queryId;
		myForm.popupInfo['paraName'] = paraName;
		myForm.popupInfo['keyword'] = $.trim($(this).parent().prev().val());
		var lpop = new Popup(myForm,DQ_CONTEXT_PATH,'M_LGUTLC_1156',paraName+' <lgcom:message code="lSearch"/>');
		lpop.setSize(450,400);
		lpop.open(function() {
			myForm.select(".dataBlock form input[name='" + paraName + "']").val($.trim(myForm.popupInfo.row.code));
		});
	});
	// Parameter Search Popup
	myForm.addEvent('click',"button[aria-label='calendar']",function(event) {

	});
};

LGUTLC00093.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGUTLC00093();
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
		<h2>Input Dynamic Query Parameter</h2>
	</div>
	<div class="dataBlock" >
		<form action="" class="form">
			<table class="table table-condensed">
				<colgroup>
					<col width="35%"/>
					<col width="*"/>
				</colgroup>
				<tbody>
				</tbody>
			</table>
		</form>
		<%-- Form 영역 --%>
		<form class="form" method="post" action="">
			<input type="hidden" name="queryId" value=""/>
		</form>
	</div>
	<%-- 서버 버튼 영역 --%>
	<div class="controls modal-footer">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="ok"><lgcom:message code="ok"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel"><lgcom:message code="cancel"/></button>
	</div>
	</section>
</div>
</body>
</html>
