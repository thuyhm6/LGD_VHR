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
    파일명 : LGVATT50060.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Employee Unpaid Leave Warning
    작성자 : HMT_20251111
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVATT50060 = function() {
	var myForm = this;
	
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );
	var gridContent = new FormUtil(myForm,'.gridContent form');
	var searchForm = new FormUtil(myForm, '.search-wrap');
	//필수항목 체크
   	var validator = new Validator( myForm, srchForm );
	
	var dateFrom = DateUtil.format(DateUtil.today().set('date',1), 'DD/MM/YYYY');
    var dateTo = DateUtil.format(DateUtil.today().add(1,'month').set('date',1).add(-1,'day'), 'DD/MM/YYYY');
    searchForm.setValue( {
    	atendanceStartDate : dateFrom,
        atendanceEndDate : dateTo
    });
    searchForm.setCalendar( { from : "atendanceStartDate", to : "atendanceEndDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
    
	var sendEmailFlagList = [ {code: '1', name: 'Send'}, {code: '0', name: 'Not Send'}, {code: '', name: 'Send'} ];
	
    searchForm.initCombo( "sendEmailFlag", sendEmailFlagList, { selectAll: true });
	myForm.setLayout( [ 
		{ name : "searchBlock", left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);
	

	
	// 그리드 선언
	var grid = buildGrid('.empULWarningManageGrid');

	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	search();
	
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
			case 'sendEmail':
				fncSendEmail();
				break;
			case 'reject':
				fncCancelSendEmail('0');
				break;
			case 'reSend':
				fncCancelSendEmail('1');
				break;
				
			case 'excelDownload':
				if(validator.isValid()) {
					Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
						var param = srchFormUtil.getValue();
						var downloader = new Downloader( myForm );
						downloader.excel( "lgvhr", "lgvpay/LGVATT50060/createExcelExportData", param );
					});
				}
				break;
			case 'save':
				var grid1 = grid.getGridBase();
				
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
					grid.saveChanges('lgvhr','lgvatt/LGVATT50060/saveEmpUlWarning', function(data, gridData ) {
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
		    { fieldName:'employeeOrg'	        	, dataType:'text'},
			{ fieldName:'employeeNo'	        	, dataType:'text'},
			{ fieldName:'employeeName' 	        	, dataType:'text'},
			{ fieldName:'employeeGrade' 	        , dataType:'text'},
			{ fieldName:'employeeCategory' 	        , dataType:'text'},
			{ fieldName:'dateHireSubsidiary'        , dataType:'text'},
			{ fieldName:'shiftTypeCode'             , dataType:'text'},
			{ fieldName:'startDate' 	            , dataType:'text'},
			{ fieldName:'endDate'                   , dataType:'text'},
			{ fieldName:'totalDays'                 , dataType:'text'},
			{ fieldName:'note'                      , dataType:'text'},
			{ fieldName:'remark'                    , dataType:'text'},
			{ fieldName:'managerNo1'                , dataType:'text'},
			{ fieldName:'managerName1'              , dataType:'text'},
			{ fieldName:'managerEmail1'             , dataType:'text'},
			{ fieldName:'sendEmailFlag'             , dataType:'text'},
		    { fieldName: 'creationDate'         	, dataType:'text'},
		    { fieldName: 'creationUserId'         	, dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookupsMultiLvl({
			"sendEmailFlagList": { data: sendEmailFlagList }
		});
		
		
		//컬럼 설정
		grid.setColumns([
	            {	name:'employeeNo',    
	            	fieldName:'employeeNo',    
	            	width:70,  
	            	header: {text:'<lgcom:message code="label.att.id" />'},	 
	            	editable: false, 
	            	styles: {textAlignment:'near'}
	            },
	            {	name:'employeeName',  
	            	fieldName:'employeeName',  
	            	width:150, 
	            	header: {text:'<lgcom:message code="label.att.employeeName" />'},	 
	            	editable: false, 
	            	styles: {textAlignment:'near'}
	            },
	            {	name:'employeeGrade', 
	            	fieldName:'employeeGrade', 
	            	width:80,  
	            	lookupDisplay: true,
					lookupSourceId: 'employeeGrade',
					lookupKeyFields: ['employeeGrade'], 
					header: {text:'<lgcom:message code="label.att.jobTitle" />'},
					editable: false,
					styles: {textAlignment:'near'}
				},
				{	name:'employeeCategory', 
	            	fieldName:'employeeCategory', 
	            	width:100,  
	            	lookupDisplay: true,
					lookupSourceId: 'employeeCategory',
					lookupKeyFields: ['employeeCategory'], 
					header: {text:'<lgcom:message code="label.att.employmentCategory" />'},
					editable: false,
					styles: {textAlignment:'near'}
				},
				{
					name:'dateHireSubsidiary',
					fieldName:'dateHireSubsidiary',
					width:100,
					type: 'data',
					header: {text:'<lgcom:message code="label.pay.hireDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'startDate',
					fieldName:'startDate',
					width:80,
					type: 'data',
					header: {text:'<lgcom:message code="StartTime" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'endDate',
					fieldName:'endDate',
					width:80,
					type: 'data',
					header: {text:'<lgcom:message code="EndTime" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'totalDays',
					fieldName:'totalDays',
					width:50,
					type: 'data',
					header: {text:'<lgcom:message code="Total" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'note',
					fieldName:'note',
					width:300,
					header: {text:'<lgcom:message code="Note" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'remark',
					fieldName:'remark',
					width:300,
					header: {text:'<lgcom:message code="Remark" />'},
					styles: {textAlignment:'center'}
				},
				{
					name:'managerNo1',
					fieldName:'managerNo1',
					width:80,
					header: {text:'<lgcom:message code="ApprovalApprover" />'},
					styles: {textAlignment:'center'}
				},
				{
					name:'managerName1',
					fieldName:'managerName1',
					width:160,
					header: {text:'<lgcom:message code="ApprovalApprover" />'},
					styles: {textAlignment:'center'}
				},
				{
					name:'managerEmail1',
					fieldName:'managerEmail1',
					width:250,
					header: {text:'<lgcom:message code="E-Mail" />'},
					styles: {textAlignment:'center'}
				},
				{
					name:'creationDate',
					fieldName:'creationDate',
					width:100,
					header: {text:'<lgcom:message code="label.att.creationDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'creationUserId',
					fieldName:'creationUserId',
					width:100,
					header: {text:'<lgcom:message code="label.att.createBy" />'},
					styles: {textAlignment:'near'},
					editable : false
				},
				{	name:'sendEmailFlag',
					fieldName:'sendEmailFlag',
					width:100,
					header: {text:'<lgcom:message code="label.att.confirmFlag"/>'},
					styles: {textAlignment:'center'},
					lookupDisplay: true,
					lookupSourceId: 'sendEmailFlagList',
					lookupKeyFields: ['sendEmailFlag'],
					editable: false
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
				checkBar: {visible:true},
				stateBar: {visible:false},
				footer: {visible:false},
				paste: {enabled:false}, /*paste 기능막기 */
				select: 'block',
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				},
				fixed : {colCount : 2, resizable:true}
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
		return grid;
	}
	
	//run결과 그리드에서 checkbar 선택한 경우 처리
	grid.getGridBase().onItemChecked = function (cgrid, itemIndex, checked) {
		<%--{PARAMETER]
		    - cgrid : grid.getGridBase()
		    - itemIndex : 그리드 행 index
		    - checked : 체크되었으면 true, 체크해제이면 false 
		--%>
	    if ( checked ) {//checkbar 선택된 경우

	    } else {//그외 비활성화 

	    }
	};
	//Run 그리드 선택 값 체크
	function fncValidateRunRow() {
		var list = fncArrangeMultiLineGridSelected(grid);
        		
		//선택된 행이 있는지 체크
		if ( !list || list.length == 0 ) {
			Message.alert("<lgcom:message code="note.noselected"/>");
			return false;
		}
		return true;
	}
	
	function search() {
		grid.getGridBase().cancel();
		var param = formUtil.getValue();
		grid.loadData('lgvhr','lgvatt/LGVATT50060/retrieveEmpULWarning', param);
		
	}
	
	//Send email flag
	function fncCancelSendEmail(sendEmailFlag) {
		var cMsg = '<lgcom:message code="question.save"/>';
		
		try {
			grid.getGridBase().commit();
		} catch(e) {
			Message.alert(e.message);
			return;
		}
			
		var checkedRows = grid.getGridBase().getCheckedRows(true);
		
		if( checkedRows.length > 0 ) {
			
			var param = {};
			var arr = [];
			
			for(var i=0; i<checkedRows.length; i++) {
				arr.push(grid.getDataProvider().getJsonRow(checkedRows[i]));
			}
			
			param["modifyList"] = arr;
			param["sendEmailFlag"] = sendEmailFlag;
			
		} else {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return;
		}
		
		Message.confirm(cMsg, function() {
			myForm.showProgress();
			myForm.transaction("lgvhr", "lgvatt/LGVATT50060/cancelSendEmail", param, function( data ){

				Message.alert( '<lgcom:message code="note.completed" />' );
				myForm.select(".search-wrap button[data-action='search']").trigger('click');
				myForm.hideProgress();
			});
		});	
	}
	
	//Send email manual
	function fncSendEmail() {
		var cMsg = '<lgcom:message code="note.sendConfirm"/>';
		
		try {
			grid.getGridBase().commit();
		} catch(e) {
			Message.alert(e.message);
			return;
		}
			
		var checkedRows = grid.getGridBase().getCheckedRows(true);
		
		if( checkedRows.length > 0 ) {
			
			var param = {};
			var arr = [];
			
			for(var i=0; i<checkedRows.length; i++) {
				arr.push(grid.getDataProvider().getJsonRow(checkedRows[i]));
			}
			
			param["modifyList"] = arr;
			
		} else {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return;
		}
		
		Message.confirm(cMsg, function() {
			myForm.showProgress();
			myForm.transaction("lgvhr", "lgvatt/LGVATT50060/sendEmail", param, function( data ){

				Message.alert( '<lgcom:message code="note.completed" />' );
				myForm.select(".search-wrap button[data-action='search']").trigger('click');
				myForm.hideProgress();
			});
		});	
	}
}
LGVATT50060.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT50060();
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
			                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.att.date"/></label></th>
			                    <td>
			                        <div class="form-inline">
	                                <input type="text" class="form-control input-sm input-require" name="atendanceStartDate" id="<c:out value="${ui_bizform_id}"/>_atendanceStartDate" placeholder="dd/mm/yyyy" style="width: 85px;" maxlength="10" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
	                                ~
	                                <input type="text" class="form-control input-sm input-require" name="atendanceEndDate" id="<c:out value="${ui_bizform_id}"/>_atendanceEndDate" placeholder="dd/mm/yyyy" style="width: 85px;" maxlength="10" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
	                                <button type="button" id="setSingleDateSample" class="btn btn-ico" aria-label="calendar">
								        <span class="ico ico-calendar" aria-hidden="true"></span>
								    </button>
	                            	</div>
		                        </td>
								
								<th><label><lgcom:message code="label.att.shiftCode" /></label></th>
								<td><select class="form-control input-sm" name="shiftCode"></select></td>
								
								<th><label><lgcom:message code="label.att.employmentCategory" /></label></th>
								<td><select class="form-control input-sm size_150" name="categoryTitle"></select></td>
								
			                </tr>
			                <tr>
								<th><label class="required"><lgcom:message code="label.att.organization" /></label></th>
								<td>
			                		<div class="input-group input-group-sm input-search">
		                                <input class="form-control input-sm _find_origin_" name="orgName" type="text">
		                                <span class="input-group-btn">
		                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupOrg">
		                                        <span class="fa fa-search" aria-hidden="true"></span>
		                                    </button>
		                                </span>
		                            </div>
			                	</td>
			                
			                	<th><label><lgcom:message code="label.att.employeeNo2" /></label></th>
								<td>
			                		<div class="input-group input-group-sm input-search">
		                                <input class="form-control input-sm _find_origin_" name="empNo" type="text">
		                                <span class="input-group-btn">
		                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupUser">
		                                        <span class="fa fa-search" aria-hidden="true"></span>
		                                    </button>
		                                </span>
		                            </div>
			                	</td>
								
								<th><label><lgcom:message code="label.att.employeeName" /></label></th>
								<td><input type="text" class="form-control input-sm" name="empName" ></td>
								
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
		        <button type="button" class="btn btn-default btn-sm" data-action="excelDownload"><span class="ico ico-excel-down"  aria-hidden="true"></span> <lgcom:message code="Download"/></button>
		     </div>
			<div class="btn-group">					      
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
			</div>
			<div class="btn-group">
				<button class="btn btn-gray btn-sm" type="button" data-action="sendEmail" ><lgcom:message code="SendMail"/></button>
			</div>
			<div class="btn-group">					     
				<button class="btn btn-gray btn-sm" type="submit" data-action="reSend"><lgcom:message code="Send"/></button> 
				<button class="btn btn-gray btn-sm" type="submit" data-action="reject"><lgcom:message code="Reject"/></button>
			</div>
		</div>
	</div>
		<div class="gridContent grid-wrap">
			<div class="grid empULWarningManageGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
