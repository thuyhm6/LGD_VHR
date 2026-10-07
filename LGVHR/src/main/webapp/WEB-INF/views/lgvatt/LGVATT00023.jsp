<%@ page import="java.util.Comparator"%>
<%@ page import="java.util.List"%>
<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn"    uri="http://java.sun.com/jsp/jstl/functions"%>

<jsp:useBean id="date" class="java.util.Date" />
<fmt:formatDate value="${date}" pattern="yyyy" var="currentYear" />

<%---------------------------------------------------------
    파일명 : LGVATT00023.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Vendor Infomation
    작성자 : HMS_20260401
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVATT00023 = function() {
	var myForm = this;
	var date = new Date();
	var year = date.getFullYear();
	var month = date.getMonth()+1;
	var day = date.getDate();
	
	if(("" + month).length == 1){month = "0" + month;}
	if(("" + day).length == 1){day = "0" + day;}
	
	var dateVal = day+"/"+month+"/"+year;
	
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
	myForm.setLayout( [ 
		{ name : "searchBlock", left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);
	// 그리드 선언
	var grid = buildGrid('.vendorInfomationGrid');

	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	search();
	
	this.addEvent('change',"select[name='vendorName']",function(event) {
		search();
	});
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
			case 'search':
				search();
				
				break;
			case 'insert':
				var grid1 = grid.getGridBase();
				grid1.commit();
				var subsidiaryCode = '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}';
				var currIdx = grid1.getCurrent().itemIndex;
				var itemCnt = grid1.getItemCount();
				var dataRowIdx = grid1.getCurrent().dataRow;
				var provider = grid1.getDataProvider();

				if(grid.getGridBase().getCurrent().itemIndex < 0) {
					grid1.beginAppendRow();
					grid1.setValue(0, 'creationUserId',$.trim(SESSION_USER.fullNameLocal));
					grid1.setValue(0, 'creationDate',dateVal);
				} else {
					grid1.beginInsertRow(currIdx);
					grid1.setValue(currIdx, 'creationUserId',$.trim(SESSION_USER.fullNameLocal));
					grid1.setValue(currIdx, 'creationDate',dateVal);
				}
				grid1.setFocus();
				
				break;
			case 'save':
				var grid1 = grid.getGridBase();
				var vendorName = $.trim(myForm.select(".searchBlock select[name='vendorName']").val());
				
				try {
					grid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if( grid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				if(!grid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				var cgrid = grid.getGridBase();
				var tocnt = 0;
				var recpmap = new Map();
				for(var i=0; i < cgrid.getItemCount(); i++) {
					// 삭제건은 제외
					if(cgrid.getDataProvider().getRowState(cgrid.getDataRow(i)) == 'deleted') continue;
					var creatMonth = cgrid.getValue(i,'creationDate').substr(6,4) + cgrid.getValue(i,'creationDate').substr(3,2);
					recpmap.put(cgrid.getValue(i,'creationDate'),1);
				}
				Message.confirm('<lgcom:message code="question.save"/>', function() {
						
					grid.useProgress(true);
					grid.saveChanges('lgvhr','lgvatt/LGVATT00023/saveVendorInfomation', function(data, gridData ) {
						Message.alert('<lgcom:message code="note.completed"/>');
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				break;
			case 'delete':
				grid.getGridBase().deleteSelection(true);
				break;
		}
	});
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/***  내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var shiftTypeCodeList = new Array();
        var shiftTypeNameList = new Array();
		var levelCodeList = new Array();
        var levelNameList = new Array();
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		
		//필드 설정
		grid.setFields([
		    { fieldName: 'vendorId'                 , dataType:'text'},
		    { fieldName: 'vendorCode'               , dataType:'text'},
		    { fieldName: 'vendorName'               , dataType:'text'},
		    { fieldName: 'effectiveStartDate'       , dataType:'text'},
		    { fieldName: 'effectiveEndDate'         , dataType:'text'},
		    { fieldName: 'remark   '                , dataType:'text'},
		    { fieldName: 'creationDate'         	, dataType:'text'},
		    { fieldName: 'creationUserId'         	, dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookupsMultiLvl({
		});

		//컬럼 설정
		grid.setColumns([
				{
					name:'vendorId',
					fieldName:'vendorId',
					width:0,
					header: {text:'ID'},
					styles: {textAlignment:'center'}
				},
				{
					name:'vendorCode',
					fieldName:'vendorCode',
					width:100,
					header: {text:'<lgcom:message code="label.att.vendorCode" />'},
					styles: {textAlignment:'center'}
				},
				{
					name:'vendorName',
					fieldName:'vendorName',
					width:300,
					header: {text:'<lgcom:message code="label.att.vendorName" />'},
					styles: {textAlignment:'center'}
				},
				{
					name:'remark',
					fieldName:'remark',
					width:400,
					header: {text:'<lgcom:message code="Remark" />'},
					styles: {textAlignment:'center'}
				},
				{	name:'effectiveStartDate', 
					fieldName:'effectiveStartDate', 
					width:180,
					header: {text:'<lgcom:message code="label.att.effectiveStartDate" />', required : true},
					styles: {textAlignment:'center'},
					editor: {type:'date', datetimeFormat:'dd/MM/yyyy'}
				},
				{	name:'effectiveEndDate', 
					fieldName:'effectiveEndDate', 
					width:180,
					header: {text:'<lgcom:message code="label.att.effectiveEndDate" />'},
					styles: {textAlignment:'center'},
					editor: {type:'date', datetimeFormat:'dd/MM/yyyy'}
				},
				{
					name:'creationDate',
					fieldName:'creationDate',
					width:200,
					header: {text:'<lgcom:message code="label.att.creationDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'creationUserId',
					fieldName:'creationUserId',
					width:200,
					header: {text:'<lgcom:message code="label.att.createBy" />'},
					styles: {textAlignment:'near'},
					editable : false
				}
		]);
		//옵션 설정
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:true,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				paste: {enabled:false}, /*paste 기능막기 */
				sorting  : {enabled:false}, /*Sorting 기능을 막는다.*/
                sortMode : "explicit",
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				}
			},
			dataProvider: {
				insertable: true,
				updatable: true,
				deletable: true,
				softDeleting: true,
				deleteCreated: true
			}
		});
		
		// Context Menu Set
		grid.setContextMenu();

		grid.setValidations([
			 					{criteria: "value['vendorCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.vendorCode'/>"/>',mode:'always',level:'error'},
			 					{criteria: "value['vendorName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.vendorName'/>"/>',mode:'always',level:'error'}
			 				]);
		return grid;
	}
	
	function search() {
		grid.getGridBase().cancel();
		var param = formUtil.getValue();
		grid.loadData('lgvhr','lgvatt/LGVATT00023/retrieveVendorInfomation', param);
	}
}
LGVATT00023.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT00023();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2></h2> 
		</div>
		<div class="searchBlock">
			<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="90"/>
						<col width="220"/>
						<col width="60"/>
						<col width="*"/>
					</colgroup>
					<tbody>
						<tr>
		                    <th><label class="required"><lgcom:message code="label.att.vendorName"/></label></th>
		                    <td><input type="text" class="form-control input-sm" name="vendorName"></td>
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- 그리드 버튼 영역 --%>
	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">
			<div class="btn-group">
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert">
					<span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete">
					<span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
			</div>
			<div class="btn-group">					      
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
			</div>
		</div>
	</div>
		<div class="gridContent grid-wrap">
			<div class="grid vendorInfomationGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
