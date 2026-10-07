<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGUTLC00030.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2012 LG CNS, All rights reserved.

	설 명 : 본 화면은 게시판 속성을 관리하는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGUTLC00030 = function() {
	var myForm = this;
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "gridContent"},
		{ name : "gridContent",  left : 0, right : 0, top : "gridControls", bottom : 0 }		
    ]);	
    
	// Setting System, Use Flag Combo
	var code = new CommonCode('lgcom');
	code.add('systemCode',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_SYSTEM_CODE'});
	code.add('useFlag',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_YN_FLAG'});
	code.execute();
	formUtil.initCombo('systemCode',code.get('systemCode'),{selectAll:true});
	formUtil.initCombo('useFlag',code.get('useFlag'),{selectAll:true});
	// 기본 시스템 세팅, Use Flag 초기값 Y
	formUtil.setValue({systemCode:SESSION_USER.systemCode,useFlag:'Y'});
	// 그리드 초기화
	var grid = buildGrid('.boardMasterGrid');
	/***  이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'search':
				grid.getGridBase().cancel();
				var param = formUtil.getValue();
				grid.loadData('lgcom','lgsysc/LGUTLC00030/retrieveBulletinBoardList', param);
				break;
			case 'insert':
				var cgrid = grid.getGridBase();
				cgrid.commit();
				var curr = cgrid.getCurrent();
				if(curr.itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(curr.itemIndex);
				}
				cgrid.setValue(cgrid.getCurrent().itemIndex,'bbReplyEnabledFlag','N');
				cgrid.setValue(cgrid.getCurrent().itemIndex,'bbShortReplyEnabledFlag','N');
				cgrid.setValue(cgrid.getCurrent().itemIndex,'bbAttachFileEnableFlag','N');
				cgrid.setValue(cgrid.getCurrent().itemIndex,'bbUseFlag','Y');
				cgrid.setCurrent({column:'systemCode'});
				cgrid.setFocus();
				break;
			case 'delete':
				grid.getGridBase().deleteSelection(true);
				break;
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
					grid.saveChanges('lgcom','lgsysc/LGUTLC00030/saveBulletinBoardList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select("button[data-action='search']").trigger('click');
					});
				});
				break;
		}
	});
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 System, Board ID 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('systemCode','editable',false);
			cgrid.setColumnProperty('bulletinBoardId','editable',false);
			// 삭제버튼 비활성화
			myForm.select(".gridControls button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('systemCode','editable',true);
			cgrid.setColumnProperty('bulletinBoardId','editable',true);
			cgrid.setCellStyles(newRow,'systemCode','addStyle');
			cgrid.setCellStyles(newRow,'bulletinBoardId','addStyle');
			cgrid.setCellStyles(newRow,'bulletinBoardTitle','addStyle');
			cgrid.setCellStyles(newRow,'bulletinBoardTypeCode','addStyle');
			cgrid.setCellStyles(newRow,'bbUseFlag','addStyle');
			// 삭제버튼 활성화
			myForm.select(".gridControls button[data-action='delete']").removeAttr('disabled');
		}
	};
	grid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	/***  내부 함수  ***/
	// 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
			{ fieldName:'systemCode'              },
			{ fieldName:'bulletinBoardId'         },
			{ fieldName:'bulletinBoardTitle'      },
			{ fieldName:'bulletinBoardTypeCode'   },
			{ fieldName:'bbShortReplyEnabledFlag' },
			{ fieldName:'bbReplyEnabledFlag'      },
			{ fieldName:'bbAttachFileEnableFlag'  },
			{ fieldName:'bbUseFlag'               }
		]);
		// Lookup 조회, key 속성에 lookup에 매핑될 lookupSourceId 값을 사용한다.
		code.add('boardType',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_BOARD_TYPE_CODE'});
		code.add('replyFlag',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_YN_FLAG'});
		code.add('commentFlag',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_YN_FLAG'});
		code.add('attachFlag',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_YN_FLAG'});
		code.execute();
		grid.setLookups({
			'system':code.get('systemCode'),
			'boardType':code.get('boardType'),
			'replyFlag':code.get('replyFlag'),
			'commentFlag':code.get('commentFlag'),
			'attachFlag':code.get('attachFlag'),
			'useFlag':code.get('useFlag')
		});

		// Grid Column Set
		grid.setColumns([
			{
				name:'systemCode',
				fieldName:'systemCode',
				width:70,
				header: {text:'<lgcom:message code="System"/>', required: true},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'system',
				lookupKeyFields: ['systemCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'bulletinBoardId',
				fieldName:'bulletinBoardId',
				width:130,
				header: {text:'<lgcom:message code="BoardId"/>', required: true},
			},
			{
				name:'bulletinBoardTitle',
				fieldName:'bulletinBoardTitle',
				width:280,
				header: {text:'<lgcom:message code="BoardName"/>',required: true},
			},
			{
				name:'bulletinBoardTypeCode',
				fieldName:'bulletinBoardTypeCode',
				width:110,
				header: {text:'<lgcom:message code="BoardType"/>', required: true},
				lookupDisplay: true,
				lookupSourceId: 'boardType',
				lookupKeyFields: ['bulletinBoardTypeCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'bbReplyEnabledFlag',
				fieldName:'bbReplyEnabledFlag',
				width:70,
				header: {text:'<lgcom:message code="ReplyFlag"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'replyFlag',
				lookupKeyFields: ['bbReplyEnabledFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'bbShortReplyEnabledFlag',
				fieldName:'bbShortReplyEnabledFlag',
				width:70,
				header: {text:'<lgcom:message code="CommentFlag"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'commentFlag',
				lookupKeyFields: ['bbShortReplyEnabledFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'bbAttachFileEnableFlag',
				fieldName:'bbAttachFileEnableFlag',
				width:70,
				type: 'data',
				header: {text:'<lgcom:message code="AttachFlag"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'attachFlag',
				lookupKeyFields: ['bbAttachFileEnableFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'bbUseFlag',
				fieldName:'bbUseFlag',
				width:70,
				type: 'data',
				header: {text:'<lgcom:message code="UseFlag"/>', required: true},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'useFlag',
				lookupKeyFields: ['bbUseFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			}
		]);

		grid.setOptions({
			grid: {
				hideDeletedRows:false,
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
					height: 30
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
		// Validation Set
		grid.setValidations([
			{criteria: "value['systemCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='System'/>"/>',mode:'always',level:'error'},
			{criteria: "value['bulletinBoardId'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='BoardId'/>"/>',mode:'always',level:'error'},
			{criteria: "value['bulletinBoardTitle'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='BoardName'/>"/>',mode:'always',level:'error'},
			{criteria: "value['bulletinBoardTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='BoardType'/>"/>',mode:'always',level:'error'},
			{criteria: "value['bbUseFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='UseFlag'/>"/>',mode:'always',level:'error'}
		]);
		return grid;
	}
};

LGUTLC00030.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGUTLC00030();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Board Master</h2>
	</div>
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="100"/>
						<col width="80" />
						<col width="100"/>
						<col width="200"/>
						<col width="100"/>
						<col width="60" />
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label><lgcom:message code="System"/></label></th>
							<td><select name="systemCode" class="form-control input-sm"></select></td>
							<th scope="col"><label><lgcom:message code="BoardName"/></label></th>
							<td><input type="text" name="boardName" class="form-control input-sm" placeholder=""/></td>
							<th scope="col"><label><lgcom:message code="UseFlag"/></label></th>
							<td><select name="useFlag" class="form-control input-sm"></select></td>
						</tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search" data-access="LGUTLC00030/retrieveBulletinBoardList"><lgcom:message code="search"/>
		</form>		
	</div>
	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">			
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
			</div>	
			<div class="btn-group">			
				<button class="btn btn-gray btn-sm" type="button" role="button" data-action="save" data-access="LGUTLC00030/saveBulletinBoardList"><lgcom:message code="save"/></button>
			</div>
		</div>		
	</div>
	<div class="gridContent grid-wrap">
		<div class="grid boardMasterGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
