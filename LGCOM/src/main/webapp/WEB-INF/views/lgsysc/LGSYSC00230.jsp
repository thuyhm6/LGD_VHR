<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSYSC00230.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 :  Role Sup User를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Role Super User</title>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00230 = function() {
	var myForm = this;
	/* Form util 선언 */
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	/* 팝업용 변수 선언 */
	myForm.popupInfo = {rolePopup:{}, userPopup:{}, roleUserPopup:{}};

	
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "gridContent"},
		{ name : "gridContent",  left : 0, right : 0, top : "gridControls", bottom : 0 }		
    ]);	
    
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	// 조회조건 Combo 초기화
	var code = new CommonCode('lgcom');
	code.add('systemCode',{codeTypeCode:'LGCOM_SYSTEM_CODE'});
	code.add('assignFlag',{codeTypeCode:'LGCOM_YN_FLAG'});
	code.add('mailControl',{codeTypeCode:'LGCOM_YN_FLAG'});
	code.execute();
	formUtil.initCombo('systemCode',code.get('systemCode'),{selectAll:true});
	formUtil.initCombo('assignFlag',code.get('assignFlag'),{selectAll:true});
	formUtil.initCombo('mailControl',code.get('mailControl'),{selectAll:true});
	// 기본 시스템 세팅, Control Flag 'Y'
	formUtil.setValue({systemCode:SESSION_USER.systemCode,assignFlag:'Y'});
	// 그리드 선언
	var grid = buildGrid('.superUserListGrid');
	/***  이벤트 핸들러  ***/
	// 버튼 이벤트
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			// 조회
			case 'search':
				grid.getGridBase().cancel();
				var param = formUtil.getValue();
				grid.loadData('lgcom','lgsysc/LGSYSC00230/retrieveReponsibilitySuperUserList', param);
				break;
			// Detail
			case 'detail':
				var cgrid = grid.getGridBase();
				if(cgrid.getCurrent().itemIndex < 0) return;
				// Popup Open을 위한 Parameter 조합
				myForm.popupInfo.roleUserPopup['applicationId'] = $.trim(cgrid.getValue(cgrid.getCurrent().itemIndex,'applicationId'));
				myForm.popupInfo.roleUserPopup['responsibilityId'] = $.trim(cgrid.getValue(cgrid.getCurrent().itemIndex,'responsibilityId'));
				myForm.popupInfo.roleUserPopup['responsibilityKey'] = $.trim(cgrid.getValue(cgrid.getCurrent().itemIndex,'responsibilityKey'));
				myForm.popupInfo.roleUserPopup['responsibilityName'] = $.trim(cgrid.getValue(cgrid.getCurrent().itemIndex,'responsibilityName'));
				myForm.popupInfo.roleUserPopup['section'] = $.trim(cgrid.getValue(cgrid.getCurrent().itemIndex,'section'));
				var rupopup = new Popup(myForm,'lgcom','M_LGSYSC_1148','<lgcom:message code="RoleUserList"/>');
				rupopup.setSize(740,412);
				rupopup.open(function() {
				});
				break;
			// Save
			case 'save':
				try {
					grid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
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
					grid.saveChanges('lgcom','lgsysc/LGSYSC00230/saveResponsibilitySuperUserList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select("button[data-action='search']").trigger('click');
					});
				});
				break;
		}
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 Program ID 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('responsibilityName','editable',false);
			cgrid.setColumnProperty('responsibilityName','button','none');
			// 삭제버튼 활성화
			myForm.select(".gridControls button[data-action='delete']").prop('disabled',true);
		} else {
			cgrid.setColumnProperty('responsibilityName','editable',true);
			cgrid.setColumnProperty('responsibilityName','button','action');
			// 삭제버튼 비활성화
			myForm.select(".gridControls button[data-action='delete']").prop('disabled',false);
			// 필수항목 표시
			cgrid.setCellStyles(newRow,'responsibilityName','addStyle');
			cgrid.setCellStyles(newRow,'employeeDesc','addStyle');
			cgrid.setCellStyles(newRow,'section','addStyle');
			cgrid.setCellStyles(newRow,'org','addStyle');
			cgrid.setCellStyles(newRow,'domain','addStyle');
			cgrid.setCellStyles(newRow,'mailSendFlag','addStyle');
		}
	};
	/* Grid Popup 핸들 */
	grid.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);
		if(column.name == 'responsibilityName') {
			myForm.popupInfo.rolePopup['searchMode'] = 'single';
			myForm.popupInfo.rolePopup['row'] = itemIndex;
			myForm.popupInfo.rolePopup['col'] = column.name;
			myForm.popupInfo.rolePopup['extraType'] = '';
			myForm.popupInfo.rolePopup['extraOwn'] = false;
			myForm.popupInfo.rolePopup['ownUserId'] = '';
			myForm.popupInfo.rolePopup['findKey'] = $.trim(gridRow.responsibilityName);
			myForm.popupInfo.rolePopup['roleData'] = [];
			var rolepop = new Popup(myForm,'lgcom','M_LGUTLC_1141','<lgcom:message code="RoleSearch"/>');
			rolepop.setSize(740,412);
			rolepop.open(function() {
				var array = myForm.popupInfo.rolePopup.roleData;
				if(array.length == 0) return;
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'applicationId',array[0].applicationId);
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'responsibilityId',array[0].responsibilityId);
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'responsibilityKey',array[0].roleCode);
				cgrid.setValue(myForm.popupInfo.rolePopup.row,'responsibilityName',array[0].roleName);
				cgrid.commit();
				myForm.popupInfo.rolePopup.roleData = [];
			});
		}
		else if(column.name == 'employeeDesc') {
			// 입력된 사용자명을 세팅한다.
			myForm.popupInfo.userPopup['searchMode'] = 'single';
			myForm.popupInfo.userPopup['employeeName'] = $.trim(gridRow.employeeDesc);
			// 팝업을 호출한다.
			var popup = new Popup(myForm,'lgcom','M_LGUTLC_1142','<lgcom:message code="UserSearch"/>');
			popup.setSize(800,494);	// searchMode 'Single'
			popup.open(function() {
				var retData = myForm.popupInfo.userPopup['userData'];
				if(retData) {
					cgrid.setValue(itemIndex,'employeeName',$.trim(retData[0].employeeName));
					cgrid.setValue(itemIndex,'employeeNum',$.trim(retData[0].employeeNo));
					cgrid.setValue(itemIndex,'team',$.trim(retData[0].teamName));
					cgrid.setValue(itemIndex,'emailAddress',$.trim(retData[0].mailAddr));
					cgrid.setValue(itemIndex,'employeeDesc',$.trim(retData[0].employeeDesc));
				}
				myForm.popupInfo.userPopup = null;
				myForm.popupInfo.userPopup = {};
			});
		}
	};
	/* Grid Popup 핸들 */
	grid.getGridBase().onEditChange = function(cgrid, index, value) {
		if(index.column == 'responsibilityName') {
			if($.trim(value) == '') {
				cgrid.setValue(index.itemIndex,'applicationId','');
				cgrid.setValue(index.itemIndex,'responsibilityId','');
				cgrid.setValue(index.itemIndex,'responsibilityKey','');
				cgrid.setValue(index.itemIndex,'responsibilityName','');
			}
		}
		else if(index.column == 'employeeDesc') {
			if($.trim(value) == '') {
				cgrid.setValue(index.itemIndex,'employeeName','');
				cgrid.setValue(index.itemIndex,'employeeNum','');
				cgrid.setValue(index.itemIndex,'team','');
				cgrid.setValue(index.itemIndex,'emailAddress','');
				cgrid.setValue(index.itemIndex,'employeeDesc','');
			}
		}
	};
	/*** 내부 함수 ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		grid.setFields([
			{ fieldName: 'applicationId'        , dataType: 'number' },
			{ fieldName: 'responsibilityId'     , dataType: 'number' },
			{ fieldName: 'responsibilityKey'    , dataType: 'text'   },
			{ fieldName: 'responsibilityName'   , dataType: 'text'   },
			{ fieldName: 'employeeName'         , dataType: 'text'   },
			{ fieldName: 'employeeNum'          , dataType: 'text'   },
			{ fieldName: 'team'                 , dataType: 'text'   },
			{ fieldName: 'emailAddress'         , dataType: 'text'   },
			{ fieldName: 'employeeDesc'         , dataType: 'text'   },
			{ fieldName: 'section'              , dataType: 'text'   },
			{ fieldName: 'domain'               , dataType: 'text'   },
			{ fieldName: 'org'                  , dataType: 'text'   },
			{ fieldName: 'txnFlag'              , dataType: 'text'   },
			{ fieldName: 'intfFlag'             , dataType: 'text'   },
			{ fieldName: 'mailSendFlag'         , dataType: 'text'   },
			{ fieldName: 'respKorDesc'          , dataType: 'text'   },
			{ fieldName: 'respChnDesc'          , dataType: 'text'   },
			{ fieldName: 'respEngDesc'          , dataType: 'text'   }
		]);
		// Lookup 설정
		code.execute('maillingFlag',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_YN_FLAG'});
		code.execute('domainCode',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_SYSTEM_CODE'});
		grid.setLookups({
			'maillingFlag':code.get('maillingFlag'),
			'domainCode':code.get('domainCode'),
		});
		//컬럼 설정
		grid.setColumns([
			{
				name:'responsibilityName',
				fieldName:'responsibilityName',
				width:180,
				header: {text:'<lgcom:message code="RoleName"/>'},
				renderer: {showTooltip:true},
				editable: false
			},
			{
				name:'employeeDesc',
				fieldName:'employeeDesc',
				width:200,
				header: {text:'<lgcom:message code="SuperUser"/>'},
				renderer: {showTooltip:true},
				button: 'action'
			},
			{
				name:'domain',
				fieldName:'domain',
				width:80,
				header: {text:'<lgcom:message code="System"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'domainCode',
				lookupKeyFields: ['domain'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'mailSendFlag',
				fieldName:'mailSendFlag',
				width:80,
				header: {text:'<lgcom:message code="MailControl"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'maillingFlag',
				lookupKeyFields: ['mailSendFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
				editable: false
			},
			{
				type:'group',
				orientation:'horizontal',
				width:600,
				header : {text:'<lgcom:message code="Description"/>', styles:{fontBold:true} },
				columns: [
					{
						name: 'respKorDesc',
						fieldName:'respKorDesc',
						width:200,
						header: {text:'<lgcom:message code="Korean"/>'},
						renderer: {showTooltip:true}
					},
					{
						name: 'respChnDesc',
						fieldName:'respChnDesc',
						width:200,
						header: {text:'<lgcom:message code="Chinese"/>'},
						renderer: {showTooltip:true}
					},
					{
						name: 'respEngDesc',
						fieldName:'respEngDesc',
						width:200,
						header: {text:'<lgcom:message code="English"/>'},
						renderer: {showTooltip:true}
					}
				]
			}
		]);
		// Validation Set
		grid.setValidations([
			{criteria: "value['responsibilityName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='RoleName'/>"/>',mode:'always',level:'error'},
			{criteria: "value['domain'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='System'/>"/>',mode:'always',level:'error'}
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
			dataProvider: {
				insertable: true,
				updatable: true,
				deletable: true,
				softDeleting: true,
				deleteCreated: true
			},
			display: { fitStyle: 'even' }
		});
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
}

LGSYSC00230.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00230();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Role Super User</h2>
	</div>
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table" >
					<colgroup>
						<col width="80"/>
						<col width="200"/>
						<col width="80"/>
						<col width="120"/>
						<col width="70"/>
						<col width="80"/>
						<col width="90"/>
						<col width="60"/>
						<col width="90"/>
						<col width="60"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="row"><lgcom:message code="RoleName"/></th>
							<td><input type="text" name="roleName" class="form-control input-sm" placeholder=""/></td>
							<th scope="row"><lgcom:message code="SuperUser"/></th>
							<td><input type="text" name="employeeName" class="form-control input-sm"/></td>
							<th scope="row"><lgcom:message code="System"/></th>
							<td><select name="systemCode" class="form-control input-sm"></select></td>
							<th scope="row"><lgcom:message code="AssignFlag"/></th>
							<td><select name="assignFlag" class="form-control input-sm size_60"></select></td>
							<th scope="row"><lgcom:message code="MailControl"/></th>
							<td><select name="mailControl" class="form-control input-sm size_60"></select></td>
						</tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search"><lgcom:message code="search"/></button>
		</form>
	</div>
	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">	
				<button class="btn btn-default btn-sm" type="button" role="button" data-action="detail"><lgcom:message code="Detail"/></button>
			</div>	
			<div class="btn-group">					
				<button class="btn btn-gray btn-sm" type="button" role="button" data-action="save" data-access="LGSYSC00230/saveRoleSuperUserList"><lgcom:message code="save"/></button>
			</div>
		</div>		
	</div>
	<div class="gridContent grid-wrap">
		<div class="grid superUserListGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
