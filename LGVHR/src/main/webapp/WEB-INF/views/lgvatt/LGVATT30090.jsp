<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn"    uri="http://java.sun.com/jsp/jstl/functions"%>
<%---------------------------------------------------------
    파일명 : LGVATT30090.jsp
    프로젝트명 : V-HR 근태 개선 프로젝트
    기간 : 2023/02/13 ~ 2023/04/30

   Copyright(c) 2023 LG CNS VH,  All rights reserved..

    설 명 : Daily Att Summary UI
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
var LGVATT30090 = function() {
	var myForm = this;
	var _this = this;
	var srchForm = '.searchBlock form';
	var isAttMaster = ('<c:out value="${flg_vn_att_master}"/>' == 'Y')?true:false;
	
	myForm.popupInfo = { 
			//userPopup : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', userData:[]},
			//partPopup : {searchMode:'single', popupKind:'', confirmKind:'', organizationId:'', organizationName:'', partData:[]}
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
	var grid = buildGrid('.dailyAttSummaryList');
    
	//날짜 설정
	var $date = myForm.select(".searchBlock input[name='attDate']");
	
	$date.val(setYesterday(DateUtil.today("DD/MM/YYYY")));
	
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	formUtil.setCalendar( { from : "attDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
	
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
		}
	});
	
	myForm.addEvent( "change", ".searchBlock .form select[name=planYyyymmdd]" , function(event) {
		//클릭이벤트 호출
		myForm.select(".searchBlock button[data-action='search']").trigger('click');
		event.stopPropagation();
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
			//{ fieldName: 'division'   	, dataType:'text'},
		    //{ fieldName: 'department'   	, dataType:'text'},
		    { fieldName: 'team'         	, dataType:'text'},
		    { fieldName: 'section'    		, dataType:'text'},
		    { fieldName: 'task'         	, dataType:'text'},
		    { fieldName: 'part'         	, dataType:'text'},
		    { fieldName: 'unit'  			, dataType:'text'},
		    { fieldName: 'total'            , dataType:'text'},
		    { fieldName: 'lateness'         , dataType:'text'},
		    { fieldName: 'leavingEarly'    , dataType:'text'},
		    { fieldName: 'outing'           , dataType:'text'},
		    { fieldName: 'training'         , dataType:'text'},
		    { fieldName: 'annualLeave'     , dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookupsMultiLvl({
		});
		
		//컬럼 설정
		grid.setColumns([
				/*{
					name:'division',
					fieldName:'division',
					width:180,
					header: {text:'<lgcom:message code="label.att.Division" />'},
					styles: {textAlignment:'near'},
					editable: false
				},
				{
					name:'department',
					fieldName:'department',
					width:180,
					header: {text:'<lgcom:message code="label.att.Department" />'},
					styles: {textAlignment:'near'},
					editable: false
				},*/
				{
					name:'team',
					fieldName:'team',
					width:150,
					header: {text:'<lgcom:message code="team"/>'},
					styles: {textAlignment:'near'},
					editable: false
				},
				{
					name:'section',
					fieldName:'section',
					width:150,
					header: {text:'<lgcom:message code="Section"/>'},
					styles: {textAlignment:'near'},
					editable: false
				},
				{
					name:'task',
					fieldName:'task',
					width:150,
					header: {text:'<lgcom:message code="Task" />'},
					styles: {textAlignment:'left'},
					editable: false
				},
				{
					name:'part',
					fieldName:'part',
					width:180,
					header: {text:'<lgcom:message code="Part" />'},
					styles: {textAlignment:'near'},
					editable: false
				},
				{
					name:'unit',
					fieldName:'unit',
					width:180,
					header: {text:'<lgcom:message code="Unit" />'},
					styles: {textAlignment:'near'},
					editable: false
				},
				{
					name:'total',
					fieldName:'total',
					width:50,
					header: {text:'<lgcom:message code="Total" />'},
					styles: {textAlignment:'center'},
					editable: false
				},
				{	type:'group',
					name:'day1',
					fieldName:'day1',
					width:470,
					header:{
				         text:'<lgcom:message code="label.att.day1" /> '
				    },
					orientation:'horizontal',
					columns: [
								{
									name:'lateness',
									fieldName:'lateness',
									width:20,
									header: {text:'<lgcom:message code="Lateness"/>'},
									styles: {textAlignment:'center'},
									editable: false,
								},
								{
									name:'leavingEarly',
									fieldName:'leavingEarly',
									width:30,
									header: {text:'<lgcom:message code="leavingEarly"/>'},
									styles: {textAlignment:'center'},
									editable: false,
								},
								{
									name:'outing',
									fieldName:'outing',
									width:20,
									header: {text:'<lgcom:message code="Outing"/>'},
									styles: {textAlignment:'center'},
									editable: false,
								},
								{
									name:'training',
									fieldName:'training',
									width:20,
									header: {text:'<lgcom:message code="Training"/>'},
									styles: {textAlignment:'center'},
									editable: false,
								},
								{
									name:'annualLeave',
									fieldName:'annualLeave',
									width:30,
									header: {text:'<lgcom:message code="annualLeave"/>'},
									styles: {textAlignment:'center'},
									editable: false,
								}
							]
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
	
	function search() {
		grid.getGridBase().cancel();

		var parameter = {
			attDate: $.trim(myForm.select(".searchBlock input[name='attDate']").val())
		};
		
		grid.loadData('lgvhr','lgvatt/LGVATT30090/getDailyAttSummaryList', parameter);
		
		grid.setLookupsMultiLvl({
		
	    });
	}
	
	//어제 날짜 구하기
	function setYesterday(date){
		var selectDate = date.split("/");
		var changeDate = new Date();
		
		changeDate.setFullYear(selectDate[2], selectDate[1]-1, selectDate[0]-1);
		
		var y = changeDate.getFullYear();
		var m = changeDate.getMonth() + 1;
		var d = changeDate.getDate();
		if(m < 10)    { m = "0" + m; }
		if(d < 10)    { d = "0" + d; }
		
		var resultDate = d + '/' + m + '/' + y;
		return resultDate;
	}
}
LGVATT30090.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT30090();
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
							<th><label><i class="asterisk">*</i><lgcom:message code="label.att.date" /></label></th>
		                    <td>
								<span class="form-inline">
								    <input type="text" class="form-control input-sm input-require" name="attDate" placeholder="dd/mm/yyyy" readonly>
								    <button type="button" id="setSingleDateSample" class="btn btn-ico" aria-label="calendar">
								        <span class="ico ico-calendar" aria-hidden="true"></span>
								    </button>
								</span>
							</td>
							<%-- <th scope="col"><label><lgcom:message code="label.att.approvalStatus"/></label></th>
							<td><select class="form-control input-sm input-require" name="approvaStatusCode" ></select></td> --%>
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
				
			</div>
			<div class="btn-group">
				
			</div>
		</div>
	</div>
		<div class="gridContent grid-wrap">
			<div class="grid dailyAttSummaryList"></div>
		</div>
	</section>
</div>
</body>
</html>
