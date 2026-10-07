<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT20440.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Long Term Plan 조회
    작성자 : bakderia
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVATT20440 = function() {
	var myForm = this;
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
	//코드 데이터 조회
    var code = new CommonCode("lgcom");
    code.add("approvalStatusList", {codeTypeCode:"LGVHR_ATT_APPROVAL_STATUS"});
    code.execute();
        
    //결재상태 콤보 셋팅
    formUtil.initCombo("approvaStatusCode", code.get("approvalStatusList"), {selectAll:true});

	// Form Util 선언
    var dateFrom = DateUtil.format(DateUtil.today().add(-1,'month').set('date',1), 'DD/MM/YYYY');

    formUtil.setValue( {
    	planStartDate : dateFrom,
        planEndDate : DateUtil.today("DD/MM/YYYY")
    });

	formUtil.setCalendar( { from : "planStartDate", to : "planEndDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );

	myForm.setLayout( [ 
		{ name : "searchBlock", left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);
	
	// 그리드 선언
	var grid = buildGrid('.multiplePlanListGrid');

	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
			case 'search':
				grid.getGridBase().cancel();
				searchList();
				
				break;
			case "newMplan":
	        	gotoNewPage();
	        	break;
			case "detail":
				var gridCount = grid.getDataProvider().getRowCount();
				
				if(gridCount != 0) {
					gotoDeatilPage();
				}
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
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//필드 설정
		grid.setFields([
		    { fieldName: 'employeeNo'         		 , dataType:'text'},
		    { fieldName: 'approvalRequestId'         , dataType:'text'},
		    { fieldName: 'applicationUserId'         , dataType:'text'},
		    { fieldName: 'requestNo'         		 , dataType:'text'},
			{ fieldName: 'planningId'                , dataType:'text'},
			{ fieldName: 'requestCode'               , dataType:'text'},
			{ fieldName: 'requestDate'               , dataType:'text'},
			{ fieldName: 'planStartDate'             , dataType:'text'},
			{ fieldName: 'planEndDate'               , dataType:'text'},
			{ fieldName: 'requestor'            	 , dataType:'text'},
			{ fieldName: 'attendanceType'            , dataType:'text'},
			{ fieldName: 'attendanceTypeDetail'      , dataType:'text'},
			{ fieldName: 'detailReason'      		 , dataType:'text'},
		    { fieldName: 'approvalStatus'         	 , dataType:'text'},
		    { fieldName: 'status'         	 	 	 , dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookups({});
		//컬럼 설정
		grid.setColumns([
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
					name:'planStartDate',
					fieldName:'planStartDate',
					width:116,
					type: 'data',
					header: {text:'<lgcom:message code="label.att.planStartDate"/>'},
					styles: {textAlignment:'center'},
					editable : false
				},	
				{
					name:'planEndDate',
					fieldName:'planEndDate',
					width:116,
					type: 'data',
					header: {text:'<lgcom:message code="label.att.planEndDate" />'},
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
					name:'detailReason',
					fieldName:'detailReason',
					width:400,
					type: 'data',
					header: {text:'<lgcom:message code="label.att.attendanceDetailReason" />'},
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

		return grid;
	}
	
	//신규 페이지 이동
    function gotoNewPage() {
        var nav = new Navigate( myForm, "lgvhr", "M_LGVATT_1030" );
        nav.addParam("callType", "DETAIL");
        
        nav.addNavigationCallback( function( caller ){
            myForm.select("button[data-action=search]").trigger('click');
        });
        nav.goPageInCurrentDiv(false);
    }
  	//grid 클릭으로 상세 페이지 이동
    grid.getGridBase().onDataCellClicked =  function ( cgrid, index ) {
        var rowData = grid.getJsonRow();
        if (index.column == "requestNo") {
        	gotoDeatilPage();
        }
    }
 	//상세 페이지 이동
    function gotoDeatilPage() {
    	var rowData = grid.getJsonRow();
		
		var param = gridContent.getValue();
		
		// 선택된 항목이 없다면 중단
		//if($.trim(param['planningId']) == '') return;
		
		if($.trim(param['approvalRequestId']) == null) return;
        var nav = new Navigate( myForm, "lgvhr", "M_LGVATT_1031" );
        nav.addParam("callType", "DETAIL");
        nav.addParam("employeeNo", rowData["employeeNo"]);
        nav.addParam("requestCode", rowData["requestCode"]);
        nav.addParam("approvalRequestId", rowData["approvalRequestId"]);
        nav.addParam("status", rowData["status"]);

        nav.goPageInCurrentDiv(false);
    }
	function searchList() {
		var param = formUtil.getValue();
		var dateFrom = $("#planStartDate").val();
		var dateTo = $("#planEndDate").val();
		
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
		
		grid.loadData('lgvhr','lgvatt/LGVATT20440/retrieveMutiplanList',param);
	}
	
	//해외주재원 여부확인
	transaction("lgvhr", "lgvatt/LGVATT20440/retrieveFseYn", {employeeNo:"${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}"}, function(data){
		if(data.result.fseYn == "Y") { //해외주재원은 장기근태 등록버튼 숨김처리
			$(".gridControls [data-action='newMplan']").hide();
		}
	});
}

LGVATT20440.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT20440();
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
		                    <th><label class="required"><lgcom:message code="label.att.requestDate"/></label></th>
		                    <td>
		                        <div class="form-inline ">
                                <input type="text" class="form-control input-sm input-require" name="planStartDate" id="planStartDate" placeholder="dd/mm/yyyy" style="width: 85px;" maxlength="10" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
                                ~
                                <input type="text" class="form-control input-sm input-require" name="planEndDate" id="planEndDate" placeholder="dd/mm/yyyy" style="width: 85px;" maxlength="10" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
                                <button type="button" id="setSingleDateSample" class="btn btn-ico" aria-label="calendar">
							        <span class="ico ico-calendar" aria-hidden="true"></span>
							    </button>
                            	</div>
		                    </td>
		                    <th scope="col"><label><lgcom:message code="label.att.approvalStatus"/></label></th>
							<td><select class="form-control input-sm input-require" name="approvaStatusCode" ></select></td>	
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<div class="gridControls module-group text-right">
            <div class="btn-toolbar">
                <div class="btn-group">
                    <button class="btn btn-default btn-sm" type="submit" data-action="newMplan"><lgcom:message code="New"/></button>
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
