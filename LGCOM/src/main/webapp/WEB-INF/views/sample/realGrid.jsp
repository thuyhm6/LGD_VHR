<%@ page language="java"  pageEncoding="utf-8"%>
<%---------------------------------------------------------
    파일명 : realGrid.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Real Grid Sample
    작성자 : wcfw
-------------------------------------------------------------%>
<!DOCTYPE html>
<html lang="${sessionScope.USER_SESSION.languageCode}">
<head>
<title>WCFW</title>
<meta http-equiv="x-ua-compatible" content="IE=edge">
<%@ include file="/WEB-INF/views/framework/header.jsp" %>
<script>
var gridView;
var gridData;
$(function() {
	RealGridJS.setTrace(false);
	RealGridJS.setRootContext('/lgcom/static/ext/realgrid/dev');

	gridData = new RealGridJS.LocalDataProvider();
	gridView = new RealGridJS.GridView("grid");
	gridView.setDataSource(gridData);
	// Grid 초기화
	fncInitGrid();

	$('.container .controls button.btn').click(function() {
		switch($.trim($(this).data('action'))) {
			case 'insert':
				gridView.commit();
				if(gridView.getItemCount() == 0) {
					gridView.beginAppendRow();
				} else {
					gridView.beginInsertRow(0);
				}
				break;
			case 'info':
				trace(gridView.getColumns());
				break;
		}
	});

	function fncInitGrid() {
		gridData.setFields([
			{ fieldName: 'key1' , dataType:'text' },
			{ fieldName: 'key2' , dataType:'text' },
			{ fieldName: 'key3' , dataType:'text' },
			{ fieldName: 'key41', dataType:'text' },
			{ fieldName: 'key42', dataType:'text' }
		]);
		gridData.setOptions({
			insertable: true,
			updatable: true,
			deletable: true,
			softDeleting: true,
			deleteCreated: true
		});

		gridView.setLookups([
			{
				id:'lookup1',
				levels:1,
				keys:['Y','N'],
				values:['Yes','No'],
				ordered: true
			},
			{
				id:'lookup2',
				levels:2,
				keys:[
					['Y','1a'],
					['Y','1b'],
					['Y','1c'],
					['N','1a'],
					['N','2a'],
					['N','2b'],
					['N','2c']
				],
				values:['[Y,1a]','[Y,1b]','[Y,1c]','[N,1a]','[N,2a]','[N,2b]','[N,2c]'],
				ordered: true
			},
			{
				id:'lookup3',
				levels:3,
				ordered: true,
				keys:[
					['Y','1a','AA'],
					['Y','1a','AB'],
					['Y','1b','BA'],
					['Y','1b','BB'],
					['Y','1b','BC'],
					['Y','1c','CA'],
					['Y','1c','CB'],
					['N','1a','NA'],
					['N','1a','NB'],
					['N','1a','ND'],
					['N','2a','Na'],
					['N','2a','Nb'],
					['N','2b','NB1'],
					['N','2b','NB2'],
					['N','2b','NB3'],
					['N','2b','NB4'],
					['N','2c','NC1'],
					['N','2c','NC2']
				],
				values:[
					'[Y,1a,AA]','[Y,1a,AB]','[Y,1b,BA]','[Y,1b,BB]','[Y,1b,BC]',
					'[Y,1c,CA]','[Y,1c,CB]','[N,1a,NA]','[N,1a,NB]','[N,1a,ND]',
					'[N,2a,Na]','[N,2a,Nb]','[N,2b,NB1]','[N,2b,NB2]','[N,2b,NB3]',
					'[N,2b,NB4]','[N,2c,NC1]','[N,2c,NC2]'
				]
			}
		]);
		gridView.setColumns([
			{
				name:'key11',
				fieldName: 'key1',
				header: {text:'Column1'},
				width: 150,
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'lookup1',
				lookupKeyFields: ['key1'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'key12',
				fieldName: 'key2',
				header: {text:'Column2'},
				width: 150,
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'lookup2',
				lookupKeyFields: ['key1','key2'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'key13',
				fieldName: 'key3',
				header: {text:'Column3'},
				width: 150,
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'lookup3',
				lookupKeyFields: ['key1','key2','key3'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				type:'group',
				orientation:'horizontal',
				name:'key4',
				header : { text:'key4', styles:{fontBold:true} },
				width: 140,
				columns: [
					{
						name:'key41',
						fieldName:'key41',
						width:70,
						header: {text:'key41'},
						styles: {textAlignment:'center'}
					},
					{
						name:'key42',
						fieldName:'key42',
						width:70,
						header: {text:'key42'},
						styles: {textAlignment:'center'}
					}
				]
			}
		]);
		gridView.setOptions({
			hideDeletedRows: false,
			checkBar: {visible:false},
			copy: {
				enabled: true,
				singleMode: true,
				lookupDisplay: false
			},
			display: {
				fitStyle: 'none'
			},
			edit: {
				insertable: true,
				appendable: true,
				updatable: true,
				deletable: true,
				enterToTab: true
			},
			header: {resizable:true},
			indeicator: {visible:false},
			panel: {visible:false},
			stateBar: {visible:false},
			footer: {visible:false}
		});
	}
});
</script>
</head>

<body>
<div class="container">
	<div class="pageHeader">
		<h2>Grid Function Tester</h2>
	</div>
	<div class="searchBlock">
	</div>
	<div class="controls">
		<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> Add</button>
		<button class="btn btn-default btn-sm" type="button" role="button" data-action="info"><span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span> Info</button>
	</div>
	<div class="content">
		<div id="grid" class="grid" style="height:300px;"></div>
	</div>
</div>
</body>
</html>
