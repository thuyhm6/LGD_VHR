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
    파일명 : LGVATT50040.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Setup OT level
    작성자 : HMS
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVATT50040 = function() {
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
	
	transaction_sync( "lgvhr","lgvatt/LGVATT50030/retrieveAttendanceYyyymm", {}, function(data) {
    	if ( data.result ) {
    		yyyymmList = data.result.yyyymmList;
    		
    		formUtil.initCombo("timeAndAttendanceYyyymm", data.result.yyyymmList,   {selectAll:false});
    		formUtil.setValue({timeAndAttendanceYyyymm: data.result.currentYyyymmData.attendanceYyyymm});
    	}
    });
	
	// 그리드 선언
	var grid = buildGrid('.otLevelManageGrid');

	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	search();
	
	this.addEvent('change',"select[name='timeAndAttendanceYyyymm']",function(event) {
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
				var yearMonth = $.trim(myForm.select(".searchBlock select[name='timeAndAttendanceYyyymm']").val());
				
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
					/*입력년도가 다를경우 alert
					if(yearMonth != creatMonth) {
						var otherYear = cgrid.getValue(i,'creationDate');
						Message.alert('<lgcom:message code="error.noSameYear" arguments="'+otherYear+'"/>');
						return;
					}
					*/
					recpmap.put(cgrid.getValue(i,'creationDate'),1);
				}
				Message.confirm('<lgcom:message code="question.save"/>', function() {
						
					grid.useProgress(true);
					grid.saveChanges('lgvhr','lgvatt/LGVATT50040/saveOtLevelManage', function(data, gridData ) {
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
		    { fieldName: 'otLevelId'                , dataType:'text'},
		    { fieldName: 'timeAndAttendanceYyyymm'  , dataType:'text'},
		    { fieldName: 'shiftTypeCode'            , dataType:'text'},
		    { fieldName: 'shiftTypeName'            , dataType:'text'},
		    { fieldName: 'otLevel'                  , dataType:'text'},
		    { fieldName: 'levelName'                , dataType:'text'},
		    { fieldName: 'lowerLimit'               , dataType:'text'},
		    { fieldName: 'upperLimit'               , dataType:'text'},
		    { fieldName: 'otCategory'               , dataType:'text'},
		    { fieldName: 'remark   '                , dataType:'text'},
		    { fieldName: 'creationDate'         	, dataType:'text'},
		    { fieldName: 'creationUserId'         	, dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookupsMultiLvl({
		});
		
		//Shift type 
		var parameter = {codeTypeCode: 'LGVHR_GROUP_TYPE_CODE', languageCode:SESSION_USER.languageCode};
		transaction_sync("lgvhr", "lgvatt/LGVATT50040/retrieveCodeType", parameter, function(data){
			var shiftTypeList = data.result;	
			$(shiftTypeList).each( function(){
				shiftTypeCodeList.push(this.code);
				shiftTypeNameList.push(this.name);
			});
		});
		//overtime level 
		var param = {codeTypeCode: 'LGVHR_OT_LEVEL', languageCode:SESSION_USER.languageCode};
		transaction_sync("lgvhr", "lgvatt/LGVATT50040/retrieveCodeType", param, function(data){
			var levelList = data.result;	
			$(levelList).each( function(){
				levelCodeList.push(this.code);
				levelNameList.push(this.name);
			});
		});
		
		//컬럼 설정
		grid.setColumns([
				{
					name:'otLevelId',
					fieldName:'otLevelId',
					width:0,
					header: {text:'<lgcom:message code="label.att.lowerLimit" />'},
					styles: {textAlignment:'center'}
				},
				{
					name:'shiftTypeCode',
					fieldName:'shiftTypeCode',
					width:100,
					header: {text:'<lgcom:message code="label.pay.shiftType" />'},
					styles: {textAlignment:'near'},
					lookupDisplay: true,
					styles: {textAlignment:'center'},
					values:shiftTypeCodeList,
					labels:shiftTypeNameList,
					editor: {type:'dropDown', textReadOnly : true,editable: true}
				},
				{
					name:'otLevel',
					fieldName:'otLevel',
					width:100,
					header: {text:'<lgcom:message code="label.att.level"/>'},
					styles: {textAlignment:'near'},
					lookupDisplay: true,
					values:levelCodeList,
					labels:levelNameList,
					editor: {type:'dropDown', textReadOnly : true,editable: true}
				},
				{
					name:'lowerLimit',
					fieldName:'lowerLimit',
					width:100,
					header: {text:'<lgcom:message code="label.att.lowerLimit" />'},
					styles: {textAlignment:'center'}
				},
				{
					name:'upperLimit',
					fieldName:'upperLimit',
					width:100,
					header: {text:'<lgcom:message code="label.att.upperLimit" />'},
					styles: {textAlignment:'center'}
				},
				{
					name:'otCategory',
					fieldName:'otCategory',
					width:300,
					header: {text:'<lgcom:message code="label.att.actualAttendanceType" />'},
					styles: {textAlignment:'center'}
				},
				{
					name:'remark',
					fieldName:'remark',
					width:400,
					header: {text:'<lgcom:message code="Remark" />'},
					styles: {textAlignment:'center'}
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
			 					{criteria: "value['shiftTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.shiftType'/>"/>',mode:'always',level:'error'},
			 					{criteria: "value['otLevel'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.level'/>"/>',mode:'always',level:'error'},
			 					{criteria: "value['lowerLimit'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.lowerLimit'/>"/>',mode:'always',level:'error'}
			 				]);
		return grid;
	}
	
	function search() {
		grid.getGridBase().cancel();
		var param = formUtil.getValue();
		grid.loadData('lgvhr','lgvatt/LGVATT50040/retrieveOtLevel', param);
		
		var parameter = {codeTypeCode : 'LGVHR_GROUP_TYPE_CODE', languageCode : SESSION_USER.languageCode};
		transaction_sync("lgvhr", "lgvatt/LGVATT50040/retrieveCodeType", parameter, function(data){
			shiftTypeList = data.result;
		});
		var param = {codeTypeCode : 'LGVHR_OT_LEVEL', languageCode : SESSION_USER.languageCode};
		transaction_sync("lgvhr", "lgvatt/LGVATT50040/retrieveCodeType", param, function(data){
			levelList = data.result;
		});
		
		grid.setLookupsMultiLvl({
	    	'shiftTypeName' : shiftTypeList,
	    	'levelName' : levelList
	    });
	}
}
LGVATT50040.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT50040();
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
		                    <th><label class="required"><lgcom:message code="label.att.month"/></label></th>
		                    <td>
		                        <div class="form-inline ">
                                	<select class="form-control input-sm input-require" name="timeAndAttendanceYyyymm" id="timeAndAttendanceYyyymm"></select>
                            	</div>
		                    </td>
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
			<div class="grid otLevelManageGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
