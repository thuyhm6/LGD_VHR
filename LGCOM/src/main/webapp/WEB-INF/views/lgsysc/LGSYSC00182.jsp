<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSYSC00182.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본화면은 메뉴 검색 Popup 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Menu Search</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
.menuTree {
	height:100%;
	padding:10px;
	overflow:auto;
}
</style>
<script type="text/javascript">
var LGSYSC00182 = function() {
	var myForm = this;
	var _popupInfo;
	var selectData;
	// 팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".searchBlock").parents("._div_popup_holder_").css({"width": "470px", "height":"450px"});
	

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "controls1", left : 0, right : 0, top : "searchBlock", bottom : "content"},
		{ name  : "content", left : 0, right : 0, top : "controls1", bottom : "controls"},
		{ name  : "controls2", left : 0, right : 0, bottom : 0 }	 	
	]);
    
	var formUtil = new FormUtil( myForm, ".searchBlock form");
	//공통코드 정보를 인출
	var code = new CommonCode('lgcom');
	code.add('LGCOM_SYSTEM_CODE', {codeTypeCode:'LGCOM_SYSTEM_CODE' });
	code.add('LGCOM_MODULE_CODE', {codeTypeCode:'LGCOM_MODULE_CODE' });
	code.execute();
	// 조회블럭의 정보를 입력하기 위한 Form 을 다루는 FormUtil
	formUtil.initCombo('systemCode', code.get("LGCOM_SYSTEM_CODE"));
	formUtil.initCombo('moduleCode', code.get("LGCOM_MODULE_CODE"), {selectAll:true,filter:'systemCode'});
	/* JS Tree 선언 */
	var tree = myForm.select('.content .menuTree').jstree({
		core: {
			multiple:false,
			animation:0,
			themes: {icons:false},
			expand_selected_onload: true
		}
	});
	/* Tree Event Bind */
	tree.bind('select_node.jstree',function(event,data) {
		if($.trim(data.node.original.type) == 'leaf') {
			selectData = {};
			selectData['menuId'] = $.trim(data.node.id);
			selectData['menuName'] = $.trim(data.node.text);
		} else {
			selectData = {};
		}
	});
	myForm.initForm = function() {
		// Popup 정보 받기
		_popupInfo = myForm.getParent().popupInfo.menuPopup;
		if($.trim(_popupInfo['systemCode']) != '') {
			formUtil.setValue('systemCode',$.trim(_popupInfo['systemCode']));
		}
		if($.trim(_popupInfo['moduleCode']) != '') {
			formUtil.setValue('moduleCode',$.trim(_popupInfo['moduleCode']));
		}
		if($.trim(_popupInfo['menuName']) != '') {
			//formUtil.setValue({menuName:$.trim(_popupInfo['menuName'])});
		}
		myForm.select(".searchBlock form button[data-action='search']").trigger('click');
	};
	/* 버튼 제어 */
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'search':
				selectData = null;
				selectData = {};
				transaction('lgcom','lgsysc/LGSYSC00180/retrieveMenuList',formUtil.getValue(),function(data) {
					if(data.result) {
						var treeData = [];
						var firstMenuId;
						$(data.result).each(function(inx) {
							if(inx == 0) {
								firstMenuId = this["menuId"];
							}
							//각 레코드의 데이터 보정 및 정리
							if(!this["highMenuId"]) {
								this["highMenuId"] = "#"; // jsTree 는 root메뉴의 parent 가 # 이어야 한다.
							}
							this["status"] = "N";
							//각 레벨에 따라 type 을 지정한다.
							if( this["menuLevelNo"] == "1" ) {
								this["menuLevelType"] = "root";
							} else if( this["menuLevelNo"] == "2" ) {
								this["menuLevelType"] = "branch";
							} else if( this["menuLevelNo"] == "3" ) {
								this["menuLevelType"] = "leaf";
							}
							treeData.push({
								id : this["menuId"],
								parent : this["highMenuId"],
								text : this["menuName"],
								type : this["menuLevelType"]
							});
						});
						tree.jstree(true).settings.core.data = treeData;
						tree.jstree(true).refresh();
					}
				});
				break;
			case 'expand':
				if(tree) {
					tree.jstree('open_all');
				}
				break;
			case 'collapse':
				if(tree) {
					tree.jstree('close_all');
				}
				break;
			case 'ok':
				if(typeof(selectData) == 'undefined' || $.trim(selectData['menuId']) == '') {
					Message.alert('<lgcom:message code="note.nocheckdata"/>');
					return;
				}
				_popupInfo['selectedData'] = {
					menuId: $.trim(selectData['menuId']),
					menuName: $.trim(selectData['menuName'])
				};
				Popup.closePopup(myForm,true);
				break;
			case 'cancel':
				Popup.closePopup(myForm);
				break;
		}
	});
}

LGSYSC00182.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	//launch(function(){
		var form = new LGSYSC00182();
		form.init();
		form.initForm();
	//});
});
</script>
</head>

<body>
<div class="mdi-container popup">
  <section class="page-content">
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table" >
					<colgroup>
						<col width="70"/>
						<col width="90" />
						<col width="70"/>
						<col width="90" />
					</colgroup>
					<tbody>
						<tr>
							<th><label><lgcom:message code="System"/></label></th>
							<td><select class="form-control input-sm input-require" name="systemCode"></select></td>
							<th><label><lgcom:message code="Module"/></label></th>
							<td><select class="form-control input-sm" name="moduleCode"></select></td>
							<td rowspan="2"></td>
						</tr>
						<tr>
							<th><label><lgcom:message code="MenuName" /></label></th>
							<td colspan="3"><input type="text" class="form-control input-sm" name="menuName"></td>
						</tr>
					</tbody>
				</table>
			   <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>	
		</form>
	</div>
	<div class="controls controls1 module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">		
				<button type="button" class="btn btn-default btn-sm ico-lgd" data-action ="expand" data-toggle="tooltip" data-placement="left" title="<lgcom:message code="ExpendAll"/>"><i class="fa fa" aria-hidden="true" aria-hidden="true"></i><lgcom:message code="ExpendAll"/></button>
				<button type="button" class="btn btn-default btn-sm ico-lgd" data-action ="collapse" data-toggle="tooltip" data-placement="right" title="<lgcom:message code="CollapseAll"/>"><i class="fa fa-minus" aria-hidden="true" aria-hidden="true"></i><lgcom:message code="CollapseAll"/></button>
			</div>
		</div>			
	</div>
	
	<div class="content">
		<div class="menuTree"></div>
	</div>
	<div class="controls controls2 modal-footer">
		<button class="btn btn-darkgray btn-sm" type="submit" data-action="ok" ><lgcom:message code="ok" /></button>
		<button class="btn btn-dark btn-sm" href="#" role="button" data-action="cancel"><lgcom:message code="cancel" /></button>
	</div>
	</section>
</div>
</body>
</html>
