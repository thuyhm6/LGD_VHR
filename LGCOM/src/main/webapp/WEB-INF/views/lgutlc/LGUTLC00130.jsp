<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGUTLC00130.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2012 LG CNS, All rights reserved.

	설 명 : 본 화면은 Mail Template을 관리하는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGUTLC00130 = function() {
	var myForm = this;
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	/* 팝업용 변수 선언 */
	myForm.popupInfo = {};

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "gridContent"},
		{ name : "gridContent",  left : 0, right : 0, top : "gridControls", bottom : 0 }		
    ]);		
	// 조회조건 Combo 초기화
	var code = new CommonCode('lgcom');
	code.add('systemCode',{codeTypeCode:'LGCOM_SYSTEM_CODE'});
	code.add('moduleCode',{codeTypeCode:'LGCOM_MODULE_CODE'});
	code.add('method',{codeTypeCode:'LGCOM_RECIPIENT_METHOD_CODE'});
	code.add('useFlag',{codeTypeCode:'LGCOM_YN_FLAG'});
	code.execute();
	// 조회조건
	formUtil.initCombo('systemCode',code.get('systemCode'),{selectAll:false});
	formUtil.initCombo('moduleCode',code.get('moduleCode'),{selectAll:true, filter:'systemCode'});
	formUtil.initCombo('useFlag',code.get('useFlag'),{selectAll:true});
	// 기본 시스템 세팅, Use Flag 초기값 Y
	formUtil.setValue({systemCode:SESSION_USER.systemCode,useFlag:'Y'});
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	// 그리드 생성
	var grid = buildGrid('.templateGrid');
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','[data-action]',function(event) {
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
				grid.loadData('lgcom','lgutlc/LGUTLC00130/retrieveMailTemplateMasterList',param);
				break;
			// Add
			case 'insert':
				var cgrid = grid.getGridBase();
				cgrid.commit();
				var curr = cgrid.getCurrent();
				if(curr.itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(curr.itemIndex);
				}
				curr = cgrid.getCurrent();
				cgrid.setValue(curr.itemIndex,'systemCode',$.trim(formUtil.getValue('systemCode')));
				cgrid.setValue(curr.itemIndex,'contentView','N');
				cgrid.setValue(curr.itemIndex,'recipientView','N');
				cgrid.setValue(curr.itemIndex,'useFlag','Y');
				cgrid.setCurrent({column:'systemCode'});
				cgrid.setFocus();
				break;
			// 삭제
			case 'delete':
				grid.getGridBase().deleteSelection(true);
				break;
			// 저장
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
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid.saveChanges('lgcom','lgutlc/LGUTLC00130/saveMailTemplateMasterList', function(data) {
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
	/* Cell 클릭시 상세 조회 */
	grid.getGridBase().onDataCellClicked = function(cgrid, index) {
		if(index.column == 'contentView' || index.column == 'recipientView') {
			var flag = cgrid.getValue(index.itemIndex,index.column);
			myForm.popupInfo["mailId"] = $.trim(cgrid.getValue(index.itemIndex,'mailId'));
			myForm.popupInfo["sendMailName"] = $.trim(cgrid.getValue(index.itemIndex,'sendMailName'));
			if(index.column == 'contentView' && flag == 'Y') {
				var cpop = new Popup(myForm,'lgcom','M_LGUTLC_1194','Mail Template Contents');
				cpop.setSize(800,700);
				cpop.open(function() {
				},function() {
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				});
			}
			else if(index.column == 'recipientView' && flag == 'Y') {
				// 메일 수신자 지정 유형이 변경되었다면 저장을 먼저 한 후 가능함.
				if(cgrid.getValue(index.itemIndex,'mailRecipientMgtMethodCode') != cgrid.getValue(index.itemIndex,'orginRecpMethodCode')) {
					Message.alert('<lgcom:message code="error.Pleasesavedatafirst"/>');
					return;
				}
				var rpop;
				if($.trim(cgrid.getValue(index.itemIndex,'mailRecipientMgtMethodCode')) == 'TEXT') {
					rpop = new Popup(myForm,'lgcom','M_LGUTLC_1195','<lgcom:message code="Recipients"/>');
					rpop.setSize(600,600);
				}
				else if($.trim(cgrid.getValue(index.itemIndex,'mailRecipientMgtMethodCode')) == 'SQL') {
					rpop = new Popup(myForm,'lgcom','M_LGUTLC_1196','<lgcom:message code="Recipients"/>');
					rpop.setSize(800,600);
				}
				rpop.open(function() {
				},function() {
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				});
			}
		}
	};
	/* Grid Row Changed */
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면
		if(!editable) {
			if(cgrid.getValue(newRow,'contentView') == 'Y') {
				cgrid.setColumnProperty('contentView','cursor','pointer');
			} else {
				cgrid.setColumnProperty('contentView','cursor','default');
			}
			if(cgrid.getValue(newRow,'recipientView') == 'Y') {
				cgrid.setColumnProperty('recipientView','cursor','pointer');
			} else {
				cgrid.setColumnProperty('recipientView','cursor','default');
			}
			// 삭제버튼 비활성화
			myForm.select(".gridControls button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('contentView','cursor','default');
			cgrid.setColumnProperty('recipientView','cursor','default');
			// 삭제버튼 활성화
			myForm.select(".gridControls button[data-action='delete']").removeAttr('disabled');
		}
	};
	/***  내부 함수  ***/
	// 그리드 초기화
	function buildGrid(gridId) {
		var realGrid = new RealGrid(myForm, gridId);
		realGrid.setPagingMode(true);
		realGrid.setFields([
			{ fieldName:'mailId'                    , dataType:'number'},
			{ fieldName:'sendMailName'              , dataType:'text'  },
			{ fieldName:'systemCode'                , dataType:'text'  },
			{ fieldName:'moduleCode'                , dataType:'text'  },
			{ fieldName:'senderEmailAddr'           , dataType:'text'  },
			{ fieldName:'mailRecipientMgtMethodCode', dataType:'text'  },
			{ fieldName:'orginRecpMethodCode'       , dataType:'text'  },
			{ fieldName:'contentView'               , dataType:'text'  },
			{ fieldName:'recipientView'             , dataType:'text'  },
			{ fieldName:'useFlag'                   , dataType:'text'  }
		]);
		realGrid.setLookupsMultiLvl({
			system: code.get('systemCode'),
			module: {data:code.get('moduleCode'), keyField:['pCode','code']},
			method: code.get('method'),
			useFlag: code.get('useFlag')
		});
		realGrid.setColumns([
			{
				name:'systemCode',
				fieldName:'systemCode',
				width:80,
				header: {text:'<lgcom:message code="System"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'system',
				lookupKeyFields: ['systemCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'moduleCode',
				fieldName:'moduleCode',
				width:80,
				header: {text:'<lgcom:message code="Module"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'module',
				lookupKeyFields: ['systemCode','moduleCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'sendMailName',
				fieldName:'sendMailName',
				width:250,
				header: {text:'<lgcom:message code="Template"/>'}
			},
			{
				name:'senderEmailAddr',
				fieldName:'senderEmailAddr',
				width:200,
				header: {text:'<lgcom:message code="SenderMail"/>'}
			},
			{
				name:'mailRecipientMgtMethodCode',
				fieldName:'mailRecipientMgtMethodCode',
				width:80,
				header: {text:'<lgcom:message code="AssignMethod"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'method',
				lookupKeyFields: ['mailRecipientMgtMethodCode'],
				editor: {type:'dropDown',textReadOnly:false,commitOnSelect:true,dropDownPosition:'editor'},
			},
			{
				name:'contentView',
				fieldName:'contentView',
				width:70,
				header: {text:'<lgcom:message code="Content"/>'},
				styles: {textAlignment:'center'},
				renderer: {type:'image',smoothing:false},
				styles: {textAlignment:'center', iconLocation:'center', iconIndex:0, iconLocation:'center', iconAlignment:'center'},
				imageList: 'images',
				renderer: {type:'icon',textVisible:false},
				dynamicStyles: [{ criteria:'value = "Y"', styles:{iconIndex:8}}],
				editable: false
			},
			{
				name:'recipientView',
				fieldName:'recipientView',
				width:70,
				header: {text:'<lgcom:message code="Recipient"/>'},
				styles: {textAlignment:'center'},
				renderer: {type:'image',smoothing:false},
				styles: {textAlignment:'center', iconLocation:'center', iconIndex:0, iconLocation:'center', iconAlignment:'center'},
				imageList: 'images',
				renderer: {type:'icon',textVisible:false},
				dynamicStyles: [{ criteria:'value = "Y"', styles:'iconIndex=8'}],
				editable: false
			},
			{
				name:'useFlag',
				fieldName:'useFlag',
				width:80,
				header: {text:'<lgcom:message code="UseFlag"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'useFlag',
				lookupKeyFields: ['useFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			}
		]);
		realGrid.setOptions({
			grid: {
				hideDeletedRows: true,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:true},
				footer: {visible:false},
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
			},
			display: { fitStyle: 'none' }
		});
		// Context Menu Set
		realGrid.setContextMenu();
		return realGrid;
	}
}

LGUTLC00130.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGUTLC00130();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Mail Template</h2>
	</div>
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="80"/>
						<col width="90"/>
						<col width="80"/>
						<col width="90"/>
						<col width="100"/>
						<col width="200"/>
						<col width="100"/>
						<col width="60" />
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label><lgcom:message code="System"/></label></th>
							<td><select class="form-control input-sm" name="systemCode"></select></td>
							<th scope="col"><label><lgcom:message code="Module"/></label></th>
							<td><select class="form-control input-sm" name="moduleCode"></select></td>
							<th scope="col"><label><lgcom:message code="Template"/></label></th>
							<td><input type="text" class="form-control input-sm" name="sendMailName"/></td>
							<th scope="col"><label><lgcom:message code="UseFlag"/></label></th>
							<td><select name="useFlag" class="form-control input-sm"></select></td>
						</tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search"><lgcom:message code="Search"/></button>
		</form>
	</div>
	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">	
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
			</div>
			<div class="btn-group">		
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" data-access="LGUTLC00030/saveBulletinBoardList"><lgcom:message code="save"/></button>
			</div>	
		</div>
	</div>
	<div class="gridContent grip-wrap">
		<div class="grid templateGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
