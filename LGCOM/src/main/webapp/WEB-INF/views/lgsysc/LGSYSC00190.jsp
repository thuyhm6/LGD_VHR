<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSYSC00190.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2012 LG CNS,  All rights reserved.

    설 명 : 메뉴 트리를 작성하고 관리하기 위한 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Menu List2</title>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00190 = function(){
    var myForm = this;
    /*
    var layout = { 
             searchBlock : { left : 0 , top : 0 , right : 0 }, 
             treeTools : { left : 50 , top : SINGLE_LINE.top1, width : 350  },
             menuTree : { left : 0 , top : SINGLE_LINE.top2, width : 400, bottom : 0 },
             serMenuTreeToolMove : { top : 40, left : 430 , width : 50 },
             controls : { top : SINGLE_LINE.top1 , left : 410 , right : 0 },
             dataBlock : { top : SINGLE_LINE.top2, left : 410 , right : 0 }
       };    
    
    myForm.setManagedLayout( layout );
    */
    
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock",   left : 0, right : 0, top : 0 },		
		{ name  : "treeTools",     left : 0, right : 0, top : "searchBlock", width : 375, bottom : "menuTree" },		
		{ name  : "menuTree",      left : 0, right : 0, top : "treeTools", width : 375, bottom : 0 },		
		{ name  : "controls",      left : "treeTools", right : 0, top : "searchBlock", bottom : "dataBlock"},
	 	{ name  : "dataBlock",     left : "menuTree", right : 0, top : "controls", bottom : 0  }		
	]);     
    
    //우측 메뉴 정보 폼의 입력 검증을 위한 validator 정의 
    var validator = new Validator( myForm, ".menuItem", {
        rules  : {
            moduleCode : { required : true },
            menuName : { required : true },
            menuDesc : { required : true },
            programId : { required : true },
            programName : { required : true },     
            sortOrderNo : { required : true, number : true }
        },
        
        messages : {
            moduleCode : { required : "Required" },
            menuName : { required : "Required" },
            menuDesc : { required : "Required" },
            programId : { required : "Required" },
            programName : { required : "Required" },
            sortOrderNo : { required : "Required" , number : "Numbers only"}
        },
        tooltip_options : { placement : "top" }
    } );    
    

    //우측 메뉴 정보를 입력/수정하기 위한 Form 을 다루는 FormUtil
    var menuForm = new FormUtil( myForm, ".menuItem.form");
    menuForm.addValidator( validator );
    var menuNamesForm = new FormUtil( myForm, ".menuNamesForm");
    
    var menuData = new Map();
    
    var tree = new JsTree( myForm, ".menuTree", {} );
    tree.onClick( function( e, data ){
        var menu = menuData.get( data.node.id ); 
        menuForm.clear();
        menuForm.setValue( menu );
        
        menuNamesForm.setValue("menuName", menu["names"] );
        
        if( menuForm.getValue("programName") != "" ) {
        	myForm.select( "button[data-action='deleteProgram']" ).removeAttr("disabled");
        } else {
        	myForm.select( "button[data-action='deleteProgram']" ).prop("disabled", true);
        }
        
        //트리 노드 선택시, 이 트리에 자식이 있는 경우는 프로그램 정보쪽을 모두 Disable 처리한다. 
        if( tree.getChildNodes().length > 0  ) {
            if( menu["menuLevelNo"] == "3" || menu["menuLevelNo"] == "4" ) {
            	menuForm.disable("programName");
            }
        } else {
            if( menu["menuLevelNo"] == "3" || menu["menuLevelNo"] == "4" ) {
            	menuForm.enable("programName");
            } else {
            	menuForm.disable("programName");
            }
        }
    });    
    
    tree.onItemMove( function( e, data ) { 	   	
	    var menuItem = menuData.get( data.node.id );  
	    var parentItem = menuData.get( data.parent );
	    
	    if( menuItem["menuLevelNo"] > 1 && menuItem["highMenuId"] != parentItem["menuId"] ) {
	        menuItem["highMenuId"] = parentItem["menuId"];
	        menuItem["parentMenuName"] = parentItem["menuName"];
	        menuItem["status"] = "U";
	        menuForm.setValue( menuItem );
	    }
	    
	    //Reorder process
	    //1. 새로 옮겨진 parent 아래의 자식에 대해 reorder 수행한다. 
	    var targets = tree.getNode( data.parent ).children;
	    $(targets).each( function( inx ){
	    	var item = menuData.get( this );
	    	if( item["sortOrderNo"] != (inx+1) ) {
	    		item["sortOrderNo"] = inx+1;
	    		item["status"] = "U";
	    	}
	    });
	    //2. parent 를 옮긴경우에는, 예전 parent 에 대해서도 추가로 reorder 를 수행해 준다. 
	    if( data.parent != data.old_parent ) {
	        targets = tree.getNode( data.old_parent ).children;
	        $(targets).each( function( inx ){
	            var item = menuData.get( this );
	            if( item["sortOrderNo"] != (inx+1) ) {
	                item["sortOrderNo"] = inx+1;
	                item["status"] = "U";
	            }
	        });
	    }
    });
    
    tree.onDeleteNode ( function( e, data ){
        markMenuItemsAsDeleted( data.node.id );
    });
    
    tree.onSelectNode( function( e, data ){
        e.preventDefault();
    	return false;
    });
    
    function markMenuItemsAsDeleted( id ){
    	//자기 자신을 D 로 만들고
        var menuItem = menuData.get( id );
        menuItem["status"] = "D";
        
        $( menuData.values() ).each( function(){
        	if( this["highMenuId"] == id ) {
        		markMenuItemsAsDeleted( this["menuId"] );
        	}
        });
    }    
    
    var openNodes = [];
    
    function getMenuData(){
    	myForm.showProgress();
  	    myForm.transaction( "lgcom", "lgsysc/LGSYSC00190/retrieveMenuList", searchForm.getValue() , function(data){
  	    	myForm.hideProgress();
  	    	menuData.clear();
            var list = data["result"];    
            var treeData = [];
            
            var firstMenuId;
            $(list).each( function( inx ){
            	
            	if( inx == 0 ) {
            		firstMenuId = this["menuId"];
            	}
            	
            	//각 레코드의 데이터 보정 및 정리  
            	if( nvl( this["highMenuId"] ) == "" ) {
            		this["highMenuId"] = "#"; //jsTree 는 root메뉴의 parent 가 # 이어야 한다. 
            	} else {
            		var parent = menuData.get( this["highMenuId"] ); 
            		this["parentMenuName"] = parent["menuName"];
            	}
            	
            	this["status"] = "N";
            	
            	//열려있는 상태를 보관하는 Array 에서 이  menuId 를 확인하여  state 를 할당한다. 
            	var opened = false;
            	if( openNodes.indexOf( this["menuId"] ) > -1  ) {
            		opened = true;
            	}
            	
            	treeData.push({
            		id : this["menuId"],
            		parent : this["highMenuId"],
            		text : this["menuName"],
            		state : {
            			opened : opened
            		}
            	});
            	
            	this["names"]  = JSON.parse( this["menuMName"] );
            	
            	menuData.put( this["menuId"], this );
            });
            
            tree.setData( treeData , function(){
            	setTimeout( function(){
			        selectTreeNode(firstMenuId);        		
                }, 500);
            });
            
            //조회를 한번이라도 수행해야만 버튼이 활성화 된다. 
            myForm.select(".menuTreeEdit").removeAttr("disabled");
            
            //조회 조건에서 정한 systemCode 를 입력 폼에 지정한다. 
            menuForm.setValue( "systemCode", searchForm.getValue("systemCode") );
  	    });
    }
    
    //공통코드 정보를 인출
    var code = new CommonCode("lgcom");
    code.add(  "LGCOM_SYSTEM_CODE" , { codeTypeCode : "LGCOM_SYSTEM_CODE" } );
    code.add(  "LGCOM_MODULE_CODE" , { codeTypeCode : "LGCOM_MODULE_CODE" } );
    code.add(  "LGCOM_YN_FLAG"     , { codeTypeCode : "LGCOM_YN_FLAG" } );
    code.add(  "LGCOM_LANGUAGE_CODE"     , { codeTypeCode : "LGCOM_LANGUAGE_CODE" } ); 
    code.execute();
    
    
    //입력부분의 언어 입력을 위한 테이블 구성
    var list = code.get("LGCOM_LANGUAGE_CODE");
    var menuNameForLanguagesBody =  myForm.select(".menuNameForLanguages");
    menuNameForLanguagesBody.empty();
    trace("LGCOM_LANGUAGE_CODE");
    trace(list);
    trace("LGCOM_LANGUAGE_CODE");
    $(list).each( function(){
    	var tr = "<tr>" + 
    	         "<th scope='row'><label for='textarea01'>"+ this["name"] +"</label></th>" + 
    	         "<td><input name='code' type='hidden' value='"+ this["code"] +"' /><input type='text' name='menuName' class='form-control input-sm' data-code='"+ this["code"] +"' /></td>" +
			     "</tr>";
			     
    	menuNameForLanguagesBody.append( tr );
    });
    
    
    //조회블럭의 정보를 입력하기 위한 Form 을 다루는 FormUtil
    var searchForm = new FormUtil( myForm, ".searchBlock .form" );
    searchForm.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE")  );

    menuForm.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE")  );
    menuForm.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE") , {selectEmpty : true, filter : "systemCode"} );
    menuForm.initCombo( "displayFlag", code.get("LGCOM_YN_FLAG") );
    menuForm.initCombo( "useFlag", code.get("LGCOM_YN_FLAG") );
    menuForm.initCombo( "popUpScreenFlag", code.get("LGCOM_YN_FLAG") );
    
    menuForm.addChangeEvent( function( currentData, originalData, isChanged  ){
        var menuInfo = menuData.get( currentData["menuId"] );    	
    	
    	//폼에서 변경직후에 모은 폼의 데이터의 menuId 를 받아서, 이것으로 메뉴트리의 아이템을 호출한다.
        if( menuInfo["status"] != "C" ) {
            if( isChanged ) {
                currentData["status"] = "U";
            } else {
                currentData["status"] = "N	";
            }
        } else {
            currentData["status"] = menuInfo["status"];
        }    	
    	
        currentData["names"] = menuInfo["names"];
    	
    	menuData.put( currentData["menuId"], currentData );
    	tree.changeCurrentNodeName( currentData.menuName );
    });    
    
    menuNamesForm.addChangeEvent(function( currentData, originalData, isChanged  ){
        var menuInfo = menuData.get( menuForm.getValue("menuId") ); 
        
        if( menuInfo["status"] != "C" ) {
            if( isChanged ) {
            	menuInfo["status"] = "U";
            } else {
            	menuInfo["status"] = "N";
            }
        }
        
        var names = {};
        trace( currentData["code"] );
        
        $(currentData["code"]).each( function( inx ){
            names[ currentData["code"][inx] ] = currentData["menuName"][inx];
        });

        trace( menuInfo );
        menuInfo["names"] = names;
    });
    
    
    function saveTreeData() {
        //현재 열려있는 노드들의 ID를 모아둔다.    	
    	openNodes = tree.getOpenNodes();
        var data = getChangedList();

        //getChangedList 에서 데이터 검증을 수행한 결과, 문제가 있다고 판단했을 경우로, 이 경우 더 진행하지 않는다. 
        //관련 메세지는 getChangedList 에서 이미 띄웠으므로, 여기선 멈추기만 한다.
        if( data == null ) {
        	return;
        }

        if( data.changeCount  == 0 ) {
            Message.alert('<lgcom:message code="error.noChangedData"/>');
        	return;
        }

        Message.confirm("<lgcom:message code="question.save" />", function(){
            myForm.transaction( "lgcom", "lgsysc/LGSYSC00190/updateMenuList", data, function(){
            	getMenuData();
                validator.resetForm();
                Message.notify('<lgcom:message code="note.completed" />');
            });
        });
    }    
    
    function selectTreeNode( id ) {
	    tree.selectNode( id );
	    var menu = menuData.get( id ); 
	    menuForm.clear();
	    menuForm.setValue( menu );  
	    
	    menuNamesForm.clear();
	    
	    myForm.select(".menuNamesForm [data-code]").each( function(){
	    	$(this).prev().val(  $(this).data("code") );
	    });
	    
	    menuNamesForm.setValue( "menuName", menu["names"] ); 
    }
    
    
    function getChangedList() {
        var result = { updated : [], created :[] , deleted : [] , changeCount : 0 };

        $( menuData.values() ).each( function(){
            var menuInfo = this;
            
            //필수필드에 대한 체크를 수행한다. 
            if( menuInfo["menuLevelNo"] == "4"  ) {
                if( menuInfo["menuName"] == "" || menuInfo["moduleCode"] == ""  || menuInfo["menuDesc"] == "" || menuInfo["programId"] == "" || menuInfo["programName"] == "" ) {
                    selectTreeNode( menuInfo["menuId"] );
                    validator.isValid();
                    result = null;
                    return false; // Break 와 같은 효과 
                }
            } else {
                if( menuInfo["menuName"] == "" || menuInfo["menuDesc"] == "" || menuInfo["moduleCode"] == "" ) {
                    selectTreeNode( menuInfo["menuId"] );
                    validator.isValid();
                    result = null;             
                    return false; // Break 와 같은 효과 
                }                   
            }            

            if( menuInfo.status == "C" ) {
                result.created.push( menuInfo );    
                result.changeCount++;
            } else if( menuInfo.status == "U" ) {
                result.updated.push( menuInfo );
                result.changeCount++;
            } else if( menuInfo.status == "D" ) {
                result.deleted.push( menuInfo );
                result.changeCount++;
            } 
        });
        
        return result;
    }    
    
    var searchCondition;
    
    
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "change", ".searchBlock [name='systemCode']" , function(event){
		if( searchCondition == undefined ) { 
			myForm.select(".menuTreeEdit").prop("disabled", true);
			return;
		}
		
		if( searchCondition["systemCode"] == searchForm.getValue("systemCode") ) {
			myForm.select(".menuTreeEdit").removeAttr("disabled");
		} else {
			myForm.select(".menuTreeEdit").prop("disabled", true);
		}
	});
	
	myForm.addEvent( "click", "button[data-action]" , function(event){
        var item = event.target;
        
        if( !$(item).filter("[data-action]").exists() ) {
        	item = $(item).parent();
        }
        
		var action = $(item).data("action");
		var programPopup = myForm.popupInfo.programPopup;
		
		switch( action ){
		    case "search" :
		    	validator.resetForm();
		    	searchCondition = searchForm.getValue();
		    	getMenuData();
				break;
		    case "deleteProgram" :
		    	var menuInfo = menuData.get( menuForm.getValue("menuId")  )
		    	if( nvl(menuInfo["programId"]) != "" ) {
		    		menuInfo["status"] = "U";
		    	}
		    	menuInfo["programId"] = "";
		    	menuInfo["programName"] = "";
		    	menuForm.setValue( { programId : "",  programName : ""} );
		    	
		    	break;
		    case "openPopup" :
		    	programPopup["programName"] = menuForm.getValue("programName");
		    	programPopup["systemCode"]  = searchForm.getValue("systemCode");

		    	var popup = new Popup( myForm, "lgcom", "M_LGSYSC_1135", "<lgcom:message code="ProgramSearch"/>" );
		    	popup.setSize( 600, 500 );
		    	popup.addParam("a", "b");
		    	popup.addParam("c", "d");
		    	popup.open( function(){
		    		var menuInfo = menuData.get( menuForm.getValue("menuId")  );
		    		
		    		if( menuInfo["status"] != "C" && ( menuInfo["programId"] != programPopup["programId"] ) ) {
		    			menuInfo["status"] = "U";
		    		}
		    		
		    		menuForm.setValue( "programId", programPopup["programId"] );
                    menuForm.setValue( "programName",programPopup["programName"] ).focus();
                    
                    menuInfo["programId"] =  programPopup["programId"];
		    	    menuInfo["programName"] = programPopup["programName"];
		    	});
		    	break;
		    case "save" :
         		saveTreeData();	
		    	break;
            case "expandAll" :
                tree.expandAll();
                break;	
            case "expandHalf" :
                tree.expandHalf();
                break;                
            case "collapseAll" :
                tree.collapseAll();
                break;
            case "addRoot" :
            	
                var item = { status : "C", 
                             systemCode : searchForm.getValue("systemCode"), 
                             moduleCode : "",   
                             menuId : uuid(), 
                             menuName : "(New Menu)", 
                             menuLevelNo : 1, 
                             parentMenuName : "",   
                             highMenuId : "#", 
                             displayFlag : "Y" , 
                             useFlag : "Y" , 
                             popUpScreenFlag : "N", 
                             sortOrder : 0, 
                             programId : "", 
                             programName : "", 
                             menuDesc : "" };
            	
            	var names = {};
                $( code.get("LGCOM_LANGUAGE_CODE") ).each( function(){
                	names[ this["code"] ] = item["menuName"];
                });
                
                item["names"] = names;
                
                tree.addRootNode( { id : item["menuId"], text : item["menuName"] , type : "root" } , function( node, position ){
                    item["sortOrderNo"] = position;                   	
                    menuData.put( item["menuId"], item );
                    Message.notify("New menu item created.");
                });            	
                
                selectTreeNode( item["menuId"] );
                
                break;	
            case "addChild" :
            	if( tree.getSelectedNode().length == 0 ) {
                    Message.alert("Please select level1 or level2 menu.");            		
            		return;
            	}
       	
            	var selected = tree.getSelectedNode()[0];
            	var menuInfo = menuData.get( selected ); 
            	
            	if( menuInfo["status"] == "C" ) {
            		Message.alert("<lgcom:message code="note.saveNewMenuFirst"/>");
            		return;
            	}

            	if( menuInfo["menuLevelNo"] == "4" ) {
            		Message.alert("<lgcom:message code="note.lastMenuAlert"/>");
            		return;
            	} 
            	
            	if( nvl( menuInfo["programId"] ) != "" ) {
            		Message.alert("<lgcom:message code="note.programExistsAlert"/>"); 
            		return;
            	} 
            	
            	var item = { status : "C", 
                             systemCode : menuInfo["systemCode"], 
                             moduleCode : menuInfo["moduleCode"],             			
	                         menuId : uuid(), 
	                         menuName : "(New Menu)", 
	                         menuLevelNo : Number( menuInfo["menuLevelNo"]  ) + 1, 
	                         parentMenuName : menuInfo["menuName"],   //자기 menuName 이 새로 생기는 아이템의 parentMenuName 이다.
	                         highMenuId : menuInfo["menuId"],
	                         displayFlag : "Y" ,
	                         useFlag : "Y" , 
	                         popUpScreenFlag : "N", 
	                         sortOrder : 0, 
	                         programId : "", 
	                         programName : "", 
	                         menuDesc : "" };
            	
            	var names = {};
                $( code.get("LGCOM_LANGUAGE_CODE") ).each( function(){
                	names[ this["code"] ] = item["menuName"];
                });
                
                item["names"] = names;

            	//기본 type 은 branch, 
            	var type = "branch";
            	if( item["menuLevelNo"] == "3" ) {
            		type = "leaf";   
            	}
            	
        		menuData.put( item["menuId"], item );
            	
            	tree.addChildNode( { id : item["menuId"], text : item["menuName"] , type : type  } , function( node , position ){
                    item["sortOrderNo"] = position;         		
            		Message.notify("New menu item created.");
            	});
            	
            	selectTreeNode( item["menuId"] );
            	
                if( item["menuLevelNo"] == "3" || item["menuLevelNo"] == "4" ) {
                	menuForm.enable("programName");   
                } else {
                	menuForm.disable("programName");
                }            	
            	
            	break;
            case "delete" :
            	var node = tree.getSelectedNode();
                tree.deleteNode( node );
            	break;
		}
		
		//event.stopPropagation();
	});   
	
	myForm.addEvent( "change", ".dataBlock .form input[name=programName]" , function(event){
		var programPopup = myForm.popupInfo.programPopup;
		
    	programPopup["programName"] = menuForm.getValue("programName");
    	programPopup["systemCode"]  = searchForm.getValue("systemCode");

    	var popup = new Popup( myForm, "lgcom", "M_LGSYSC_1135", "<lgcom:message code="ProgramSearch"/>" );
    	popup.setSize( 500, 500 );
    	popup.open( function(){
    		var menuInfo = menuTree.getMenuInfo( menuForm.getValue("menuId")  );
    		
    		if( menuInfo["status"] != "C" && ( menuInfo["programId"] != programPopup["programId"] ) ) {
    			menuInfo["status"] = "U";
    		}
    		
    		menuForm.setValue( "programId", programPopup["programId"] );
            menuForm.setValue( "programName",programPopup["programName"] ).focus();
            
            menuInfo["programId"] =  programPopup["programId"];
    	    menuInfo["programName"] = programPopup["programName"];
            
            menuTree.refresh();
    	}, 
    	function(){
    		
    	});
	});	

	myForm.popupInfo = { programPopup : {} };
}


LGSYSC00190.prototype = new BizForm("${param.bizFormId}");
</script>
<style>

</style>
</head>   

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
	    <h2>Menu List</h2>
	</div>

	<div class="searchBlock">
		<form class="form search-wrap" noenter >
		        <table class="table" >
		            <colgroup>
		                <col width="90">
		                <col width="90">
		                <col width="120">
		                <col width="280">
		            </colgroup>
		            <tbody> 
		                <tr>
		                    <th><label class="required"><lgcom:message code="System" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="systemCode"  ></select>
		                    </td>
		                    
		                    <th><label><lgcom:message code="MenuName" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="menuName"></td>

		                </tr>		                		                		                
		            </tbody>
		        </table>
		    <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
	    </form>
	</div> 
	
    <div class="treeTools gridControls module-group text-right">
    	<div class="btn-toolbar">	
			<div class="btn-group">
				<button type="button" class="btn btn-default btn-sm ico-lgd" aria-label="추가" data-action ="expandAll"  >
				    <span class="fa fa-plus" aria-hidden="true"></span>
				</button>
				<button type="button" class="btn btn-default btn-sm ico-lgd" aria-label="추가" data-action ="expandHalf" >
				    <span class="fa fa-bars" aria-hidden="true"></span>
				</button>	
				<button type="button" class="btn btn-default btn-sm ico-lgd" aria-label="추가" data-action ="collapseAll" >
				    <span class="fa fa-minus" aria-hidden="true"></span>
				</button>	
			</div>
			<div class="btn-group">			
				<button class="btn btn-default btn-sm menuTreeEdit ico-lgd" type="button" role="button" data-action="addRoot" disabled ><span class="fa fa-plus" aria-hidden="true"></span><lgcom:message code="AddRoot" /></button>
				<button class="btn btn-default btn-sm menuTreeEdit ico-lgd" type="button" role="button" data-action="addChild" disabled ><span class="fa fa-plus" aria-hidden="true"></span><lgcom:message code="AddChild" /></button>
				<button class="btn btn-default btn-sm menuTreeEdit ico-lgd" type="button" role="button" data-action="delete" disabled ><span class="fa fa-remove" aria-hidden="true"></span><lgcom:message code="Delete" /></button>
			</div>
		</div>		
	</div>
    
	<div id="_menuTree" class="menuTree noselect panel panel-default " style="overflow-y:auto;">
	</div>
	
    <div class="controls module-group text-right" >
    	<div class="btn-toolbar">	
			<div class="btn-group">
		        <button class="btn btn-darkgray btn-sm" type="submit" data-action="save" ><lgcom:message code="save" /></button>
		    </div>
		</div>        
   </div>	
	
   <div class="dataBlock">   
	    <form class="menuItem form" >
 	        <input type="hidden" name="highMenuId" />
 	        <input type="hidden" name="status" />
 	        
			<table class="table table-condensed" summary="입력 테이블">
				<caption class="sr-only-lgd">입력 테이블</caption>
				<colgroup>
					<col width="150">
					<col width="170">
					<col width="150">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<th scope="row"><label class="required"><lgcom:message code="System" /></label></th>
						<td><select class="form-control input-sm" name="systemCode"  ></select></td>
						
						<th scope="row"><label><lgcom:message code="Module" /></label></th>
						<td><select class="form-control input-sm" name="moduleCode"></select></td>
					</tr>
					
					<tr>
						<th scope="row"><label><lgcom:message code="ParentMenuName" /></label></th>
						<td><input type="text" name="parentMenuName" class="form-control input-sm" disabled /></td>
						
						<th scope="row"><label for="textarea01"><lgcom:message code="MenuId" /></label></th>
						<td><input type="text" name="menuId" class="form-control input-sm"  disabled/></td>
					</tr>

					<tr>
						<th scope="row"><label for="textarea01"><lgcom:message code="MenuName" /></label></th>
						<td><input type="text" name="menuName" class="form-control input-sm"  /></td>					
					
						<th scope="row"><label><lgcom:message code="MenuDescription" /></label></th>
						<td scope="row"><input type="text" name="menuDesc" class="form-control input-sm"  /></td>
					</tr>					
					
					<tr>
						<th scope="row"><label><lgcom:message code="Parameter" /></label></th>
						<td colspan="3"><input type="text" name="menuUrlAddr" class="form-control input-sm"  placeholder="<lgcom:message code="placeholder.additionalParameter" />" /></td>
					</tr>				
					
					<tr>
						<th scope="row"><label><lgcom:message code="ProgramName" /></label></th>
						<td ><input type="text" name="programId" class="form-control input-sm" disabled /></td>
                        <td colspan="2">
	                        <div class="input-group input-group-sm input-search size_220" style="float:left;">
	                            <input type="text" class="form-control " name="programName" />
	                            <span class="input-group-btn">
	                                <button class="btn btn-default ico-lgd find" type="button" data-action="openPopup"  >
	                                    <span class="fa fa-search" aria-hidden="true"></span>
	                                </button>
	                            </span> 
	                        </div>	 
						    <button type="button" class="btn btn-default btn-sm ico-lgd" style="margin-top:1px;margin-left: 5px;" data-action="deleteProgram"  disabled ><span class="fa fa-times"></span></button>
						</td>
					</tr>
						
					<tr>
						<th scope="row"><label><lgcom:message code="MenuLevel" /></label></th>
						<td><input type="text" name="menuLevelNo" class="form-control input-sm" disabled /></td>
						
						<th scope="row"><label for="textarea01"><lgcom:message code="SortOrder" /></label></th>
						<td><input type="text" name="sortOrderNo" class="form-control input-sm"  /></td>
					</tr>
					
					<tr>
						<th scope="row"><label><lgcom:message code="DisplayFlag" /></label></th>
						<td><select name="displayFlag" class="form-control input-sm" data-type="yes_no"></select></td>
						
						<th scope="row"><label><lgcom:message code="UseFlag" /></label></th>
						<td><select name="useFlag" class="form-control input-sm" data-type="yes_no"></select></td>
					</tr>											
										
					<tr>
						<th scope="row"><label><lgcom:message code="PopupFlag" /></label></th>
						<td><select name="popUpScreenFlag" class="form-control input-sm" data-type="yes_no"></select></td>
						
						<td></td>
						<td></td>
					</tr>											
				</tbody>
			</table> 	        
	    </form>
	    
	    <div class="sub-header"><h4><lgcom:message code="menuNameForLanguage" /></h4></div>
	    
	    <form class="menuNamesForm form" >
 	        <input type="hidden" name="highMenuId" />
 	        <input type="hidden" name="status" />
 	        
			<table class="table table-condensed" summary="입력 테이블">
				<caption class="sr-only-lgd">입력 테이블</caption>
				<colgroup>
					<col width="150">
					<col width="*">
				</colgroup>
				<tbody class="menuNameForLanguages">  
				</tbody>
			</table> 	        
	    </form>   
   </div>
   </section>            
</div>	
<script>
$(document).ready( function() {
	launch( function(){
		var form = new LGSYSC00190();
		form.init();
	});
	
});

</script>
</body>
</html>
