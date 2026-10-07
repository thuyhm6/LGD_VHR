<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSYSC00180.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본화면은 메뉴 트리를 작성하고 관리하기 위한 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Menu List</title>
<style type="text/css">

</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">

DataSet = function(){
	var data = new RealGridJS.LocalTreeDataProvider();
	
	
	/* 이벤트 핸들러 설정 */
	this.onLoadCompleted = function( callback ){
		data.onLoadCompleted = function( provider ){
			try{
				callback.call( this, provider )
			}catch(e){ }
		}
	}
	
	this.getRowCount = function() {
		return data.getRowCount();
	}
	
	this.getRowData = function( row ) {
		return data.getJsonRow( row );
	}
	
	this.getValue = function( row, filed ) {
	    var row = data.getJsonRow( row );
	    
	    if( row == undefined ) {
	    	
	    } 
	    
	}

}

MenuTree = function( myForm, selector, menuForm , searchForm ){
	var _this = this;
    var menuTree = myForm.select(selector);
    var selected;
    var treeTools = myForm.select(".treeTools");
    var menuInfoMap = new Map();
    var deletedMenuInfo = new Array();
    
    this.getMenuInfo = function( menuId ){
    	return menuInfoMap.get( menuId );
    }
    
    this.setMenuInfo = function( menuInfo ){
    	menuInfoMap.put( menuInfo["menuId"], menuInfo );
    }    
 
	function select( item ) {
		//해당 아이템을 선택한것으로 표시한다. 
		menuTree.find(".selected").removeClass("selected");
		item.children("._name").addClass("selected");

		var menuInfo = menuInfoMap.get( $(item).data("id") );

		menuForm.setValue( menuInfo )

		if( menuInfo["menuLevelNo"] != "3" ) {
			menuForm.disable("programName");
			menuForm.disable("urlAddr");
			myForm.select(".treeTools button[data-action='addChild']").prop( "disabled", false );
		} else {
			menuForm.enable("programName");
			menuForm.enable("urlAddr");
			myForm.select(".treeTools button[data-action='addChild']").prop( "disabled", true );
		}
		
		if( menuInfo["menuLevelNo"] == "1" ) {
			menuForm.enable("moduleCode");
		} else {
			menuForm.disable("moduleCode");
		}		
        selected = item;
	}
	
	function _node( item ) {
		var node = $('<li class="_item" data-level="'+item["menuLevelNo"]+'" data-id="'+item["menuId"]+'"><i class="_folder rotate0 fa fa-caret-down"></i><div class="_name">'+ item["menuName"] +'</div><span class="_exisingLabel label label-lgd">Added</span><ul class="_itemList" data-level="'+item["menuLevelNo"]+'" data-id="'+item["menuId"]+'"></ul></li>');
		
		if( item["menuLevelNo"] == "3" ) {
			node.find("._folder").remove();   
		}
		
		return node;
	}
	
	this.loadData = function( quite ){
		loadMenuTree( quite );
	}
    
    function loadMenuTree( quite ) {
    	if( !quite ) {
    		myForm.showProgress(".tree");	
    	} 
    	
    	
    	transaction( "lgcom", "lgsysc/LGSYSC00180/retrieveMenuList", searchForm.getValue() , function(data){
    		if( !quite ) {
    		    myForm.hideProgress();
    		}
    		
    		var list = data["result"];
    		
    		if( list== undefined || list.length == 0 ) {
    			myForm.select(".tree").empty().append('<div class="_nodata"><i class="fa fa-info-circle" aria-hidden="true"></i><div><lgcom:message code="note.nodata"/></div></div>');
    			return;
    		}
    		
    		//삭제 대상 목록을 모두 비운다. 
    		deletedMenuInfo.length = 0;
    		menuInfoMap.clear();
    		
    		var root  = $('<div class="_tree" ><ul class="_itemList" data-level="root"></ul></div>');
    		myForm.select(".tree").empty().append( root );
    		
			$(list).each( function(inx){
    			var item = this;
    			//이 모든 항목은 이미 DB에서 온 것이기 때문에, status 를  N ( normal ) 로 지정해준다. 
    			item.status = "N";
    			
    			//각 항목에 대해 null 이 있으면, "" 로 치환하는 로직을 수행한다.
    			$(item).cleanJSON();
    			
        		//이 메뉴의 부모 메뉴를 불러서, 그 정보를 일부 사용한다. 
        		var parentMenuInfo = menuInfoMap.get( item["highMenuId"] );
        		if( parentMenuInfo != undefined && parentMenuInfo["menuName"] != undefined ) {
        			item["parentMenuName"] = parentMenuInfo["menuName"];	
        		} else {
        			item["parentMenuName"] = "";        		
        		}
        		
        		//menuInfo 에  menuId 별로 적재한다. 
        		menuInfoMap.put( item["menuId"], item );        		
        		
    			if( item["menuLevelNo"] == "1" ) {
    				var node = _node(item);
    				menuTree.find("._itemList[data-level='root']").append( node );
    			} else  if( item["menuLevelNo"] == "2" ||  item["menuLevelNo"] == "3" ) {
    				var node = _node(item);
    				menuTree.find("._itemList[data-id='"+item["highMenuId"]+"']").append( node );
    			}   
    		}); 

    	    myForm.select("._itemList").droppable()
							    	   .sortable({
							    	       revert: true,
							    	       delay: 300,
							    	       placeholder : "_treeItemPlaceHolder",
							    	       connectWith: "._itemList",
							    	       stop : function( event, ui ){  // sorting 이 끝났을때 발동한다. ( 모든 경우에 대하여 ) 
										       if( menuInfoMap.get( ui.item.data("id") )["status"] == "C") {
										    	   $(ui.sender).sortable('cancel');
										           return false;
										       }								    	    	   
										       //아이템 떨구기가 끝나면, 해당 아이템과 주변의 순서를 reorder 해준다.							    	    	   
							    	    	   _reorderMenuItems();
							    	    	   _this.refresh();
							    	    	   select( $(ui.item) );
							    	       },
							    	       receive : function(event, ui){  // 이 콜백은 서로 다른 리스트의 아이를 받았을때에 발동된다.
							    	    	   
										       if( menuInfoMap.get( ui.item.data("id") )["status"] == "C") {
										    	   $(ui.sender).sortable('cancel');
										           return false;
										       }								    	    	   
							    	    	   
							    	    	   if( !isValidDrop( ui.sender, $(this) ) ) {
							    	    		   $(ui.sender).sortable('cancel');
							    	    		   return;
							    	    	   }
							    	    	   
							    	    	   //아이템 떨구기가 끝나면, 해당 아이템과 주변의 순서를 reorder 해준다.
							    	    	   _reorderMenuItems();
							    	    	   _this.refresh();
							    	       },
							    	       start: function(e, ui){
							    	           ui.placeholder.height(ui.item.height());
							    	       }
							    	   });
    	    
    	    select( $(root).find("._item").first() );
    	});
    }
    
    this.reorderMenuItems = function() {
    	_reorderMenuItems();
    }
    
    function _reorderMenuItems( root , highMenuId, parentMenuName ) {
    	if( root == undefined ) {
    		root = myForm.select("[data-level='root']._itemList");
    	}
    	
    	if( highMenuId == undefined ) {
    		highMenuId = "";
    		parentMenuName = "";
    	}
    	
    	var children = $(root).children("._item ");
    	
    	var sortOrderNo = 0;
    	$(children).each( function(){
    		var menuInfo = menuInfoMap.get( $(this).data("id") );
    		
    		if( menuInfo.status != "D" ) {
        		sortOrderNo++;
        		
        		//메뉴 순서가 바뀌면, 이 항목은 수정 항목으로 기재함 
        		if( menuInfo.sortOrderNo != sortOrderNo ) {
        			//신규아이템은 바뀌어도 수정이라 적지 않는다.
        			if( menuInfo.status != "C" ) {
        				menuInfo.status = "U";	
        			}
        			
        			menuInfo.sortOrderNo = sortOrderNo;
        		}
        		
        		//상위메뉴가 바뀌면, 이 항목은 수정항목으로 기재함
        		if( menuInfo.menuLevelNo != "1" && menuInfo.highMenuId != highMenuId ) {
        			
        			//신규아이템은 바뀌어도 수정이라 적지 않는다.
        			if( menuInfo.status != "C" ) {
        				menuInfo.status = "U";	
        			}
        			
        			menuInfo.highMenuId = highMenuId; // 위에서 들어온 상위 메뉴 아이디는 자기에게 담는다
        		}        		
        		
        		menuInfo.parentMenuName = parentMenuName; // 위에서 들어온 상위 메뉴 아이디는 자기에게 담는다.
        		
        		if( $(this).children("._itemList ").exists() ) {
        			_reorderMenuItems( $(this).children("._itemList "), menuInfo.menuId , menuInfo.menuName ); //자기의 메뉴아이디를 하위로 내려보낸다
        		}
    		}
    	});
    	
    }
    
   	// 이 함수는 메뉴 아이템( item ) 가 드롭될 때, 드롭되는 곳 ( holder )과의 상호 비교를 통하여, 유효한 장소인지 확인을 하기 위한 함수이다. 
   	function isValidDrop( sorceList, targetList ) {
   	    var valid = true;
   	    var sorceListLevel   = $(sorceList).data("level");
   	    var targetListLevel = $(targetList).data("level");
   	    if( sorceListLevel != targetListLevel ) {
   	    	valid = false;
   	    }
   	    return valid;
   	}    
   	
   	
   	this.getChangedList = function() {
   		var result = { updated : [], created :[] , deleted : deletedMenuInfo };

   		$( menuInfoMap.values() ).each( function(){
   			var menuInfo = this;
   			
   			//필수필드에 대한 체크를 수행한다. 
   			if( menuInfo["menuLevelNo"] == "3"  ) {
   				if( menuInfo["menuName"] == "" || menuInfo["menuDesc"] == "" || menuInfo["programId"] == "" || menuInfo["programName"] == "" ) {
   	  				select( menuTree.find("._item[data-id='"+ menuInfo["menuId"] +"']") );
   	  			    myForm.validator.isValid();
   	  			    result = null;
   	   				return false; // Break 와 같은 효과 
   	   			}
   			} else {
   				if( menuInfo["menuName"] == "" || menuInfo["menuDesc"] == "" ) {
   	  				select( menuTree.find("._item[data-id='"+ menuInfo["menuId"] +"']") );
   	  			    myForm.validator.isValid();
   	  			    result = null;   	  			    
   	   				return false; // Break 와 같은 효과 
   	   			}   				
   			}

   			if( menuInfo.status == "C" ) {
				result.created.push( menuInfo );	
			} else if( menuInfo.status == "U" ) {
				result.updated.push( menuInfo );	
			} 
   		});
   		
   		return result;
   	}
    
   	this.refresh = function() {
   		$( menuInfoMap.values() ).each( function(){
            var item = $(this)[0];
   			var labelItem = menuTree.find("._item[data-level='"+ item["menuLevelNo"] +"'][data-id='"+ item["menuId"] +"'] > ._exisingLabel");
   			var nameItem = menuTree.find("._item[data-level='"+ item["menuLevelNo"] +"'][data-id='"+ item["menuId"] +"'] > ._name");

   			if( item["status"] == "C" ) {
   				$(labelItem).show().text( "Created" );
   			} else if( item["status"] == "U" ) {
   				$(labelItem).show().text( "Updated" );
   			} else {
   				$(labelItem).hide();
   			}
   			
   			$(nameItem).text( item["menuName"]);  
   		});
   	}
   	
   	
    myForm.addEvent( "click", ".tree li ._folder", function( event ){
    	var item = $(event.target);

    	//바로 하위항목이 없을때는, 이 버튼이 동작할 필요가 없다.
    	if( $(item).parent().children("._itemList").children("._item").length == 0 ) {
    		return;
    	}
    	
    	if( $(item).data("closed") == undefined || $(item).data("closed") == "N" ) {
    		$(item).parent().children("._itemList").slideUp( 500 , function(){
    			$(item).data("closed","Y");
    		});
    		$(item).addClass("rotate-90");
    	} else {
    		$(item).parents("._item").children("._itemList").slideDown( 500 , function(){
    			$(item).data("closed","N");
    		});
    		$(item).removeClass("rotate-90");
    	}
		
		event.stopPropagation();
	});	
    
	myForm.addEvent( "click", ".tree li ._name", function( event ){
		if( !myForm.validator.isValid() ) {
			return;
		}
		var item = $(event.target);
		select( item.parent() );

		event.stopPropagation();
	});	
	
	
	myForm.addEvent( "click", ".treeTools .btn, .treeTools .btn i", function( event ){
		var item = $(event.target);
		
		if( !item.hasClass("btn") ) {
			item = $(item).parent();
		}
		
		var action = $(item).data("action");
		
		if( action == "add" ) { 
			
            if( !myForm.validator.isValid() ) {
            	return;
            } else {
            	myForm.validator.resetForm();
            }	
			
			//동일레벨에 메뉴 아이템을 추가하는 경우 
			var menuInfo = menuInfoMap.get( $(selected).data("id") );

			var item = { status : "C", 
					     systemCode : menuInfo["systemCode"], 
					     moduleCode : menuInfo["moduleCode"],  
					     menuId : uuid(), 
					     menuName : "", 
					     menuLevelNo : menuInfo["menuLevelNo"], 
					     parentMenuName : menuInfo["parentMenuName"], 
					     highMenuId : menuInfo["highMenuId"], 
					     useFlag : "Y" , 
					     popupFlag : "Y", 
					     sortOrder : 0, 
					     programId : "", 
					     programName : "", 
					     menuDesc : "" };
			
			//신규로 생성된 아이템이므로, menuInfoMap 에 추가해준다. 
			menuInfoMap.put( item.menuId, item );
			//tree에 아이템으로 추가한다.
		    var node = _node( item ); 
    		$( node ).insertAfter( selected );
    		
    		//새로운 노드가 추가됐으므로, reorder 한다.
    		_reorderMenuItems();
    		
    		select( node );
			
		} else if( action == "addChild" ) {
			
            if( !myForm.validator.isValid() ) {
            	return;
            } else {
            	myForm.validator.resetForm();
            }			
			
			var menuInfo = menuInfoMap.get( $(selected).data("id") );

			var item = { status : "C", 
					     systemCode : menuInfo["systemCode"], 
					     moduleCode : menuInfo["moduleCode"],  
					     menuId : uuid(), 
					     menuName : "", 
					     menuLevelNo : Number( menuInfo["menuLevelNo"]  ) + 1, 
					     parentMenuName : menuInfo["menuName"],   //자기 menuName 이 새로 생기는 아이템의 parentMenuName 이다.
					     highMenuId : menuInfo["menuId"], 
					     useFlag : "Y" , 
					     popupFlag : "Y", 
					     sortOrder : 0, 
					     programId : "", 
					     programName : "", 
					     menuDesc : "" };
			
			//신규로 생성된 아이템이므로, menuInfoMap 에 추가해준다. 
			menuInfoMap.put( item.menuId, item );
			//tree에 아이템으로 추가한다.  : 자신의 itemList에 추가한다.
		    var node = _node( item ); 
			$(selected).children("._itemList").append( node );
			
    		//새로운 노드가 추가됐으므로, reorder 한다.
    		_reorderMenuItems();			
			
    		select( node );
			
		} else if ( action == "delete" ) {
			//현재 선택된 동일레벨에 자신 혼자만 있는경우에는 selected 는 자신이 아니라 부모항목으로 바뀌어 로직이 작동한다.
  			if( $(selected).siblings().length == 0 ){
  			    selected = $(selected).parent().parent();
  			}
			
			//현재 선택된 항목은 삭제될 대상이므로, 그 근처의 가장 가까운 동일 아이템을 골라야 한다.
			var nextItem = findNearest( selected, "._item");
				
			//현재 선택된 메뉴와 그 아래의 모든 아이템을 지우는 로직이다. ( find 메소드임에 주의할 것 ) 
			var items = $(selected).find("._item");
			items.push(selected);
			$( items ).each( function( inx ){
				var menuInfo = menuInfoMap.get( $(this).data("id") );
				
				//선택된 항목을 지울 때, status 가 C 인 항목은 그냥 화면에 들어왔다 지워지는 항목이므로, deletedMenuInfo 에 추가하지 않는다.
				if( menuInfo["status"] != "C" ) {
					deletedMenuInfo.push( menuInfo );
				} else {
					menuInfoMap.remove( menuInfo["menuId"] );
				}
				
				$(this).remove();
			});

			_reorderMenuItems();
			
			select( nextItem );
			
		} else if ( action == "expandAll" ) {
			menuTree.find("._folder").data("closed","N").stop().velocity({"rotateZ": "0"}, {duration: 500 });
			menuTree.find("._itemList").slideDown( 500 );
			
		} else if ( action == "collapseAll" ) {
			
			menuTree.find("._folder").data("closed","Y").stop().velocity({"rotateZ": "0"}, {duration: 0}).velocity({"rotateZ": "-=90"}, {duration: 500});
			menuTree.find("._itemList:not([data-level='root'])").slideUp( 500 );
			
		} 
		  
		event.stopPropagation();
	});   
	
	function findNearest( target, selector ) {  
		if( target.next(selector).exists() ) {
			return target.next(selector);	
		}
		
		if( target.prev(selector).exists() ) {
			return target.prev(selector);
		}
		
	    return target.parent().parent();
	}
}

var LGSYSC00180 = function(){
	
    var myForm = this;
    
  
    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock",   left : 0, right : 0, top : 0 },		
		{ name  : "treeTools",     left : 0, right : 0, top : "searchBlock", width : 600, bottom : "tree" },
		{ name  : "controls",      left : "treeTools", right : 0, top : "searchBlock", bottom : "dataBlock"},
		{ name  : "tree",          left : 0, right : 0, top : "treeTools", width : 600, bottom : 0 },		
	 	{ name  : "dataBlock",     left : "tree", right : 0, top : "treeTools", bottom : 0  }		
	]);     
    
    myForm.searchConditionControl( false );
    
    this.validator = new Validator( myForm, ".menuItem", {
    	rules  : {
    		moduleCode : { required : true },
            menuName : { required : true },
            menuDesc : { required : true },
    		programId : { required : true },
    		programName : { required : true }    		
    	},
    	
    	messages : {
    		moduleCode : { required : "Required" },
    		menuName : { required : "Required" },
    	    menuDesc : { required : "Required" },
    	    programId : { required : "Required" },
    	    programName : { required : "Required" }    	    
    	}
    } );
    
    var menuForm = new FormUtil( myForm, ".menuItem.form");

    var code = new CommonCode("lgcom");
    code.add(  "LGCOM_SYSTEM_CODE" , { codeTypeCode : "LGCOM_SYSTEM_CODE" } );
    code.add(  "LGCOM_MODULE_CODE" , { codeTypeCode : "LGCOM_MODULE_CODE" } );
    code.add(  "LGCOM_YN_FLAG"     , { codeTypeCode : "LGCOM_YN_FLAG" } );
    
    code.execute();
    
    var searchForm = new FormUtil( myForm, ".searchBlock .form" );
    searchForm.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE")  );
    searchForm.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE") , {selectAll : true, filter : "systemCode"} );     
    menuForm.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE") , {selectEmpty : true} );
    
    menuForm.initCombo( "displayFlag", code.get("LGCOM_YN_FLAG") );
    menuForm.initCombo( "useFlag", code.get("LGCOM_YN_FLAG") );
    menuForm.initCombo( "popUpScreenFlag", code.get("LGCOM_YN_FLAG") );
    
    var menuTree = new MenuTree( myForm, ".tree", menuForm, searchForm ); //myForm.select(".tree");
    
    menuForm.addChangeEvent( function( currentData, originalData, isChanged  ){
    	//폼에서 변경직후에 모은 폼의 데이터의 menuId 를 받아서, 이것으로 메뉴트리의 아이템을 호출한다.
    	var menuInfo = menuTree.getMenuInfo( currentData["menuId"] );
    	var status = menuInfo["status"];
    	
    	if( status != "C" ) {
        	if( isChanged ) {
        		currentData["status"] = "U";
        	} else {
        		currentData["status"] = "N";
        	}
    	} else {
    		currentData["status"] = status;
    	}

    	menuTree.setMenuInfo( currentData );
    	menuTree.refresh();
    });    
    
    
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action], .form .find" , function(event){
		var action = $(event.target).data("action");
		var programPopup = myForm.popupInfo.programPopup;
		
		switch( action ){
		    case "search" :
		    	myForm.validator.resetForm();
		    	menuTree.loadData();
				break;
			
		    case "openPopup" :
		    	programPopup["programName"] = menuForm.getValue("programName");
		    	programPopup["systemCode"]  = searchForm.getValue("systemCode");

		    	var popup = new Popup( myForm, "lgcom", "M_LGSYSC_1135", "<lgcom:message code="ProgramSearch"/>" );
		    	popup.setSize( 600, 500 );
		    	popup.addParam("a", "b");
		    	popup.addParam("c", "d");
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
		    	});
		    	break;
		    case "save" :
         		saveTreeData();	
		    	break;
		    case "test" :
		    	
		    	
		    	break;
			case "dataExchange" : 
				myForm.setData("test", { data1 : "A", data2 : "B"} );
			
		    break;		    	
		}
		
		event.stopPropagation();
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
	
	this.print = function( value ) {
		trace("ASDFASDFASDFASDF : " + value );
	}
	
	myForm.popupInfo = { programPopup : {} };
	
	myForm.test = function() {
		return "sdfasdfasd";
	}
	
	
	function saveTreeData() {
		//저장하기 직전에, 전체적으로 Reorder 를 수행하고, 이때 상위메뉴 아이디까지 모두 정리 한다.
		menuTree.reorderMenuItems();
		var data = menuTree.getChangedList();
		
		if( data == null ) { 
			return;
		}

		if( data["created"].length + data["updated"].length + data["deleted"].length  ==  0 ) {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
            return; 			
		}

		Message.confirm("<lgcom:message code="question.save" />", function(){
			transaction( "lgcom", "lgsysc/LGSYSC00180/updateMenuList", data, function(){
				menuTree.loadData( true );
				myForm.validator.resetForm();
				Message.notify('<lgcom:message code="note.completed" />');
			});
		});
	}
}


LGSYSC00180.prototype = new BizForm("${param.bizFormId}");





</script>
<style>

.LGSYSC00180.tree { 
    overflow-y : auto;     
}

</style>
</head>   

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
	    <h2>Menu List</h2>
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
		                <col width="100">
		            </colgroup>
		            <tbody> 
		                <tr>
		                    <th><label class="required"><lgcom:message code="System" /></label></th>
		                    <td>
		                        <select class="form-control input-sm input-require" name="systemCode"  ></select>
		                    </td>
		                    
		                    <th><label ><lgcom:message code="Module" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="moduleCode"></select>
		                    </td>
		                    
		                    <th><label><lgcom:message code="MenuName" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="menuName"></td>
		                </tr>		                		                		                
		            </tbody>
		        </table>
		        <button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search"><lgcom:message code="search"/></button>		        
	    </form>
	</div> 


    <div class="LGSYSC00180 treeTools gridControls module-group text-right">
    	<div class="btn-toolbar">	
			<div class="btn-group">
				<button type="button" class="btn btn-default btn-cube" data-action ="expandAll" data-toggle="tooltip" data-placement="top" title="Expand All"><i class="fa fa-plus" aria-hidden="true"></i></button>
				<button type="button" class="btn btn-default btn-cube" data-action ="collapseAll" data-toggle="tooltip" data-placement="top" title="Collapse All"><i class="fa fa-minus" aria-hidden="true"></i></button>
			</div>
			<div class="btn-group">		
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="add"><span class="fa fa-plus" aria-hidden="true"></span><lgcom:message code="Add" /></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="addChild"><span class="fa fa-plus" aria-hidden="true"></span><lgcom:message code="AddChild" /></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span><lgcom:message code="Delete" /></button>
			</div>
		</div>		
	</div>
    
	<div class="LGSYSC00180 tree noselect box">
	</div>
	
	
    <div class="LGSYSC00180 controls module-group text-right" >
    	<div class="btn-toolbar">	
			<div class="btn-group">    
        		<button class="btn btn-gray btn-sm" type="submit" data-action="save" ><lgcom:message code="save" /></button>
        	</div>
        </div>		
   </div>	
	
    <div class="LGSYSC00180  dataBlock">
	    <form class="menuItem form" >
 	        <input type="hidden" name="highMenuId" />
 	        <input type="hidden" name="status" />
 	        
			<table class="table table-condensed" summary="입력 테이블">
				<caption class="sr-only-lgd">입력 테이블</caption>
				<colgroup>
					<col width="100">
					<col width="200">
					<col width="100">
					<col width="300">
				</colgroup>
				<tbody>
					<tr>
						<th scope="row">
							<label ><lgcom:message code="System" /></label>
						</th>
						<td>
							<input type="text" name="systemCode" class="form-control input-sm" disabled />
						</td>
						
						<th scope="row">
							<label class="required"><lgcom:message code="Module" /></label>
						</th>
						<td>
							<select class="form-control input-sm" name="moduleCode"></select>
						</td>
					</tr>
					
					<tr>
						<th scope="row">
							<label><lgcom:message code="ParentMenuName" /></label>
						</th>
						<td>
							<input type="text" name="parentMenuName" class="form-control input-sm" disabled />
						</td>
						
						<th scope="row">
							<label for="textarea01"><lgcom:message code="MenuId" /></label>
						</th>
						<td>
							<input type="text" name="menuId" class="form-control input-sm"  disabled/>
						</td>
					</tr>
					

					<tr>
						<th scope="row">
							<label class="required" for="textarea01"><lgcom:message code="MenuName" /></label>
						</th>
						<td>
							<input type="text" name="menuName" class="form-control input-sm"  />
						</td>					
					
						<th scope="row">
							<label class="required"><lgcom:message code="MenuDescription" /></label>
						</th>
						<td scope="row">
							<input type="text" name="menuDesc" class="form-control input-sm"  />
						</td>
												
					</tr>					
					
					<tr>
						<th scope="row">
							<label><lgcom:message code="Parameter" /></label>
						</th>
						<td colspan="3">
							<input type="text" name="menuUrlAddr" class="form-control input-sm"  placeholder="<lgcom:message code="placeholder.additionalParameter" />" />
						</td>
												
					</tr>				
					
					
					<tr>
						<th scope="row">
							<label><lgcom:message code="ProgramName" /></label>
						</th>
						
						<td >
							<input type="text" name="programId" class="form-control input-sm" disabled />
						</td>
						
                        <td colspan="2">
	                        <div class="input-group input-group-sm input-search ">
	                            <input type="text" class="form-control " name="programName" />
	                            <span class="input-group-btn"><label class="required"></label>
	                                <button class="btn btn-default ico-lgd find" type="button" data-action="openPopup"  >
	                                    <span class="fa fa-search" aria-hidden="true"></span>
	                                </button>
	                            </span>
	                        </div>		


						</td>
												
					</tr>
						
					<tr>
						<th scope="row">
							<label><lgcom:message code="MenuLevel" /></label>
						</th>
						<td>
							<input type="text" name="menuLevelNo" class="form-control input-sm" disabled />
						</td>
						
						<th scope="row">
							<label for="textarea01"><lgcom:message code="SortOrder" /></label>
						</th>
						<td>
							<input type="text" name="sortOrderNo" class="form-control input-sm" disabled />
						</td>
					</tr>
					
					<tr>
						<th scope="row">
							<label><lgcom:message code="DisplayFlag" /></label>
						</th>
						<td>
							<select name="displayFlag" class="form-control input-sm" data-type="yes_no"></select>
						</td>
						
						<th scope="row">
							<label><lgcom:message code="UseFlag" /></label>
						</th>
						<td>
							<select name="useFlag" class="form-control input-sm" data-type="yes_no"></select>
						</td>
					</tr>											
										
					<tr>
						<th scope="row">
							<label><lgcom:message code="PopupFlag" /></label>
						</th>
						<td>
							<select name="popUpScreenFlag" class="form-control input-sm" data-type="yes_no"></select>
						</td>
						
						<td></td>
						<td></td>
					</tr>											
												
					
				</tbody>
			</table> 	        
 	        
	    </form>
	    
		<ul class="list-unstyled">
		    <li class="text-rubric"><i class="fa fa-exclamation-circle"></i><lgcom:message code="placeholder.sortingOperationInfo" /></li>
		</ul>	
		
	</div>
	
  </section>        
</div>	

<script>
$(document).ready( function() {
	
	launch( function(){
		var form = new LGSYSC00180();
		form.init();
	});
	
});

</script>
</body>
</html>
