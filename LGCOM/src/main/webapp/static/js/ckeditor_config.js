/**
 * @license Copyright (c) 2003-2016, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';
	config.fullPage = true;
	config.toolbarCanCollapse = true;
	config.startupFocus = false;
	config.extraPlugins = 'templates,uploadimage,uploadwidget,wysiwygarea';
	config.removePlugins = 'resize,magicline';
	// 이미지 파일을 Copy & Paste 하거나 파일을 Drag And Drop 할 경우 사용하는 경로
	config.imageUploadUrl = '/lgcom/upload/ckeditor?type=stream';
	// 이미지 파일을 첨부할 경우 사용하는 경로
	config.filebrowserImageUploadUrl = '/lgcom/upload/ckeditor?type=file';
	config.removeDialogTabs = 'link:advanced;link:upload;image:Link;image:advanced';

	config.undoStackSize = 0;
	config.useComputedState = false;

	config.skin = 'bootstrapck';
	
	//20171113 이준성 엑셀 내용 그대로 복사해 오기.
	config.pasteFromWordPromptCleanup = true;
	config.pasteFromWordRemoveStyles = false;
	config.pasteFromWordRemoveFontStyles = false;
	config.allowedContent=true;
	/*
	config.contentsCss = [
		CKEDITOR.getUrl( 'contents.css' ),
		CKEDITOR.getUrl( CKEDITOR.basePath + '../../css/ckeditor.css' )
	];
	config.bodyClass = 'lgcom_body';
	*/

	// CKEditor 에 LG Smart체 폰트 추가
	config.font_names = 'LG Smart Light/LG스마트체 Light,LG_Smart_Light;LG Smart Regular/LG스마트체 Regular,LG_Smart_Regular;LG Smart SemiBold/LG스마트체 SemiBold,LG_Smart_SemiBold;LG Smart Bold/LG Smart Bold/LG스마트체 Bold,LG_Smart_Bold;' + CKEDITOR.config.font_names;

	config.toolbarGroups = [
		{ name: 'document', groups: [ 'mode', 'document', 'doctools' ] },
		{ name: 'clipboard', groups: [ 'clipboard', 'undo' ] },
		{ name: 'editing', groups: [ 'find', 'selection', 'spellchecker', 'editing' ] },
		{ name: 'forms', groups: [ 'forms' ] },
		{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
		{ name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi', 'paragraph' ] },
		{ name: 'links', groups: [ 'links' ] },
		{ name: 'insert', groups: [ 'insert' ] },
		{ name: 'styles', groups: [ 'styles' ] },
		{ name: 'colors', groups: [ 'colors' ] },
		{ name: 'tools', groups: [ 'tools' ] },
		{ name: 'others', groups: [ 'others' ] },
		{ name: 'about', groups: [ 'about' ] }
	];

	/**
	 * CKEditor의 Toolbar Configurator 로 생성한다.
	 * /LGCOM/src/main/webapp/static/ext/ckeditor_4.5.11/samples/index.html
	 */
	config.removeButtons = 'Source,Save,Preview,Templates,Scayt,Checkbox,Radio,TextField,Textarea,Select,Button,ImageButton,HiddenField,CreateDiv,BidiLtr,BidiRtl,Language,Anchor,Flash,Iframe';
};

CKEDITOR.on('dialogDefinition',function( ev ) {
	// Take the dialog name and its definition from the event data.
	var dialogName = ev.data.name;
	var digDefinition = ev.data.definition;
	var dialogObj = digDefinition.dialog;
	digDefinition.resize = CKEDITOR.DIALOG_RESIZE_BOTH;
	// Check if the definition is from the dialog we're
	// interested in (the 'image' dialog). This dialog name found using DevTools plugin
	if ( dialogName == 'link' ) {
		// Get a reference to the 'Link Info' tab.
		//var infoTab = dialogDefinition.getContents( 'info' );  // info탭을 제거하면 이미지 업로드가 안된다.
		//infoTab.remove('linkType');
		//infoTab.get('protocol')['items'].splice(1,4);
		// Get a reference to the 'Link Target' tab.
		//var targetTab = dialogDefinition.getContents( 'target' );  // Target Tab
		//targetTab.get('linkTargetType')['items'].splice(0,3);
		//targetTab.get('linkTargetType')['items'].splice(1,3);
		//targetTab.get('linkTargetType')['default']='_blank';
	}
	else if ( dialogName == 'image' ) {
		// Get a reference to the 'Image Info' tab.
		var infoTab = digDefinition.getContents( 'info' );  // info탭을 제거하면 이미지 업로드가 안된다.
		// Remove unnecessary widgets/elements from the 'Image Info' tab.
		infoTab.remove('txtHSpace'); //info 탭 내에 불필요한 엘레멘트들 제거
		infoTab.remove('txtVSpace');
	}
	else if ( dialogName == 'table' ) {
	}

	dialogObj.on('show',function() {
		if($.trim(this.getElement().getStyle('display')) == 'none') {
			this.getElement().setStyle('display','');
		}
	})
});
