<%@ page language ="java"  pageEncoding="utf-8" contentType="text/html; charset=utf-8" %>
<%---------------------------------------------------------
    파일명 : realGrid2.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Real Grid Sample2
    작성자 : wcfw
-------------------------------------------------------------%>
<body>
	<div class= "title">
		<span>RealGrid on DevonFrame and Oracle</span>
	</div>
	
	<div id = "grdMain" style="height:300px;"></div>

	<input type="button" id="btnInsert"	value="Insert Row" />
	
	<input type="button" id="sampleTest" onclick="loadSessionData();">sessionTest</input>

<script>
var gridView;
var dataProvider;

    
$(document).ready( function() {
	buildGrid();
	
    
});


function buildGrid() {

	var grid = new RealGrid("grdMain");
	
	var fields = [  { fieldName: "userId", dataType: "number"	}
				  , { fieldName: "userName"	}
				  , { fieldName: "employeeNumber"	}
				  , { fieldName: "empName"	}
				  , { fildName: "empNameEng"	}];
	
	grid.setFields( fields );
	grid.setOptions( 
			{ edit: { insertable: true,
					  appendable: true,
				  	  deletable: true,
					  deleteRowsConfirm: true,
					  deleteRowsMessage: "Are you sure?" } },
			
			{ softDeleting : true }
	);

	
	grid.setColumns( 
			[{
				fieldName : "userId",
				width: 80,
				header: {text: "사용자ID"},
				styles: {textAlignment: "far"}
			}, {
				fieldName : "userName",
				width: 80,
				header: {text: "사용자명"},
				styles: {textAlignment: "near"}
			}, {
				fieldName : "employeeNumber",
				width: 80,
				header: {text: "사번"},
				styles: {textAlignment: "near"}
			}, {
				fieldName : "empName",
				width: 80,
				header: {text: "임직원명"},
				styles: {textAlignment: "near"}
			}, {
				fieldName : "empNameEng",
				width: 80,
				header: {text: "임직원영문명"},
				styles: {textAlignment: "near"}
			}]
	);
	
	grid.setContextMenu( 
			[
		        { label: "Menu1"}, 
		        { label: "Menu2"}, 
		        { label: "-" },// menu separator}, 
		        { label: "Menu3" }, 
		        { label: "child Menus",
		            children:[
		                {label:"child1"},
		                {label:"child2"}
		            ]  
		        }
		    ],
		    
		    function( grid, label, index ){
				alert("Context menu가 클릭됐습니다: " + label.label + "n" + JSON.stringify(index));
			}
	);
	
	grid.loadData("sample/user/retrieveUserList", {} , function(){
		trace("데이터 로딩 완료");
	});
}

function btnInsertClickHandler(e){
	var curr = grdMain.getCurrent();
	grdMain.beginInsertRow(Math.max(0, curr.itemIndex));
	grdMain.showEditor();
	grdMain.setFocus();
}

</script>

</body>
	
</html>
