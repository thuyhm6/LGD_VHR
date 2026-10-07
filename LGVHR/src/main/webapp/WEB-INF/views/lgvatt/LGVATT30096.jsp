<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT30096.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    Create Request For Flexible Working
    		
    작성자 : HMT_20260101
-------------------------------------------------------------%>
<c:set var="ui_bizform_id" value="${param.bizFormId}" />
<c:set var="flg_vn_att_master" value="N"/>
<c:forEach var="roles" items="${sessionScope.USER_SESSION.roleList}">
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_ATT_MASTER_USER')>=0 }">
        <c:set var="flg_vn_att_master" value="Y"/>
    </c:if>   
</c:forEach>
<html lang="ko">
<head>
<title><lgcom:message code="label.att.requestAttendanceModification"/></title>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVATT30096 = function() {
	var _this = this;	
	var grid;
	var searchForm = new FormUtil(_this, '.search-wrap');
	var isHrMng = ('<c:out value="${flg_vn_att_master}"/>' == 'Y')?true:false;
	/* 팝업용 변수 선언 */
	_this.popupInfo = {
		userPopup: {},		// 결재자		
	};	

	// 화면 레이아웃 정의(결재선 셋팅 후 화면 레이아웃 확정되기 때문에 마지막에 셋팅한다.)
	_this.setLayout([
		{ name : "searchBlock", left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
	
	]);
	
    // 코드 데이터 조회(그리드 콤보 셋팅하기 위해 사용함.)
	// combo 목록 조회
	var code = new CommonCode("lgcom");	
	code.add("approvalStatusList", {codeTypeCode:"LGVHR_ATT_APPROVAL_STATUS"});
	code.execute();
	
	
	searchForm.initCombo("approvalStatusCode", code.get("approvalStatusList"), {selectAll:true});
    var dateFrom = DateUtil.format(DateUtil.today().add(-1,'month').set('date',1), 'DD/MM/YYYY');

    searchForm.setValue( {
    	requestStartDate : dateFrom,
        requestEndDate : DateUtil.today("DD/MM/YYYY")
    });
    
    // HR 담당자 권한일 경우 모든 Flexible Working List 보이도록
    if(!isHrMng) {
    	searchForm.setValue({isHrManager : "NoHrManager"});
    } 

    searchForm.setCalendar( { from : "requestStartDate", to : "requestEndDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
	
	  
    // 화면에 필요한 초기데이터 조회

    // 개인화조건
    
    // 조회조건 저장 처리
    _this.searchConditionControl( true );    
    
    _this.addEvent('submit', searchForm, function(event) {
        event.preventDefault();
    });
    

    // 날짜 팝업창
    
    // 필수항목 체크
    
    // 일반함수	
    
	/*** 이벤트 핸들러  ***/
	// 버튼제어
	_this.addEvent('click','button[data-action]',function(event) {
		var action = $(this).data("action");	
		var itemIndex = gridView.getCurrent().itemIndex;	
		
		switch(action) {
			case 'search' :
				fncSearchRequestSpectialOt();
				break;
			
			case 'new':
				goToPage('M_LGVATT_1080', {viewType:'NEW'}, 'M_LGVATT_1079');
				break;
			case 'detail':
				var itemIndex = gridView.getCurrent().itemIndex;
				var requestNo = gridView.getValue(itemIndex, 'requestNo');
				var approvalRequestId = gridView.getValue(itemIndex, 'approvalRequestId');
				var requestCode = gridView.getValue(itemIndex, 'requestCode');
				goToPage('M_LGVATT_1080', {viewType:'DETAIL_VIEW', 'requestNo' : requestNo, 'approvalRequestId' : approvalRequestId, 'requestCode' : requestCode}, 'M_LGVATT_1079')				
				break;
		}
	});
	
	function goToPage(menuId, param, returnPage) {
        
        var nav = new Navigate( _this, "lgvhr", menuId);
        
        for(var key in param){
        	nav.addParam(key, param[key]);
        }       
        nav.addParam("returnPage", returnPage);        
        
        nav.addNavigationCallback( function( caller ){
        	_this.select("button[data-action=search]").trigger('click');
        });
        nav.goPageInCurrentDiv(false);       
        
    }
	                    

	// 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(_this, gridId, {statusBar : "N"});
		var gridReadOnyBgColor = "#e9e9e9";
		grid.setPagingMode(true);

		//옵션 설정 
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:true,
				indicator: {visible:true},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				select: 'block',
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				},
				header: {showTooltip: true},
				
			},
			display: { fitStyle: 'none' }
		});
		
		//필드 설정
		grid.setFields(
				[
					
					{ fieldName: 'requestNo'         		 , dataType:'text'},
				    { fieldName: 'approvalRequestId'         , dataType:'text'},			   					
					{ fieldName: 'requestCode'               , dataType:'text'},
					{ fieldName: 'requestDate'               , dataType:'text'},			
					{ fieldName: 'requestor'            	 , dataType:'text'},
					{ fieldName: 'attendanceType'            , dataType:'text'},
					{ fieldName: 'attendanceTypeDetail'      , dataType:'text'},					
				    { fieldName: 'approvalStatus'         	 , dataType:'text'},
				    { fieldName: 'status'         	 	 	 , dataType:'text'}
					
				]
		);		
		//컬럼 설정 
		grid.setColumns(
				[
					
					{
					name:'requestNo',
					fieldName:'requestNo',
					width:150,
					header: {text:'<lgcom:message code="label.att.requestNo" />'},
					styles: {textAlignment:'center', fontUnderline: true, foreground: '#37a0ac'},
					cursor:'pointer',
					editable : false
				},
				{
					name:'requestDate',
					fieldName:'requestDate',
					width:116,
					header: {text:'<lgcom:message code="label.att.requestDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},			
				{
					name:'requestor',
					fieldName:'requestor',
					width:360,
					type: 'data',
					header: {text:'<lgcom:message code="label.att.requestor" />'},
					styles: {textAlignment:'near'},
					editable : false
				},		
				{
					name:'attendanceType',
					fieldName:'attendanceType',
					width:120,
					type: 'data',
					header: {text:'<lgcom:message code="label.att.attendanceType" />'},
					styles: {textAlignment:'near'},
					editable : false
				},
				{
					name:'attendanceTypeDetail',
					fieldName:'attendanceTypeDetail',
					width:150,
					type: 'data',
					header: {text:'<lgcom:message code="label.att.attendanceCode" />'},
					styles: {textAlignment:'near'},
					editable : false
				},
				{
					name:'approvalStatus',
					fieldName:'approvalStatus',
					width:102,
					header: {text:'<lgcom:message code="label.att.approvalStatus" />'},
					styles: {textAlignment:'near'},
					editable : false
				}]						
				
		);
		// Context Menu Set
		grid.setContextMenu();
		//그리드 필수값 체크
		return grid;
	}
    
	// 그리드 초기화
    grid = buildGrid(".multiplePlanListGrid");
    var gridView = grid.getGridBase();
    var provider = grid.getDataProvider();
    
	var selectOptions = {"style" : "singleRow"};
    gridView.setSelectOptions(selectOptions);
  	
	//날짜 셀 클릭 시 수정 가능여부를 판단한다.
	grid.getGridBase().onDataCellClicked =  function (grid, index) {
		var itemIndex = grid.getCurrent().itemIndex;		
        if (index.column == "requestNo") {
        	var itemIndex = grid.getCurrent().itemIndex;
			var requestNo = grid.getValue(itemIndex, 'requestNo');
			var approvalRequestId = gridView.getValue(itemIndex, 'approvalRequestId');
			var requestCode = gridView.getValue(itemIndex, 'requestCode');
        	goToPage('M_LGVATT_1080', {viewType:'DETAIL_VIEW', 'requestNo' : requestNo, 'approvalRequestId' : approvalRequestId, 'requestCode' : requestCode}, 'M_LGVATT_1079')
        }

	};
   
    gridView.onEditChange = function (grid, index, value) {
	    
	};
	
    gridView.onEditCommit = function(grid, index, oldValue, newValue){
    	
    }
    
    gridView.onCellEdited = function(grid, itemIndex, dataRow, field){
    	
    	
    }  
    
	function fncSearchRequestSpectialOt(){
		
		var param = searchForm.getValue();
		var dateFrom = param.requestStartDate;
		var dateTo = param.requestEndDate;	
		
		if( isNull(dateFrom) ) {
			Message.alert("<lgcom:message code="note.att.emptyRequestDate"/>.");
			return;
		}else{
			if(!isValidDate(dateFrom)) {
				Message.alert("<lgcom:message code="note.att.emptyRequestDate"/>.");
				return;
			}
		}
		if( isNull(dateTo) ) {
			Message.alert("<lgcom:message code="note.att.emptyRequestDate"/>.");
			return;
		}else{
			if(!isValidDate(dateTo)) {
				Message.alert("<lgcom:message code="note.att.emptyRequestDate"/>.");
				return;
			}
		}
		if(!isValidDateBetween(dateFrom, dateTo)) {
			Message.alert("<lgcom:message code="note.att.emptyRequestDate"/>.");
			return;
		}
		
		grid.loadData("lgvhr", "lgvatt/LGVATT30096/retrieveFlexibleWorkingRequestList",param);
	}	
	
	// 화면 로드 후 실행 시작
	_this.myFormInit = function(){
		// searchForm 초기 셋팅
		
	}	
	
}

LGVATT30096.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT30096();
		form.init();
		form.myFormInit();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.att.requestAttendanceModification"/></h2>
		</div>
		<%-- 조회 화면 --%>
		<div class="searchBlock">
			<form class="form search-wrap">
				<input type="hidden" name="isHrManager"/>
				<table class="table">
					<colgroup>
						<col width="90"/>
						<col width="220"/>
						<col width="60"/>
						<col width="*"/>
					</colgroup>
					<tbody>
						<tr>
		                    <th><label class="required"><lgcom:message code="label.att.requestDate"/></label></th>
		                    <td>
		                        <div class="form-inline">
                                <input type="text" class="form-control input-sm input-require" name="requestStartDate" id="<c:out value="${ui_bizform_id}"/>_requestStartDate" placeholder="dd/mm/yyyy" style="width: 85px;" maxlength="10" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
                                ~
                                <input type="text" class="form-control input-sm input-require" name="requestEndDate" id="<c:out value="${ui_bizform_id}"/>_requestEndDate" placeholder="dd/mm/yyyy" style="width: 85px;" maxlength="10" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
                                <button type="button" id="setSingleDateSample" class="btn btn-ico" aria-label="calendar">
							        <span class="ico ico-calendar" aria-hidden="true"></span>
							    </button>
                            	</div>
		                    </td>
		                    <th scope="col"><label><lgcom:message code="label.att.approvalStatus"/></label></th>
							<td><select class="form-control input-sm input-require" name="approvalStatusCode" ></select></td>	
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>			
		
		<%-- 리스트 화면 --%>
		<div class="gridControls module-group text-right">
            <div class="btn-toolbar">
                <div class="btn-group">
                    <button class="btn btn-default btn-sm" type="submit" data-action="new"><lgcom:message code="New"/></button>
                    <button class="btn btn-default btn-sm" type="submit" data-action="detail"><lgcom:message code="Detail"/></button>
                </div>
            </div>
        </div>
		<div class="gridContent grid-wrap">
			<div class="grid multiplePlanListGrid"></div>
		</div>
		
	</section>
</div>
</body>
</html>
