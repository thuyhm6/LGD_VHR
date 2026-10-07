<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : userMenu.jsp
    프로젝트명 : LGD WCFW Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 사용자별로 본인의 메뉴 트리를 작성하고 관리하기 위한 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>User Menu</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
MenuTree = function( myForm, selector, menuForm , searchForm ){
    var menuTree = myForm.select(selector);
    var selected;
    var menuInfoMap = new Map();
    var deletedMenuInfo = new Array();
    
    /*특정한 메뉴 아이디를 가지고 올 때, 어떤 레벨이든 그 해당 아이템만 리턴하는 메소드 */
    this.getMenuInfo = function( menuId ){
    	return menuInfoMap.get( menuId );
    }
    
    /*특정한 메뉴 아이디를 가지고 올 때, 이 아이템의 레벨에 따라, 그 하위에 속한 모든 아이템을 리턴하는 메소드 
    .*/
    this.getMenuInfoList = function( menuId ){
    	var list = [];
    	list.push( menuInfoMap.get( menuId ) );
    	
    	$( menuInfoMap.keys() ).each( function(){
    		if( menuInfoMap.get( this )["highMenuId"] == menuId ) {
    			list.push( menuInfoMap.get( this ) );
    		}
    	});
    	
    	return list;
    }
    
    
    this.setMenuInfo = function( menuInfo ){
    	menuInfoMap.put( menuInfo["menuId"], menuInfo );
    	selected.find("._name").text( menuInfo["menuName"] );
    }    
 
	function select( item ) {
		//해당 아이템을 선택한것으로 표시한다. 
		menuTree.find(".selected").removeClass("selected");
		item.children("._name").addClass("selected");

		var menuInfo = menuInfoMap.get( $(item).data("id") );

		if( menuForm != null) {
			menuForm.setValue( menuInfo );
			
			if( menuInfo["menuLevelNo"] != "3" ) {
				menuForm.disable("programName");
				menuForm.disable("urlAddr");
			} else {
				menuForm.enable("programName");
				menuForm.enable("urlAddr");
			}
			
			if( menuInfo["menuLevelNo"] == "1" ) {
				menuForm.enable("moduleCode");
			} else {
				menuForm.disable("moduleCode");
			}		
			
		}
		
        selected = item;
	}
	
	function _node( item ) {
		var node = $('<li class="_item" data-level="'+item["menuLevelNo"]+'" data-id="'+item["menuId"]+'"><i class="_folder rotate0 fa fa-caret-down"></i><div class="_name">'+ item["menuName"] +'</div><span class="_exisingLabel label label-lgd">Added</span><ul class="_itemList" data-level="'+item["menuLevelNo"]+'" data-id="'+item["menuId"]+'"></ul></li>');

		if( item["userMenuYn"] == "Y" ) {
			node.find("._exisingLabel").fadeIn(200);
		}
		
		if( item["menuLevelNo"] == "3" ) {
			node.find("._folder").remove();   
		}
		
		return node;
	}
	
	this.loadData = function( quite ){
		loadMenuTree( quite );
	}
    
    function loadMenuTree( quite ) {
    	if( quite != true ) {
    	    myForm.showProgress(".tree");
    	}
    	
    	transaction( CONTEXT_PATH, "lgsysc/LGSYSC00220/retrieveMenuListByRole", searchForm.getValue() , function(data){
    		if( quite != true ) {
    		    myForm.hideProgress();
    		}
    		
    		//삭제 대상 목록을 모두 비운다. 
    		deletedMenuInfo.length = 0;
    		menuInfoMap.clear();
    		
    		var root  = $('<div class="_tree" ><ul class="_itemList" data-level="root"></ul></div>');
    		myForm.select(".tree").empty().append( root );
    		
			$(data["result"]).each( function(inx){
    			var item = this;
    			//이 모든 항목은 이미 DB에서 온 것이기 때문에, status 를  N ( normal ) 로 지정해준다. 
    			item["status"] = "N";
    			
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

    	    myForm.select(".tree ._item[data-level='3'], .tree ._item[data-level='2']").draggable({
    	    	scroll: false,
    	    	helper: function(){
    	    		$copy = $(this).clone();
    	    		$copy.find("._exisingLabel").remove();
    	    		$copy.find("._folder").remove(); 
    	    		
    	    		$copy.css({"list-style":"none", "width":$(this).outerWidth() + "px", "z-index" : "99999" }); 
    	    		$( $copy ).addClass("_dragging_");
    	    		return $copy; 
    	    	},
                appendTo: "div#${param.bizFormId}"
    	    });
    	    
    	    
    	    
    	    select( $(root).find("._item").first() );
    	});
    }
    
    this.reorderMenuItems = function() {
    	_reorderMenuItems();
    }
    
    function _reorderMenuItems( root , highMenuId ) {
    	if( root == undefined ) {
    		root = myForm.select("[data-level='root']._itemList");
    	}
    	
    	if( highMenuId == undefined ) {
    		highMenuId = "";
    	}
    	
    	var children = $(root).children("._item ");
    	
    	var sortOrderNo = 0;
    	$(children).each( function(){
    		var menuInfo = menuInfoMap.get( $(this).data("id") );

    		if( menuInfo != undefined && menuInfo.status != "D" ) {
        		menuInfo.sortOrderNo = sortOrderNo++;
        		menuInfo.highMenuId = highMenuId; // 위에서 들어온 상위 메뉴 아이디는 자기에게 담고
        		
        		if( $(this).children("._itemList ").exists() ) {
        			_reorderMenuItems( $(this).children("._itemList "), menuInfo.menuId  ); //자기의 메뉴아이디를 하위로 내려보낸다
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
   	
    myForm.addEvent( "click", ".tree li ._folder, .tree ._item[data-level='1'] ._name, .tree ._item[data-level='2'] ._name", function( event ){
    	var item = $(event.target);
    	if( !item.hasClass("._folder") ) {
    		item = $(item).prev();
    	}

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
    		$(item).parent().children("._itemList").slideDown( 500 , function(){
    			$(item).data("closed","N");
    		});
    		$(item).removeClass("rotate-90");
    	}
		
		event.stopPropagation();
	});	
    
	myForm.addEvent( "click", ".tree li ._name", function( event ){
		var item = $(event.target);
		select( item.parent() );

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
	
	this.collapseAll = function(){
		menuTree.find("._folder").addClass("rotate-90").data("closed","Y");
		menuTree.find("._itemList[data-level='1']").slideUp(300);
	}
	
	this.expandAll = function() {
		menuTree.find("._folder").removeClass("rotate-90").data("closed","N");
		menuTree.find("._itemList[data-level='1']").slideDown(300);
	}
}

UserMenuTree = function( myForm, selector, menuForm , searchForm  ){
    var menuTree = myForm.select(selector);
    var selected;
    var menuInfoMap = new Map();
    var deletedMenuInfo = new Array();
    var sourceTree;
    
    this.setSourceTree = function( tree ) {
    	sourceTree = tree;
    }
    
    this.getMenuInfo = function( menuId ){
    	return menuInfoMap.get( menuId );
    }
    
    this.setMenuInfo = function( menuInfo ){
    	menuInfoMap.put( menuInfo["menuId"], menuInfo );
    	selected.find("._name").text( menuInfo["menuName"] );
    }    
 
	function select( item ) {
		//해당 아이템을 선택한것으로 표시한다. 
		menuTree.find(".selected").removeClass("selected");
		item.children("._name").addClass("selected");

		var menuInfo = menuInfoMap.get( $(item).data("id") );

		if( menuForm != null) {
			menuForm.setValue( menuInfo );
			
			if( menuInfo["menuLevelNo"] != "3" ) {
				menuForm.disable("programName");
				menuForm.disable("urlAddr");
			} else {
				menuForm.enable("programName");
				menuForm.enable("urlAddr");
			}
			
			if( menuInfo["menuLevelNo"] == "1" ) {
				menuForm.enable("moduleCode");
			} else {
				menuForm.disable("moduleCode");
			}		
			
		}
		
        selected = item;
	}

	function _node( item ) {
		var node = $('<li class="_item" data-level="'+item["menuLevelNo"]+'" data-id="'+item["menuId"]+'"><i class="_folder rotate0 fa fa-caret-down"></i><input class="_checkbox" type="checkbox" value="1" data-level="'+item["menuLevelNo"]+'" /><div class="_name _wide">'+ item["menuName"] +'</div><ul class="_itemList" data-level="'+item["menuLevelNo"]+'" data-id="'+item["menuId"]+'"></ul></li>');
		
		if( item["menuLevelNo"] == "3" ) {
			node.find("._folder").remove();   
		}
		
		return node;
	}
	
	this.loadData = function( quite ){
		loadMenuTree( quite );
	}

	function addMenuItem ( list ) {
		$(list).each( function(inx){
			var item = this;

			//이 모든 항목은 이미 DB에서 온 것이기 때문에, status 를  N ( normal ) 로 지정해준다. 
			item.status = "N";
			
    		//menuInfo 에  menuId 별로 적재한다. 
    		menuInfoMap.put( item["menuId"], item );
    		
    		//해당 id를 가진 오브젝트가 있는지 확인하고, 없을때만 아래 로직을 진행한다.
    		if( !menuTree.find("._item[data-level][data-id='"+ item["menuId"] +"']").exists() ) {
    			if( item["menuLevelNo"] == "1" ) {
    				var node = _node(item);
    				menuTree.find("._itemList[data-level='root']").append( node );
    			} else  if( item["menuLevelNo"] == "2" ||  item["menuLevelNo"] == "3" ) {
    				var node = _node(item);
    				menuTree.find("._itemList[data-id='"+item["highMenuId"]+"']").append( node );
    			}
    		}
		}); 
	}	
	
    function loadMenuTree( quite ) {
    	if( quite != true ) {
    		myForm.showProgress(".tree2");	
    	}
    	
    	transaction( CONTEXT_PATH, "lgsysc/LGSYSC00220/retrieveUserMenuList", { systemCode : searchForm.getValue("systemCode") } , function(data){
        	if( quite != true ) {
    		    myForm.hideProgress();
        	}
    		
    		//삭제 대상 목록을 모두 비운다. 
    		deletedMenuInfo.length = 0;
    		menuInfoMap.clear();
    		
    		var root  = $('<div class="_tree" ><ul class="_itemList" data-level="root"></ul></div>');
    		myForm.select(".tree2").empty().append( root );
    		
    		addMenuItem(data["result"]);
			
    	    myForm.select(".tree2").droppable({
    	        drop: function(event, ui){
    	        	var item = $(ui.draggable);
    	        	
    	        	if( item.hasClass("_me_") ) {
    	        		return;
    	        	}
    	        	
    	        	if( item.data("level")  == "3" ) {
        	        	var menuInfoList = new Array();
                        var menuItem = sourceTree.getMenuInfo( $(item).data("id") ); 

                        $(ui.helper).fadeOut( function(){
                        	$(this).remove();
                        });
                        
                        menuInfoList.push(menuItem);
                        do {
                        	menuItem = sourceTree.getMenuInfo( menuItem["highMenuId"] );
                        	if( menuItem ) {
                        		menuInfoList.push(menuItem);
                        	}
                        	                    	
                        } while( menuItem != undefined && menuItem["highMenuId"] != null );

                        menuInfoList.reverse();
    	    	           
    	    	        addMenuItem( menuInfoList );

    	    	    	    //아이템 떨구기가 끝나면, 해당 아이템과 주변의 순서를 reorder 해준다.
    	    	    	_reorderMenuItems();   
    	    	    	    
                        $(item).find("._exisingLabel").show();
                        
    	        	} else if( item.data("level")  == "2" ){
    	    
        	        	var menuInfoList = new Array();
        	        	//방금 떨구어진 아이템에서 id 를 추출하면, 2 레벨의 아이디가 나온다. 
                        var menuInfoList = new Array();
                        var menuItem = sourceTree.getMenuInfo( $(item).data("id") ); 
                        
                        menuInfoList.push(menuItem);

                        $(ui.helper).fadeOut( function(){
                        	$(this).remove();
                        });
                        
                        //이 메뉴 아이템의 상위 아이템을 모두 인출해 온다. ( 아이템은 한개 밖에 없다 )                        
                       	menuItem = sourceTree.getMenuInfo( menuItem["highMenuId"] );
                  		menuInfoList.push(menuItem);
                        
                        //해당 레벨 기준으로 상위를 찾는 것이기 때문에, 다 추가 하고 뒤집어 줘야 위에서 부터 상위레벨이 된다. 
                        menuInfoList.reverse();                        
                        
                        //이 메뉴 아이템의 하위 아이템을 모두 인출해 와서, 이것을 추가 해준다. ( 뒤집힌 것에다가  append 로 붙이는 것이다 ) 
                        menuInfoList =  menuInfoList.concat( sourceTree.getMenuInfoList( $(item).data("id" ) ) );

    	    	        addMenuItem( menuInfoList );

   	    	    	    //아이템 떨구기가 끝나면, 해당 아이템과 주변의 순서를 reorder 해준다.
    	    	    	_reorderMenuItems();   
                        $(item).parent().prev().show();
                        $(item).find("._exisingLabel").show();  
    	        	}
    	        	
    	        }
    	    });
    	    
			myForm.select(".tree2 ._itemList").sortable({
							    	       revert: true,
							    	       delay: 300,
							    	       placeholder : "_treeItemPlaceHolder",
							    	       connectWith: ".tree2 ._itemListt",
							    	       stop : function( event, ui ){  // sorting 이 끝났을때 발동한다. ( 모든 경우에 대하여 ) 
							    	    	   //아이템 떨구기가 끝나면, 해당 아이템과 주변의 순서를 reorder 해준다.
							    	    	   _reorderMenuItems();
							    	       },
							    	       receive : function(event, ui){  // 이 콜백은 서로 다른 리스트의 아이를 받았을때에 발동된다.
							    	    	  
							    	    	   if( !isValidDrop( ui.sender, $(this) ) ) {
							    	    		   $(ui.sender).sortable('cancel');
							    	    		   return;
							    	    	   }
							    	    	   
							    	    	   //아이템 떨구기가 끝나면, 해당 아이템과 주변의 순서를 reorder 해준다.
							    	    	   _reorderMenuItems();
							    	       },
							    	       start: function(e, ui){
							    	    	   ui.item.addClass("_me_");
							    	           ui.placeholder.height(ui.item.height());
							    	       }
							    	   });

    	});
    }
    
    this.reorderMenuItems = function() {
    	_reorderMenuItems();
    }
    
    function _reorderMenuItems( root , highMenuId ) {
    	if( root == undefined ) {
    		root = myForm.select("[data-level='root']._itemList");
    	}
    	
    	if( highMenuId == undefined ) {
    		highMenuId = "";
    	}
    	
    	var children = $(root).children("._item ");
    	
    	var sortOrderNo = 1;
    	$(children).each( function(){
    		var menuInfo = menuInfoMap.get( $(this).data("id") );
    		
    		if( menuInfo != undefined && menuInfo.status != "D" ) {
        		menuInfo.sortOrderNo = sortOrderNo++;
        		menuInfo.highMenuId = highMenuId; // 위에서 들어온 상위 메뉴 아이디는 자기에게 담고
        		
        		if( $(this).children("._itemList ").exists() ) {
        			_reorderMenuItems( $(this).children("._itemList "), menuInfo.menuId  ); //자기의 메뉴아이디를 하위로 내려보낸다
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
   	
   	// 이 클래스에서의 getChangedList 메소드는 모든 항목이 신규 생성이다
   	this.getChangedList = function() {
   		//순서가 의미가 없다.
   		var result = { created :menuInfoMap.values() };
   		return result;
   	}
    
    myForm.addEvent( "click", ".tree2 li ._folder", function( event ){
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
    		$(item).parent().children("._itemList").slideDown( 500 , function(){
    			$(item).data("closed","N");
    		});
    		$(item).removeClass("rotate-90");
    		
    	}
		
		event.stopPropagation();
	});	
    
	myForm.addEvent( "click", ".tree2 li ._name", function( event ){
		var item = $(event.target);
		select( item.parent() );

		event.stopPropagation();
	});	
	

	myForm.addEvent( "click", ".userMenuList .btn, .userMenuList .btn i", function( event ){
		var item = $(event.target);
		
		if( !item.hasClass("btn") ) {
			item = $(item).parent();
		}
		var action = $(item).data("action");
		
		if ( action == "delete" ) {
			 var list = menuTree.find("._checkbox:checked").closest("._item");
			 $(list).each( function(){
				var id = $(this).data("id");
				myForm.select(".tree ._item[data-id='"+id+"']").find("._exisingLabel").hide();
				menuInfoMap.remove( id  );	
			 });
			 
			 $(list).remove();
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
	
	//체크박스를 선택하는 이벤트 
	myForm.addEvent("change", ".tree2 ._checkbox", function( event ){
		var item = $(event.target).closest("._item");
		var myLevel = item.data("level"); 
		
		if( $(event.target).is(':checked') ) {
			
			if( myLevel == "3" ) { 
				//자신과 동일한 레벨의 모든 체크박스들이 다 체크된 상황이라면, 상위항목들에 체크를 수행한다. 
				if( $(item).parent().find("._checkbox").length == $(item).parent().find("._checkbox:checked").length  ) {
					$(item).parents("._item").children("._checkbox").each( function(){
						$(this)[0].checked = true; //.prop("checked", true );
					});
				} 
			} else if( myLevel == "2" ) {  //하위의 모든 체크박스를 체크한다. 그리고 상위의 체크박스를 체크한다. 
				
				$(item).parents("._item").children("._checkbox").each( function(){
					$(this)[0].checked = true; //.prop("checked", true );
				});
			
				$(item).find("._checkbox").each( function(){
					$(this)[0].checked = true; //.prop("checked", true );
				});			
				
			} else if( myLevel == "1" ) {  //하위의 모든 체크박스를 체크한다.
				
				$(item).find("._checkbox").each( function(){
					$(this)[0].checked = true; //.prop("checked", true );
				});
			}  
		} else {
			if( myLevel == "3" ) {   
				//자신과 동일한 레벨의 모든 체크박스들이 다 체크 안된 상황이라면, 바로 위 항목들에 대한 체크 해제를 함께 수행한다.
				//단 상위레벨의 체크를 해제할 때는, 그 다른 자식들의 체크 여부를 함께 따져야 한다.
				if(  $(item).parent().find("._checkbox").length > $(item).parent().find("._checkbox:checked").length  ) {
					
					//2레벨 먼저 체크
					var targetLevel  =  $(item).parent().closest("._item");
				
					if( $(targetLevel).find("._checkbox[data-level='2']:checked").length == 1  ) {
						$(targetLevel).find("._checkbox[data-level='2']").each( function(){
							$(this)[0].checked = false; //.prop("checked", true );
						});
					}
				
					//1레벨 체크
					targetLevel  =  $(targetLevel).parent().closest("._item");
				
					if( $(targetLevel).find("._checkbox[data-level='1']:checked").length == 1  ) {
						$(targetLevel).find("._checkbox[data-level='1']").each( function(){
							$(this)[0].checked = false; //.prop("checked", true );
						});  
					}			
					
				}
			
			} else if( myLevel == "2" ) {  //하위의 모든 체크박스를 체크한다. 그리고 상위의 체크박스를 체크한다. 
				
				//3레벨은 모두 다 체크 해제
				$(item).find("._checkbox").each( function(){
					$(this)[0].checked = false; //.prop("checked", true );
				});
								
				
				//1레벨 체크
				var targetLevel  =  $(item).parent().closest("._item");
			
				if( $(targetLevel).children("._itemList" ).find("._checkbox:checked").length == 0  ) {
					$(targetLevel).children("._checkbox").each( function(){
						$(this)[0].checked = false; //.prop("checked", true );
					});
				}	

			} else if( myLevel == "1" ) {  //하위의 모든 체크박스를 체크한다.
				
				$(item).find("._checkbox").each( function(){
					$(this)[0].checked = false; //.prop("checked", true );
				});
			}  
		}
	});
	
	this.collapseAll = function(){
		menuTree.find("._folder").addClass("rotate-90").data("closed","Y");
		menuTree.find("._itemList[data-level='1']").slideUp(300);
	}
	
	this.expandAll = function() {
		menuTree.find("._folder").removeClass("rotate-90").data("closed","N");
		menuTree.find("._itemList[data-level='1']").slideDown(300);
	}
	
}


LGSYSC00220 = function(){
    var myForm = this;
    
    /* 이 화면의 레이아웃을 아래와 같이 정리 한다. : 자동확장 및 Sizing 을 위해서 */
    myForm.setManagedLayout({
   	 searchBlock : { left : 0 , top : 0 , right : 0 }, 
   	 treeTools  : { left : 0 , top : 40, width : 350  },
   	 controlGroup1 : { top : 40 , left : 0 ,  width : 400 },
   	 controlGroup2 : { top : 40 , left : 410 , right : 0 },
   	 tree : { left : 0 , top : 70, width : 400, bottom : 40 },
   	 tree2 : { top : 70, left : 410 , right : 0, bottom : 40 },
   	_information :  { left : 0 , bottom : 0, width : 600  }
    });     
        
    var code = new CommonCode(CONTEXT_PATH);
    code.add(  "LGCOM_SYSTEM_CODE" , { codeTypeCode : "LGCOM_SYSTEM_CODE" } );
    code.add(  "LGCOM_MODULE_CODE" , { codeTypeCode : "LGCOM_MODULE_CODE" } );
    code.execute();
    
    /*
    var values = new ValueSet();
    values.add( "VALUES1", {valueSetId : "LGCOM_LOGGING", codeTypeCode : "LGCOM_MODULE_CODE" } );
    values.execute();
    */
    var searchForm = new FormUtil( myForm, ".searchBlock .form" );
    searchForm.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE")  );
    searchForm.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE") , {selectAll : true, filter : "systemCode" } );
    
    var menuTree = new MenuTree( myForm, ".tree", null, searchForm ); //myForm.select(".tree");
    var userMmenuTree = new UserMenuTree( myForm, ".tree2", null, searchForm ); //myForm.select(".tree");
    userMmenuTree.setSourceTree(menuTree);
    
    
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var action = $(event.target).data("action");
		
		switch( action ){
		    case "search" :

		    	trace( JSON.stringify( searchForm.getValue()  ));		    	
		    	
		    	menuTree.loadData();
		    	userMmenuTree.loadData();
				break;
		    case "save" :
         		saveTreeData();	
		    	break;		    	
		} 
		
		event.stopPropagation();
	});   
	
	myForm.addEvent( "click", ".menuList button i, .menuList button", function(event){
		var item = $(event.target);
		
		if( !item.hasClass("btn") ) {
			item = item.parent();
		}
		
		var action = $(item).data("action");
		
		if( action =="expandAll" ) {
			menuTree.expandAll();
		} else if ( action =="collapseAll" ) { 
			menuTree.collapseAll();
		}
		
		event.stopPropagation();
	});
	
	myForm.addEvent( "click", ".userMenuList button i, .userMenuList button", function(event){
		var item = $(event.target);
		
		if( !item.hasClass("btn") ) {
			item = item.parent();
		}
		
		var action = $(item).data("action");
		
		if( action =="expandAll" ) {
			userMmenuTree.expandAll();
		} else if ( action =="collapseAll" ) { 
			userMmenuTree.collapseAll();
		}
		
		event.stopPropagation();
	});	
	
	
	function saveTreeData() {
		//저장하기 직전에, 전체적으로 Reorder 를 수행하고, 이때 상위메뉴 아이디까지 모두 정리 한다.
		userMmenuTree.reorderMenuItems();
		var data = userMmenuTree.getChangedList();		
		
		//if( data["created"].length == 0 ) {
			//Message.alert('<lgcom:message code="error.noChangedData"/>');   
     //       return 			
	//	}
		
		Message.confirm("<lgcom:message code="question.save" />", function(){
			transaction( CONTEXT_PATH, "lgsysc/LGSYSC00220/insertUserMenuList", data, function(){
		    	menuTree.loadData( true );
		    	userMmenuTree.loadData( true );
				Message.notify('<lgcom:message code="note.completed" />');
				
				
	    		//전체 탭을 닫고, 메인 화면을 그대로 리프레시한다. 
	    		var activeLevel1MenuId = $("header ._menu ._menuItem.active").data("id");
	    		var activeLevel2MenuId = $("aside ._menuBody a._level2._selected").data("id");
				var nav = new Navigate( "lgcom" , "main");
	    		nav.addParam("reload", "Y");
	    		nav.addParam("activeLevel1MenuId", activeLevel1MenuId );
	    		nav.addParam("activeLevel2MenuId", activeLevel2MenuId );
				nav.goPost();
			});
		});
	}
	
	
}


LGSYSC00220.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGSYSC00220();
		form.init();
	});	
});

</script>
<style>



._dragging_ {
    font-size : 12px;
    font-weight : bold;
    padding : 2px 15px;
    width : 200px;
    height : 20px;
    background : #FFFFFF;
    border-left : 5px solid #F34D78;
    box-shadow: 0 2px 4px 0 rgba(0, 0, 0, 0.2);
}

._dragging_ ._item[data-level='3'] {
    list-style-type: none;
    font-size : 12px;
    font-weight : bold;
    padding : 2px 15px;
    width : 200px;
    height : 20px;
    background : #FFFFFF;
    border-left : 5px solid #FFBCCD;    
    box-shadow: 0 2px 4px 0 rgba(0, 0, 0, 0.2);
}

.dataBlock .table>tbody>tr>td, .dataBlock .table>tbody>tr>th {
    border : 0px;
    padding : 0px;
    vertical-align: middle;
    height : 35px;
}

.dataBlock .table {
    border : 0px;
}

.dataBlock .table {
    border-top : 1px solid #C8C8C8;
}

.dataBlock .table>tbody>tr {
    width : 100%;
    border-bottom : 1px solid #DEDEDE;
}

.dataBlock .table>tbody>tr>th {
    text-align : right;
    padding-right : 10px;
    background-color : #F2F2F2;
}

.dataBlock .table>tbody>tr>td {
    text-align : left;
    padding : 0px 10px;
    background-color : #FFFFF;
}

.dataBlock .table {

}

.dataBlock .table tr, .dataBlock .table td {
    
}

.dataBlock .table td {
    text-align : left;
    vertical-align : center;
    height : 35px;
}

.dataBlock .form label {
    margin-bottom : 0px;
}

.dataBlock .form .control {
    height : 28px;
    width : 100%;
}

.LGSYSC00180.tree, .LGSYSC00180.tree2 { 
    overflow-y : auto;     
    overflow-x : hidden;  
}

</style>
</head>   

<body>
<div class="container">
  <section class="page-content">
	<div class="pageHeader">
	    <h2>User Menu</h2>
	</div>

	<div class="searchBlock">

		<form class="form search-wrap">
		    <fieldset>
		        <table class="table" >
		            <colgroup>
		                <col width="90">
		                <col width="90">
		                <col width="90">
		                <col width="90">
		                <col width="120">
		                <col width="280">
		                <col width="*">
		            </colgroup>
		            <tbody>
		                <tr>
		                    <th><label ><lgcom:message code="System" /></label></th>
		                    <td>
		                        <select class="form-control input-sm input-require" name="systemCode"></select>
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
		    <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
		</form>	    
	</div> 
	
    <div class="LGSYSC00180 treeTools menuList controlGroup1">
		<div class="btn-group" role="group" aria-label="First group">
			<button type="button" class="btn btn-default btn-cube" data-action ="expandAll" data-toggle="tooltip" data-placement="top" title="Expand All"><i class="glyphicon glyphicon-plus" aria-hidden="true"></i></button>
			<button type="button" class="btn btn-default btn-cube" data-action ="collapseAll" data-toggle="tooltip" data-placement="top" title="Collapse All"><i class="glyphicon glyphicon-minus" aria-hidden="true"></i></button>
		</div>
	</div>
	
	<div class="LGSYSC00180 tree noselect box"></div>
	
    <div class="LGSYSC00180 treeTools userMenuList gridControls controlGroup2" >
    
		<div class="btn-group" role="group" aria-label="First group">
			<button type="button" class="btn btn-default btn-cube" data-action ="expandAll" data-toggle="tooltip" data-placement="top" title="Expand All"><i class="glyphicon glyphicon-plus" aria-hidden="true"></i></button>
			<button type="button" class="btn btn-default btn-cube" data-action ="collapseAll" data-toggle="tooltip" data-placement="top" title="Collapse All"><i class="glyphicon glyphicon-minus" aria-hidden="true"></i></button>
		</div>    
    
		<button class="btn btn-default btn-sm" type="button" role="button" data-action="delete"><i class="glyphicon glyphicon-remove"></i><lgcom:message code="Delete" /></button>
		<div class="divider" ></div>    
        <button class="btn btn-save btn-sm" type="submit" data-action="save" ><lgcom:message code="save" /></button>
   </div>	
	
   <ul class="_information list-unstyled" >
       <li class="text-rubric"><i class="fa fa-exclamation-circle"></i><lgcom:message code="placeholder.myMenuOperationInfo" /></li>
   </ul>		
	

	<div class="LGSYSC00180 tree2 noselect box"></div>	
	      
	      
</section>	      
</div>	
</body>
</html>
