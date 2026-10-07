<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn"    uri="http://java.sun.com/jsp/jstl/functions"%>
<%---------------------------------------------------------
    파일명 : LGVATT50050.jsp
    프로젝트명 : V-HR 근태 개선 프로젝트
    기간 : 2023/02/13 ~ 2023/04/30

   Copyright(c) 2023 LG CNS VH,  All rights reserved..

    설 명 : Setup Korean Leader charge Part
    작성자 : Kim BiHo
-------------------------------------------------------------%>
<c:set var="flg_vn_att_master" value="N"/>
<c:forEach var="roles" items="${sessionScope.USER_SESSION.roleList}">
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_ATT_MASTER_USER')>=0 }">
        <c:set var="flg_vn_att_master" value="Y"/>
    </c:if>   
</c:forEach>

<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVATT50050 = function() {
	var myForm = this;
	var _this = this;
	var isAttMaster = ('<c:out value="${flg_vn_att_master}"/>' == 'Y')?true:false;
	
	myForm.popupInfo = { 
			userPopup : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', userData:[]},
			partPopup : {searchMode:'single', popupKind:'', confirmKind:'', organizationId:'', organizationName:'', partData:[]}
	};
	
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
	var valueSet = new ValueSet("lgcom");
	valueSet.add('orgName', {valueSetId : 'LGVATT_LW_ADMIN_ORG_NAME', employeeNum : '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}', subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}'});
	valueSet.execute(); 
	
	myForm.setLayout( [ 
		{ name : "searchBlock", left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);
	
	
	// 그리드 선언
	var grid = buildGrid('.koreanLeaderInfoGrid');    
    
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
			case 'insert':
				var grid1 = grid.getGridBase();
				var subsidiaryCode = '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}';
				var currIdx = grid1.getCurrent().itemIndex;
				var itemCnt = grid1.getItemCount();
				var dataRowIdx = grid1.getCurrent().dataRow;
				
				grid1.beginAppendRow();

				grid1.setFocus();
				
				break;
			case 'save':
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
				
				var recpmap = new Map();
				for(var i=0; i < cgrid.getItemCount(); i++) {
					// 삭제건은 제외
					//if(cgrid.getDataProvider().getRowState(cgrid.getDataRow(i)) == 'deleted') continue;
					console.log(cgrid.getDataProvider().getRowState(cgrid.getDataRow(i)));
				}
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid.useProgress(true);
					grid.saveChanges('lgvhr','lgvatt/LGVATT50050/saveKoreanLeaderInfo', function(data, gridData ) {
						Message.alert('<lgcom:message code="note.completed"/>');
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				break;
			case 'excelUpload':
				var uploader = new ExcelUploader("lgvhr", "LGVATT50050", {});
	                uploader.open(  processExcelUploadPostProcess );
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
	
	/**
		Cell Button Event
		Event Column : employeeNumber ,departmentCode
		Event Contents : call Popup
	*/
	grid.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);
		var userId = $.trim(SESSION_USER.fullNameLocal);
		
		if(column.name == "employeeNo"){
            //user search popup
			processUserPopup(itemIndex, column.name, userId, gridRow.employeeNo);
		}else if(column.name == "organizationCode"){
			//department search popup
			processUserPopup(itemIndex, column.name, userId, gridRow.organizationCode);
		}
	};
	
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
			{ fieldName: 'seqValue'           , dataType:'text'},
		    { fieldName: 'employeeNo'           , dataType:'text'},
		    { fieldName: 'englishName'          , dataType:'text'},
		    { fieldName: 'localName'            , dataType:'text'},
		    { fieldName: 'organizationCode'           , dataType:'text'},
		    { fieldName: 'organizationName'         , dataType:'text'},
		    { fieldName: 'englishOrganizationName'  , dataType:'text'},
		    { fieldName: 'emailAddr'                 , dataType:'text'},
		]);
		// Lookup 설정
		grid.setLookupsMultiLvl({
		});
		
		//컬럼 설정
		grid.setColumns([
				//SEQ_VALUE
				{
					name:'seqValue',
					fieldName:'seqValue',
					width:0,
					header: {text:'<lgcom:message code="SeqValue" />'},
					styles: {textAlignment:'center'},
					editable: false
				},
				{
					name:'employeeNo',
					fieldName:'employeeNo',
					width:100,
					header: {text:'<lgcom:message code="EmployeeNumber" />'},
					styles: {textAlignment:'center'},
					button: 'action',
					editable: true
				},
				{
					name:'englishName',
					fieldName:'englishName',
					width:150,
					header: {text:'<lgcom:message code="EnglishFullName"/>'},
					styles: {textAlignment:'near'},
					editable: false
				},
				{
					name:'localName',
					fieldName:'localName',
					width:150,
					header: {text:'<lgcom:message code="localLanguageFullName"/>'},
					styles: {textAlignment:'near'},
					editable: false
				},
				{
					name:'organizationCode',
					fieldName:'organizationCode',
					width:100,
					header: {text:'<lgcom:message code="label.att.organizationId" />'},
					styles: {textAlignment:'center'},
					button: 'action',
					editable: true
				},
				{
					name:'organizationName',
					fieldName:'organizationName',
					width:0,
					header: {text:'<lgcom:message code="label.att.organizationName" />'},
					styles: {textAlignment:'near'},
					editable: false
				},
				{
					name:'englishOrganizationName',
					fieldName:'englishOrganizationName',
					width:300,
					header: {text:'<lgcom:message code="label.att.englishOrganizationName" />'},
					styles: {textAlignment:'near'},
					editable: false
				},
				{
					name:'emailAddr',
					fieldName:'emailAddr',
					width:200,
					header: {text:'<lgcom:message code="MailAddr" />'},
					styles: {textAlignment:'near'},
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
			 					//{criteria: "value['shiftTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.shiftType'/>"/>',mode:'always',level:'error'},
			 					//{criteria: "value['otLevel'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.level'/>"/>',mode:'always',level:'error'},
			 					//{criteria: "value['lowerLimit'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.lowerLimit'/>"/>',mode:'always',level:'error'}
			 				]);
		return grid;
	}
	
	function processUserPopup(rowIdx, colName, applicationUserId, keyword) {
		if(typeof(applicationUserId) == 'undefined') applicationUserId = '';		
		var grid1 = grid.getGridBase();
		var _popup = "";
		if(colName == 'employeeNo'){
			_popup = _this.popupInfo.userPopup;	
		}else if(colName == 'organizationCode'){
			_popup = _this.popupInfo.partPopup;
		}
        
        _popup.searchMode   = "single";
        
        if(!isAttMaster) {
        	_popup.popupKind    = "PIC";
        } else {
        	_popup.popupKind    = "";
        }
        
        _popup.confirmKind  = "";
        
        var popup = "";
        if(colName == 'employeeNo'){
	        _popup.employeeNo = keyword;
	        _popup.employeeName = "";
	        
	        popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1016', '<lgcom:message code="UserSearch"/>' );
	        popup.setSize(800,494);
	        popup.open( function(){
	        	grid1.setValue(rowIdx,'employeeNo', _popup.userData[0].employeeNumber);
	            grid1.setValue(rowIdx,'englishName', _popup.userData[0].englishFullName);
	            grid1.setValue(rowIdx,'localName', _popup.userData[0].localLanguageFullName);
	            grid1.setValue(rowIdx,'emailAddr', _popup.userData[0].mailAddr);
	        	
	            //form input box setting sample
	            //formUtil.setValue({employeeNumber  :_popup.userData[0].employeeNo});
	            //formUtil.setValue({englishFullName   :_popup.userData[0].employeeName});
	        });
	        _popup.userData = [];
        }else if(colName == 'organizationCode'){
        	_popup.organizationId = keyword;
	        _popup.organizationName = "";
	        
	        popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1017', '<lgcom:message code="PartSearch"/>' );
	        popup.setSize(800,494);
	        popup.open( function(){
	        	grid1.setValue(rowIdx,'organizationCode', _popup.partData[0].organizationId);
	            grid1.setValue(rowIdx,'organizationName', _popup.partData[0].organizationName);
	            grid1.setValue(rowIdx,'englishOrganizationName', _popup.partData[0].englishOrganizationName);
	        });
	        _popup.partPopup = [];
        }
		
        
	}
	
	function processExcelUploadPostProcess( sessionId ) { 
		param.sessionId = sessionId;
		//반드시 transaction_sync 를 써야합니다 !!
		transaction_sync('lgvhr','lgvpay/LGVATT50050/uploadExcelPartLeaderInfo',param, function(data) {
			Message.notify('<lgcom:message code="note.completed"/>');
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		});
	}
	
	function search() {
		grid.getGridBase().cancel();
		var param = formUtil.getValue();
		console.log(param);
		grid.loadData('lgvhr','lgvatt/LGVATT50050/getKoreanLeaderInfo', param);
		
		grid.setLookupsMultiLvl({
		
	    });
	}
}
LGVATT50050.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT50050();
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
						<col width="50"/>
						<col width="130"/>
					</colgroup>
					<tbody>
						<tr>
		                    <th scope="col"><label><lgcom:message code="EmployeeNumber"/></label></th>
							<td><input type="text" name="employeeNo" class="form-control input-sm" placeholder=""/></td>
							<th scope="col"><label><lgcom:message code="EnglishFullName"/></label></th>
							<td><input type="text" name="englishName" class="form-control input-sm" placeholder=""/></td>
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
				<button class="btn btn-default btn-sm" type="button" data-action="excelUpload">
					<span class="ico ico-excel-up"></span><lgcom:message code="Upload" /></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert">
					<span class="fa fa-plus" aria-hidden="false"></span> <lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete">
					<span class="fa fa-remove" aria-hidden="false"></span> <lgcom:message code="delete"/></button>
			</div>
			<div class="btn-group">					      
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
			</div>
		</div>
	</div>
		<div class="gridContent grid-wrap">
			<div class="grid koreanLeaderInfoGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
