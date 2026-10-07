<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSYSC00120.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 role별 조직 정보를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Role Org</title>
<style type="text/css">
.content {
	clear:both;
	height:400px;
}
.division {
	height:100%;
}


.gridControls {
    width : auto;
}

</style>
<script type="text/javascript">
var LGSYSC00120 = function(){
    var grid1, grid2;
    var myForm = this;
    
    var formUtil = new FormUtil(myForm,'.searchBlock form');
    var orgForm = new FormUtil( myForm, ".orgType");
    
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name  : "gridControls", left : 0, right : 0, top : "searchBlock" },
		{ name  : "contentGrid1",  left : 0, right : 0, top : "gridControls", width : 650, bottom : 0 },	 	
		{ name  : "organizationGrid",  left : "contentGrid1", right : 0, top : "gridControls", bottom : 0},		
	]); 
    
    // combo 목록 조회
	var code = new CommonCode("lgcom");
	code.add( "LGCOM_SYSTEM_CODE", { codeTypeCode:'LGCOM_SYSTEM_CODE' });
	code.add( "LGCOM_MODULE_CODE", { codeTypeCode:'LGCOM_MODULE_CODE' });
	code.add( "LGCOM_ORGANIZATION_TYPE_CODE", { codeTypeCode:'LGCOM_ORGANIZATION_TYPE_CODE' });
	code.execute();
	
	formUtil.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE"), {selectAll : true } );
	formUtil.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE"), {selectAll : true, filter : "systemCode" } );
	orgForm.initCombo( "organizationId", code.get("LGCOM_ORGANIZATION_TYPE_CODE") );	
    
   	grid1 = buildGrid("LGSYSC00120_grid1");
   	grid2 = buildGrid("LGSYSC00120_grid2");

   	myForm.loadCompleted = function() {
   		orgForm.setValue({organizationId:'C'});
	};
  	
    myForm.select(".organizationGrid .grid").show(0);
    
    this.addEvent("change", ".gridControls select", function(){
    	var value = $(this).val();
        myForm.select(".organizationGrid .grid").hide(0);
        myForm.select(".organizationGrid .grid[data-target='"+ value +"']").show( 0, function(){
        	
        	if( value == "C" ) {
        		grid2.resetSize();
        	} 
        	
        });
        
        var row = 0;
	    var current = grid1.getGridBase().getCurrent();
    
	    if ( current.itemIndex < 0 ) {
	    	return;
	    } else {
	        row = Math.max(0, current.dataRow);
	        
		    var rowData = grid1.getDataProvider().getJsonRow(row);
		    
		    myForm.select(".gridControls button[data-action='expand']").removeAttr('disabled');
		    myForm.select(".gridControls button[data-action='collapse']").removeAttr('disabled');
		    
		    setGridVal(value, rowData.roleCode);	        
	    }	    
    });   	
   
    /* 그리드 이벤트 처리 */
    grid1.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
    	if(newRow < 0) return;
    	var rowData = grid1.getDataProvider().getJsonRow(newRow);
		var value = $(".form.orgType select").val();
		setGridVal(value, rowData.roleCode);
    }
    /*
	grid1.getGridBase().onDataCellClicked = function(grid, index) {    	
		var rowData = grid1.getDataProvider().getJsonRow(index.dataRow);
		var value = $(".form.orgType select").val();
		setGridVal(value, rowData.roleCode);
	};
	*/
	/*** 부모메뉴 선택/해제시 자식노드 전체 선택/해제 ***/
	grid2.getGridBase().onItemChecked = function (grid, itemIndex, checked) {	
		var gridProvider = grid2.getDataProvider();
		var gridMain = grid2.getGridBase();
		treeChecked(gridProvider, gridMain, itemIndex, checked);
	}	
	
	
	function treeChecked(gridProvider, gridMain, index, checked) {
	    index = gridMain.getDataRow(index);
	    var childrens = gridProvider.getChildren(index);
	    var cdrows = [];
	    if (childrens != null) {
	        $.each(childrens, function(k, v) {
	            if (v < 0)
	                return false;
	            cdrows.push(v);
	        })
	        gridMain.checkRows(cdrows, checked);
	    }
	}
	
	/*** 이벤트 핸들러  ***/
	this.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "search" :
		    	grid1.getGridBase().cancel();
		    	grid2.getDataProvider().clearRows();
				var param =  myForm.select(".searchBlock form").toJSON();			
				grid1.loadData('lgcom','lgsysc/LGSYSC00090/retrieveRoleList', param );
				if(grid1.getDataProvider().getRowCount() > 0){
		    		var index = {itemIndex: 0};				
					grid1.getGridBase().setCurrent(index);
		    	}	
				break;
			
		    case "save" :		    	
		    	var grid;
		    	var selValue = $(".form.orgType select").val();
		    	if(selValue=='C'){
		    		grid = grid2;
		    	}
		    	
		    	grid.getGridBase().commit();		    		    	
			    grid.getGridBase().expandAll();
		    	
		    	for(var i=0; i < grid.getRowCount(); i++){
		    		if(grid.getGridBase().isCheckedRow(grid.getGridBase().getDataRow(i))){		    		
		    			grid.getDataProvider().setRowState(grid.getGridBase().getDataRow(i), "created", false);
		    		}else{
		    			grid.getDataProvider().setRowState(grid.getGridBase().getDataRow(i), "none", false);
		    		}		    		
		    	}  
		    	
		    	grid.getGridBase().collapseAll();
		    	
		    	
				if( grid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					var masterData = grid1.getGridBase().getValues( grid1.getGridBase().getCurrent().itemIndex );
					var orgData = orgForm.getValue();
				
					var paramter = {roleCode: masterData.roleCode, orgType: orgData.organizationId };
					grid.useProgress(true);
					grid.saveChanges('lgcom','lgsysc/LGSYSC00120/saveRoleOrgList', paramter, function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				
		    	break;
		    	
		    case "expand" :
		    	var selValue = $(".form.orgType select").val();
		    	if(selValue=='C'){
		    		grid2.getGridBase().expandAll();
		    	}
		    	
		    	break;
		    	
		    case "collapse" :
		    	var selValue = $(".form.orgType select").val();
		    	if(selValue=='C'){
		    		grid2.getGridBase().collapseAll();
		    	}
		    	break;
		}
	});
	
	/*** 내부 함수  ***/
    //그리드 초기화 
	function buildGrid(gridId) {
		var grid;
		switch(gridId) {
			case 'LGSYSC00120_grid1':	
				grid = new RealGrid(myForm, gridId);
				grid.setPagingMode(true);
				//필드 설정
				grid.setFields(
						[
							{ fieldName:'systemCode'     , dataType:'text'  },
							{ fieldName:'moduleCode'     , dataType:'text'  },
							{ fieldName:'roleCode'       , dataType:'text'  },
							{ fieldName:'roleName'       , dataType:'text'  }
						]
				);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				//컬럼 설정 
				grid.setColumns(
						[
							{
								name:'systemCode',
								fieldName:'systemCode',
								width:80,
								header: {text:'<lgcom:message code="System"/>'},
								styles: {textAlignment:'center'},
								editable: false
							},
							{
								name:'moduleCode',
								fieldName:'moduleCode',
								width:80,
								header: {text:'<lgcom:message code="Module"/>'},
								styles: {textAlignment:'center'},
								editable: false
							},
							{
								name:'roleCode',
								fieldName:'roleCode',
								width:150,
								header: {text:'<lgcom:message code="RoleCode"/>'},
								editable: false
							},
							{
								name:'roleName',
								fieldName:'roleName',
								width:150,
								header: {text:'<lgcom:message code="RoleName"/>'},
								editable: false
							},
						]
				);
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
						edit: {
							insertable: true,
							appendable: true,
							updatable: true,
							deletable: true
						}
					},
					display: { fitStyle: 'evenFill' }
				});	
			break;
			case 'LGSYSC00120_grid2':
				grid = new RealGrid(myForm, gridId, 'treeview' );
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
						edit: {
							insertable: true,
							appendable: true,
							updatable: true,
							deletable: true
						}
					},
					display: { fitStyle: 'evenFill' }
				});	
				//필드 설정
				grid.setFields(
						[
							{ fieldName:'businessGroupId'	, dataType:'text'  },
							{ fieldName:'businessGroupName'	, dataType:'text'  },
							{ fieldName:'companyId'			, dataType:'text'  },
							{ fieldName:'companyName'		, dataType:'text'  },
							{ fieldName:'ynFlag'			, dataType:'text'  }
						]
				);
				//컬럼 설정 
				grid.setColumns(
						[
							{
								name:'businessGroupName',
								fieldName:'businessGroupName',
								width:100,
								type:'data',
								header: {text:'<lgcom:message code="BusinessGroup"/>'},
								editable: false
							},
							{
								name:'companyName',
								fieldName:'companyName',
								width:150,
								type:'data',
								header: {text:'<lgcom:message code="CompanyName"/>'},	
								editable: false
							}
						]
				);
				break;
				
		}
		return grid;		
	}	
	
	//grid1클릭 이벤트 및 grid2,3,4,5,6,7의 셀렉트 박스 change이벤트 발생시 그리드 호출 이벤트
	function setGridVal(value, roleCode){
		switch(value){
    	case 'C':
    		grid2.loadData('lgcom','lgsysc/LGSYSC00120/retrieveRoleOrgList',{roleCode: roleCode, orgType: value},function (provider) {
    			//전체 그리드 로우수 체크 , 수만큼 돌려서 ynFlag가 Y인놈은 체크
    			var indexList = [];
    			grid2.getGridBase().expandAll();
    			var gridCount = grid2.getDataProvider().getRowCount();       			
    			
    			for(var inx = 0; inx < gridCount; inx++){
    				var rData = grid2.getDataProvider().getJsonRow(grid2.getGridBase().getDataRow(inx));	
    				if(rData.ynFlag=='Y'){	
    					var parentInx = grid2.getGridBase().getParent(inx);
    					indexList.push(inx);
    					indexList.push(parentInx);
    				}    				
    			}               
    			grid2.getGridBase().checkItems(indexList,true); 
    			grid2.getGridBase().collapseAll();
    			
    		});
    		break;
    	
    	}
	}
}

LGSYSC00120.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {	
	launch(function(){
		var form = new LGSYSC00120();
		form.init();
		form.loadCompleted();
	});
});

</script>
<style>
</style>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
	    <h2>Role Org</h2>
	</div>
	
	<div class="searchBlock">
		<form class="form search-wrap">
		        <table class="table" >
		            <colgroup>
		                <col width="90">
		                <col width="90">
		                <col width="90">
		                <col width="90">
		                <col width="120">
		                <col width="180">
		                <col width="120">
		                <col width="220">
		            </colgroup>
		            <tbody>
		                <tr>
		                    <th><label class="required"><lgcom:message code="System" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="systemCode"></select>
		                    </td>
		                    
		                    <th><label ><lgcom:message code="Module" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="moduleCode"></select>
		                    </td>
		                    
		                    <th><label><lgcom:message code="RoleCode" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="roleCode"></td>
		                    
		                    <th><label><lgcom:message code="RoleName" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="roleName"></td>		                    

		                </tr>
		            </tbody>
		        </table>
		    <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
		</form>	
	</div>
	
    <div class="contentGrid1 grid-wrap">
		<div id="LGSYSC00120_grid1" class="grid"></div>
	</div>


	<div class="gridControls module-group text-right" >

		<div class="btn-toolbar">	
		    <div class="btn-group">
	             <form class="form orgType">
                     <label><lgcom:message code="OrganizationType"/> </label>	
					 <select id="organizationId" name="organizationId" class="form-control input-sm size_120" style="display: inline;"></select>
				 </form>   			    
	        </div>		
			<div class="btn-group">	
			    <button class="btn btn-default btn-sm" type="button" role="button" data-action="expand"><lgcom:message code="AllExpand"/></button>
				<button class="btn btn-default btn-sm" type="button" role="button" data-action="collapse"><lgcom:message code="AllCollapse"/></button>
			</div>	
        	<div class="btn-group">	
		        <button class="btn btn-gray btn-sm" type="submit" data-action="save" ><lgcom:message code="save"/></button>
		    </div>
		</div>        
   	</div>	

	<div class="organizationGrid grid-wrap">
		<div id="LGSYSC00120_grid2" class="grid" data-target="C"></div>
	</div>	    
	</section>
</div>
</body>
</html>
