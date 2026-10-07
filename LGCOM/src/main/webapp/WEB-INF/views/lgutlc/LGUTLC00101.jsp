<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00101.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Service Logging Detail List를 조회하는 팝업입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Service Logging Detail</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
span.dispLabel {
	width: 100%;
	padding: 0px;
	margin: 0px;
	overflow: hidden;
	text-overflow: ellipsis;
}
</style>
<script type="text/javascript">
var LGUTLC00101 = function() {
	var myForm = this;
	var _popupInfo;
	// 조회조건 Combo 초기화
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "content", left : 0, right : 0, top : "searchBlock", bottom : "controls"},
		{ name  : "controls", left : 0, right : 0, bottom : 0 }	 	
	]);	
	// 조회조건 Combo 초기화
	var code = new CommonCode('lgcom');
	code.add('systemCode',{codeTypeCode:'LGCOM_SYSTEM_CODE'});
	code.add('moduleCode',{codeTypeCode:'LGCOM_MODULE_CODE'});
	code.execute();
	// 그리드 선언
	var grid = buildGrid(".serviceDetailGrid");
	/*** OnLoad 이벤트 **/
	myForm.initMyForm = function() {
		_popupInfo = myForm.getParent().popupInfo.detailPopup;
		if(_popupInfo) {
			formUtil.setValue({
				executionYyyymm: $.trim(_popupInfo['executionYyyymm']),
				menuId: $.trim(_popupInfo['menuId']),
				programId: $.trim(_popupInfo['programId']),
				systemServiceDesc: $.trim(_popupInfo['systemServiceDesc'])
			});
			myForm.select(".searchBlock form span[name='spanExecutionYyyymm']").text($.trim(_popupInfo['executionYyyymm']));
			myForm.select(".searchBlock form span[name='spanMenuName']").text($.trim(_popupInfo['menuName']));
			myForm.select(".searchBlock form span[name='spanMenuName']").data('toggle','tooltip');
			myForm.select(".searchBlock form span[name='spanMenuName']").data('placement','right');
			myForm.select(".searchBlock form span[name='spanMenuName']").attr('title',$.trim(_popupInfo['menuName']));
			myForm.select(".searchBlock form span[name='spanProgramName']").text($.trim(_popupInfo['programName']));
			myForm.select(".searchBlock form span[name='spanProgramName']").data('toggle','tooltip');
			myForm.select(".searchBlock form span[name='spanProgramName']").data('placement','right');
			myForm.select(".searchBlock form span[name='spanProgramName']").attr('title',$.trim(_popupInfo['programName']));
			myForm.select(".searchBlock form span[name='spanSystemServiceDesc']").text($.trim(_popupInfo['serviceName']));
			myForm.select(".searchBlock form span[name='spanSystemServiceDesc']").data('toggle','tooltip');
			myForm.select(".searchBlock form span[name='spanSystemServiceDesc']").data('placement','right');
			myForm.select(".searchBlock form span[name='spanSystemServiceDesc']").attr('title',$.trim(_popupInfo['systemServiceDesc']));
			/* Service Logging 상세 내역 조회 */
			var param = formUtil.getValue();
			grid.loadData('lgcom','lgutlc/LGUTLC00100/retrieveServiceLogDetailList', param);
		}
	};
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		// 조회
		if(action == 'search') {
			grid.getGridBase().cancel();
			var param = formUtil.getValue();
			grid.loadData('lgcom','lgutlc/LGUTLC00100/retrieveServiceLogSummaryList', param);
		}
		// 창닫기
		else if(action == 'close') {
			Popup.closePopup(myForm, true);
		}
	});
	/*** 내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//컬럼 설정
		grid.setFields([
			{ fieldName: 'executionYyyymm'      , dataType: 'text'   },
			{ fieldName: 'logSeqNo'             , dataType: 'number' },
			{ fieldName: 'applicationUserId'    , dataType: 'number' },
			{ fieldName: 'employeeName'         , dataType: 'text'   },
			{ fieldName: 'systemCode'           , dataType: 'text'   },
			{ fieldName: 'moduleCode'           , dataType: 'text'   },
			{ fieldName: 'menuId'               , dataType: 'text'   },
			{ fieldName: 'menuName'             , dataType: 'text'   },
			{ fieldName: 'programId '           , dataType: 'text'   },
			{ fieldName: 'programName'          , dataType: 'text'   },
			{ fieldName: 'systemServiceDesc'    , dataType: 'text'   },
			{ fieldName: 'serviceName'          , dataType: 'text'   },
			{ fieldName: 'actualStartTime'      , dataType: 'text'   },
			{ fieldName: 'actualEndTime'        , dataType: 'text'   },
			{ fieldName: 'executionTime'        , dataType: 'number' }
		]);
		grid.setLookupsMultiLvl({
			system: code.get('systemCode'),
			module: {data:code.get('moduleCode'), keyField:['pCode','code']}
		});
		// Grid Column 세팅
		grid.setColumns([
			{
				name:'employeeName',
				fieldName:'employeeName',
				width:80,
				header: {text:'<lgcom:message code="EmployeeName"/>'},
				mergeRule: {criteria:"values['executionYyyymm'] + value"},
				editable: false
			},
			{
				name:'systemCode',
				fieldName:'systemCode',
				width:55,
				header: {text:'<lgcom:message code="System"/>'},
				styles: {textAlignment:'center'},
				mergeRule: {criteria:"values['executionYyyymm'] + values['employeeName'] + value"},
				lookupDisplay: true,
				lookupSourceId: 'system',
				lookupKeyFields: ['systemCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
				editable: false
			},
			{
				name:'moduleCode',
				fieldName:'moduleCode',
				width:60,
				header: {text:'<lgcom:message code="Module"/>'},
				styles: {textAlignment:'center'},
				mergeRule: {criteria:"values['executionYyyymm'] + values['employeeName'] + values['systemCode'] + value"},
				lookupDisplay: true,
				lookupSourceId: 'module',
				lookupKeyFields: ['systemCode','moduleCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
				editable: false
			},
			{
				name:'menuName',
				fieldName:'menuName',
				width:120,
				header: {text:'<lgcom:message code="MenuName"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'programName',
				fieldName:'programName',
				width:150,
				header: {text:'<lgcom:message code="ProgramName"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'serviceName',
				fieldName:'serviceName',
				width:150,
				header: {text:'<lgcom:message code="SystemServiceDesc"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'actualStartTime',
				fieldName:'actualStartTime',
				width:130,
				header: {text:'<lgcom:message code="ActualStartDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'actualEndTime',
				fieldName:'actualEndTime',
				width:130,
				header: {text:'<lgcom:message code="ActualEndDate"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'executionTime',
				fieldName:'executionTime',
				width:60,
				header: {text:'<lgcom:message code="ExecuteTime"/>'},
				styles: {textAlignment:'far',paddingRight:5,numberFormat:'#,##0.0000'},
				editable: false
			}
		]);
		//옵션 설정
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				},
				header: {
					height: 34
				}
			},
			dataProvider: {
				insertable: true,
				updatable: true,
				deletable: true,
				softDeleting: true,
				deleteCreated: true
			},
			display: { fitStyle: 'evenFill' }
		});
		//마우스 오른쪽 클릭시 메뉴
		grid.setContextMenu();
		return grid;
	}
};

LGUTLC00101.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGUTLC00101();
		form.init();
		form.initMyForm();
	});
});
</script>
</head>

<body>
<div class="mdi-container popup">
  <section class="page-content">
	<div class="searchBlock">
		<form class="form search-wrap">
			<input type="hidden" name="executionYyyymm"/>
			<input type="hidden" name="menuId"/>
			<input type="hidden" name="programId"/>
			<input type="hidden" name="systemServiceDesc"/>
				<table class="table">
					<colgroup>
						<col width="100"/>
						<col width="60" />
						<col width="80" />
						<col width="130"/>
						<col width="80" />
						<col width="130"/>
						<col width="110"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="row"><label><lgcom:message code="ExecutionYyyymm"/></label></th>
							<td><span name="spanExecutionYyyymm" class="dispLabel size_60"></span></td>
							<th scope="row"><label><lgcom:message code="MenuName"/></label></th>
							<td><span name="spanMenuName" class="dispLabel size_130"></span></td>
							<th scope="row"><label><lgcom:message code="ProgramName"/></label></th>
							<td><span name="spanProgramName" class="dispLabel size_130"></span></td>
							<th scope="row"><label><lgcom:message code="SystemServiceDesc"/></label></th>
							<td><span name="spanSystemServiceDesc" class="dispLabel size_190"></span></td>
						</tr>
					</tbody>
				</table>
		</form>
	</div>
	<div class="content">
		<div class="grid serviceDetailGrid grid-wrap"></div>
	</div>
	<div class="controls modal-footer">
		<button class="btn btn-gray btn-sm" type="button" data-action="close" ><lgcom:message code="Close" /></button>
	</div>
	</section>
</div>
</body>
</html>
