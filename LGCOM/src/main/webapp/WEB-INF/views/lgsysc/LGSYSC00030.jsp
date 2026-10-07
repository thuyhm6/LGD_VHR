<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGSYSC00030.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2012 LG CNS, All rights reserved.

	설 명 : 본 화면은 사용자 정보를 관리하는 화면입니다.
	작성자 : csseo
-------------------------------------------------------------%>
<%
	java.util.Map user = (java.util.Map)session.getAttribute("USER_SESSION");
	boolean isAdminFlag = false;
	if(user != null) {
		java.util.List<java.util.Map<String, Object>> list = ( java.util.List<java.util.Map<String, Object>>)user.get("roleList");
		for( java.util.Map<String,Object> item : list ) {
			if( item.containsValue("BIZWEB_SYSTEM_ADMINISTRATOR") ) {
				isAdminFlag = true;
				break;
			}
		}
	}
%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00030 = function() {
	var myForm = this;
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');

	// 재직구분 세팅
	var code = new CommonCode('lgcom');
	code.add('resignation',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_SUSP_RESIGNATION_FLAG'});
	code.add('language',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_LANGUAGE_CODE'});
	code.add('defsystem',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_SYSTEM_CODE'});
	code.add('flag',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_YN_FLAG'});
	code.execute();

	formUtil.initCombo('suspResignationFlag',code.get('resignation'),{selectAll:true});
	
	/* 화면 레이아웃 정의 
	myForm.setManagedLayout({  
		searchBlock :{ line : 1, left : 0, top : 0 , right : 0, search : true },
		gridControls:{ line : 2, left : 0, top : 100, right : 0 },
		gridContent :{ line : 3, left : 0, top : 120, right : 0, bottom:0 }
	} );	*/ 

	myForm.setLayout( [ 
		{ name : "searchBlock", left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);
	 
	// 그리드 선언
	var grid = buildGrid('.userListGrid');

	// Selection Mode 변경
    grid.setSelectMode(RealGrid.SELECTION_BLOCKLINE);

	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	// 화면 초기 세팅
	myForm.loadCompleted = function() {
		formUtil.setValue({suspResignationFlag:'C'});
	};
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
			case 'search':
				grid.cancel();
				var param = formUtil.getValue();
				grid.loadData('lgcom','lgsysc/LGSYSC00030/retrieveUserList',param);
				break;
			case 'save':
				grid.commit();
				if(grid.getRowCount() == 0) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				// 변경건이 있는지 체크
				if(!grid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid.saveChanges('lgcom','lgsysc/LGSYSC00030/saveUserList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select("button[data-action='search']").trigger('click');
					});
				});
				break;
			case 'loginas':
				var cgrid = grid.getGridBase();
				// 조회된 건이 없으면 종료
				if(cgrid.getItemCount() == 0) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				}
				// 선택된 행이 없으면 종료
				if(cgrid.getCurrent().itemIndex < 0) {
					Message.alert('<lgcom:message code="note.noselected"/>');
					return;
				}
				// Application User Id
				var userId = $.trim(cgrid.getValue(cgrid.getCurrent().itemIndex,'userId'));
				// 기존 로그인 사용자와 동일한 세션이면 종료
				if(userId == $.trim(SESSION_USER['applicationUserId'])) return;
				var empName = $.trim(cgrid.getValue(cgrid.getCurrent().itemIndex,'localEmployeeName'));
				var mailAddr = $.trim(cgrid.getValue(cgrid.getCurrent().itemIndex,'mailAddr'));
				var ssoId = $.trim(mailAddr.replace(/(\@)+(lgdisplay.com|lgdpartner.com|lgcns.com)+/g,''));
				if(ssoId == '') return;
				Message.confirm('<lgcom:message code="question.loginAs" arguments="'+empName+'"/>', function() {
					var nav = new Navigate('lgcom','region');
					nav.addParam('ssoId',ssoId);
					nav.goGet();
				});
				break;
				
			case "userImportBatch" : 
	        	var param = { "data" : { programId : "LGBATC00010" } };
				Message.confirm('<lgcom:message code="question.userImportBatch"/>', function() {
					myForm.transaction("lgcom", "lgsysc/LGSYSC00030/executeUserImport", param, function( data ){
						Message.alert('<lgcom:message code="note.batchSubmitted"/>');
					});
				});
				break;
		}
	});
	/* 숫자키만 입력 */
	myForm.addEvent('keydown','.searchBlock form input.number',function(event) {
		var code = event.which ? event.which : event.keyCode;
		if(code >= 48 && code <= 57) {
		} else if(96 <= code && code <= 105) {
		} else if(code === 8 || code === 9 || code === 37 || code === 39 || code === 46 || code === 67 || code === 86) {
		} else {
			var val = $.trim($(this).val());
			if(isNaN(val)) {
				val = val.slice(0,-1);
			}
			$(this).val(val);
			event.returnValue = false;
			if(event.preventDefault) event.preventDefault();
		}
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/***  내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId );
		grid.setPagingMode(true);
		//필드 설정
		grid.setFields([
			{ fieldName:'userId'             , dataType:'number'},
			{ fieldName:'employeeNo'         , dataType:'text'  },
			{ fieldName:'employeeName'       , dataType:'text'  },
			{ fieldName:'localEmployeeName'  , dataType:'text'  },
			{ fieldName:'departmentName'     , dataType:'text'  },
			{ fieldName:'mailAddr'           , dataType:'text'  },
			{ fieldName:'languageCode'       , dataType:'text'  },
			{ fieldName:'defaultSystemCode'  , dataType:'text'  },
			{ fieldName:'suspResignationName', dataType:'text'  },
			{ fieldName:'applyStartDate'     , dataType:'text'  },
			{ fieldName:'applyEndDate'       , datatype:'text'  },
			{ fieldName:'requestRegionCode'  , datatype:'text'  },
			{ fieldName:'requestRegionName'  , datatype:'text'  },
			{ fieldName:'timeZoneName'       , datatype:'text'  },
			{ fieldName:'regionUseFlag'      , datatype:'text'  },
			{ fieldName:'originRegionUseFlag', datatype:'text'  },
			{ fieldName:'defaultOrgId'       , datatype:'text'  },
			{ fieldName:'defaultOrgName'     , datatype:'text'  },
			{ fieldName:'orgUseFlag'         , datatype:'text'  },
			{ fieldName:'screenDesignThemeId', datatype:'text'  },
			{ fieldName:'menuUseFlag'        , datatype:'text'  },
			{ fieldName:'ouUseFlag'          , datatype:'text'  }
		]);
		// Lookup 설정
		grid.setLookups({
			language:code.get('language'),
			defsystem:code.get('defsystem'),
			ruseflag:code.get('flag'),
			ouseflag:code.get('flag'),
			museflag:code.get('flag'),
			ouuseflag:code.get('flag')
		});
		//컬럼 설정
		grid.setColumns([
			{
				name:'userId',
				fieldName:'userId',
				width:55,
				header: {text:'<lgcom:message code="UserID"/>'},
				styles: {textAlignment:'far'},
				editor: {type:'number'},
				editable: false
			},
			{
				name:'employeeNo',
				fieldName:'employeeNo',
				width:70,
				header: {text:'<lgcom:message code="EmployeeNo"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'localEmployeeName',
				fieldName:'localEmployeeName',
				width:80,
				header: {text:'<lgcom:message code="EmployeeName"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'employeeName',
				fieldName:'employeeName',
				width:100,
				header: {text:'<lgcom:message code="EmployeeEngName"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'departmentName',
				fieldName:'departmentName',
				width:100,
				header: {text:'<lgcom:message code="Department"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'mailAddr',
				fieldName:'mailAddr',
				width:140,
				header: {text:'<lgcom:message code="E-Mail"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'languageCode',
				fieldName:'languageCode',
				width:64,
				type: 'data',
				header: {text:'<lgcom:message code="Language"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'language',
				lookupKeyFields: ['languageCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'defaultSystemCode',
				fieldName:'defaultSystemCode',
				width:60,
				type: 'data',
				header: {text:'<lgcom:message code="DefaultSystem"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'defsystem',
				lookupKeyFields: ['defaultSystemCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'requestRegionName',
				fieldName:'requestRegionName',
				width:60,
				type: 'data',
				header: {text:'<lgcom:message code="DefaultRegion"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'regionUseFlag',
				fieldName:'regionUseFlag',
				width:70,
				type: 'data',
				header: {text:'<lgcom:message code="RegionFix"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'ruseflag',
				lookupKeyFields: ['regionUseFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'timeZoneName',
				fieldName:'timeZoneName',
				width:70,
				header: {text:'<lgcom:message code="TimezoneName"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'ouUseFlag',
				fieldName:'ouUseFlag',
				width:60,
				type: 'data',
				header: {text:'<lgcom:message code="UseOU"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'ouuseflag',
				lookupKeyFields: ['ouUseFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
				editable: false
			},
			{
				name:'defaultOrgName',
				fieldName:'defaultOrgName',
				width:135,
				header: {text:'<lgcom:message code="DefaultOrg"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'orgUseFlag',
				fieldName:'orgUseFlag',
				width:56,
				type: 'data',
				header: {text:'<lgcom:message code="DefaultOrgFix"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'ouseflag',
				lookupKeyFields: ['orgUseFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'screenDesignThemeId',
				fieldName:'screenDesignThemeId',
				width:56,
				type: 'data',
				header: {text:'<lgcom:message code="Theme"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				values: [ 'A', 'B' ],
				labels: [ '<lgcom:message code="Dark"/>', '<lgcom:message code="Light"/>' ],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'menuUseFlag',
				fieldName:'menuUseFlag',
				width:70,
				type: 'data',
				header: {text:'<lgcom:message code="UserMenuUse"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'museflag',
				lookupKeyFields: ['menuUseFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'suspResignationName',
				fieldName:'suspResignationName',
				width:64,
				header: {text:'<lgcom:message code="InOfficeType"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				type:'group',
				orientation:'horizontal',
				width:148,
				header : { text:'<lgcom:message code="TenureApplyDate"/>', styles:{fontBold:true} },
				columns: [
					{
						name:'applyStartDate',
						fieldName:'applyStartDate',
						width:74,
						type: 'data',
						header: {text:'<lgcom:message code="StartDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'applyEndDate',
						fieldName:'applyEndDate',
						width:74,
						type: 'data',
						header: {text:'<lgcom:message code="EndDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
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
				footer: {visible:false},
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				},
				header: {
					height: 40
				}
			},
			display: { fitStyle: 'none' }
		});

		// Context Menu Set
		grid.setContextMenu();

		return grid;
	}
}

LGSYSC00030.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00030();
		form.init();
		form.loadCompleted();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="UserList"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="90"/>
						<col width="220"/>
						<col width="60"/>
						<col width="180"/>
						<col width="90"/>
						<col width="120"/>
						<col width="*"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label><lgcom:message code="Department"/></label></th>
							<td>
								<input type="text" name="deptName" class="form-control input-sm" placeholder=""/>
								<input type="hidden" name="deptCode"/>
							</td>
							<th scope="col"><label><lgcom:message code="UserID"/></label></th>
							<td><input type="text" name="userId" class="form-control input-sm number" maxlength="6" placeholder=""/></td>
							<th scope="col"><label><lgcom:message code="EmployeeNo"/></label></th>
							<td><input type="text" name="employeeNo" class="form-control input-sm" placeholder=""/></td>
						</tr>
						<tr>
							<th scope="col"><label><lgcom:message code="EmployeeName"/></label></th>
							<td><input type="text" name="employeeName" class="form-control input-sm" placeholder=""/></td>
							<th scope="col"><label><lgcom:message code="E-Mail"/></label></th>
							<td><input type="text" name="mailAddr" class="form-control input-sm" placeholder=""/></td>
							<th scope="col"><label><lgcom:message code="InOfficeType"/></label></th>
							<td><select name="suspResignationFlag" class="form-control input-sm"></select></td>
						</tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search" data-access="LGSYSC00030/retrieveUserList"><lgcom:message code="search"/></button>
			</form>
		</div>
		<div class="gridControls module-group text-right">
            <div class="btn-toolbar">
                <%if(isAdminFlag){%>
                <div class="btn-group">
                    <button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="userImportBatch"><i class="fa fa-play" aria-hidden="true"></i> <lgcom:message code="UserImportBatch"/></button>
                    <button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="loginas"><i class="fa fa-lock" aria-hidden="true"></i> <lgcom:message code="LoginAs"/></button>
                </div>
                <%}%>
                <div class="btn-group">
                    <button class="btn btn-gray btn-sm" type="button" role="button" data-action="save" data-access="LGSYSC00030/saveUserList"><lgcom:message code="save"/></button>
                </div>
            </div>
        </div>
		<%-- <div class="module-group clearfix">
            <%if(isAdminFlag){%>
			<button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="userImportBatch"><i class="fa fa-play" aria-hidden="true"></i> <lgcom:message code="UserImportBatch"/></button>
			<button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="loginas"><i class="fa fa-lock" aria-hidden="true"></i> <lgcom:message code="LoginAs"/></button>
			<!-- <div class="divider"></div> -->
            <%}%>
			<button class="btn btn-gray btn-sm" type="button" role="button" data-action="save" data-access="LGSYSC00030/saveUserList"><lgcom:message code="save"/></button>
		</div> --%>
		<div class="gridContent grid-wrap">
			<div class="grid userListGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
