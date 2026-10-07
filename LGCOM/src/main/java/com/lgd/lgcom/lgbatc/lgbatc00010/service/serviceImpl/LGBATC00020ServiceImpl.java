/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSETC00010Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 03.    김치민    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgbatc.lgbatc00010.service.serviceImpl;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.annotation.Resource;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgbatc.lgbatc00010.service.LGBATC00020Service;

import devonframe.mail.MailSender;
import devonframe.mail.MailSenderFactory;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00010.controller.LGSETC00010Controller.java
 * </PRE>
 * @param <LGBATC00010ServiceImpl>
 *
 * @Author    이종훈
 * @Date      2019. 09. 21. 오전 9:00:58
 * @Version
 */
@Service(value="LGBATC00020Service")
public class LGBATC00020ServiceImpl implements LGBATC00020Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGBATC00020ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Value("common_directory_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
	private String commonDirectory = null;
	
	@Autowired 
	private MailSenderFactory mailSenderFactory;
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return processMailData(param);
	}

	@Override
	public LGCOMData processMailData(LGCOMData param) {
		
		//메일 데이터 테이블에서 정보를 읽어서 Template 를 적용하고 그SMTP를 호출한다. 
		List<LGCOMData> list = commonDao.selectList("Mail.retrieveMailInfo");
		String subjectText = "";
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull( list )  ) {
			
			//LOGGER.debug("*****메일 데이터 ******"); 
			//LOGGER.debug(item);
			
			String converted = "";
			List<String> fileNames = new ArrayList<String>();
			item.set("status", "N");
			
			if( item.getString("fileName") != null ) {
				LGCOMData parameter = new LGCOMData();
				parameter.set("fileGroupId", item.getString("fileName") );
				List<LGCOMData> files = commonDao.selectList("Common.retrieveAttachFileInfoByGroup", parameter );
				for( LGCOMData fileInfo : LGCOMUtils.emptyIfNull(files) ) {
					File original = new File( LGCOMUtils.getValueFromProjectProperties(commonDirectory) + "/" + LGCOMUtils.getFilePath( fileInfo.getString("fileLocationInfo") ) );
					File attachment = new File( LGCOMUtils.getValueFromProjectProperties(commonDirectory) + "/_temp/" +  fileInfo.getString("fileName")  );
					attachment.getParentFile().mkdirs();
					LOGGER.debug(original.getAbsolutePath());
					LOGGER.debug(attachment.getAbsolutePath());
					try {
						FileUtils.copyFile(original, attachment);
						fileNames.add(attachment.getAbsolutePath() );
					} catch (IOException e) {
						e.printStackTrace();
						item.set("errorReasonDesc", e.getMessage() );
						item.set("status", "E"); // ERROR
					} finally{
						commonDao.update( "Mail.updateMailInfo", item );
					}
				}
			}
			// 에러 
			if(!item.isNull(item.getString("status")) && item.getString("status").equals("E")){
				return null;
			}
			
			/* 메일 템플릿이 지정 돼 있지 않으면, 테이블에 있는 정보는 그대로 메일로 발송해야 한다. */
			if( !item.isNull("mailId") ) {
				String mailTextData = item.getString("mailClobData");
				LGCOMData mailData = new LGCOMData();
				if( mailTextData == null ) {
					mailTextData = "{}";
				}
				
				mailData = LGCOMData.parse( mailTextData );
				
				LGCOMData template = commonDao.select( "Mail.retrieveMailTemplate", item );
				String templateText = template.getString("mailDetailContent");
			    subjectText = template.getString("subjectText");
				
				/**** 내용 치환 부분 ***/
				try {
					Document document = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(new InputSource(new StringReader(templateText)));
					XPath xpath = XPathFactory.newInstance().newXPath();
					
					/**조건부 표시 영역 처리 시작 **/
					//데이터를 모두 풀어서 Map 을 생성해둔다. 
					LGCOMData arranged = new LGCOMData();
					arrangeData( arranged, mailData, "");

					//조건부 표시 영역에 대한 체크를 수행한다. 
					NodeList conditional = (NodeList) xpath.evaluate("//*[@data-condition]", document, XPathConstants.NODESET);
				    ScriptEngineManager mgr = new ScriptEngineManager();
				    ScriptEngine engine = mgr.getEngineByName("JavaScript");

					for (int inx = 0; inx < conditional.getLength(); inx++) {
			            Node condition = conditional.item(inx).getAttributes().getNamedItem("data-condition");
			            String conditionText = condition.getTextContent();
			            
			            Iterator<String> it = arranged.keySet().iterator();
			            while( it.hasNext() ){
			            	String key = it.next();
			            	String value = arranged.getString(key);
			            	
			            	if( !conditionText.contains( key ) ){
			            		continue;
			            	}
			            	
			            	String formuala = conditionText.replaceAll(  key  , "'" + value  + "'");
			            	boolean testResult = false;
			            	try{
			            		testResult = Boolean.parseBoolean( engine.eval(formuala) + "" );
			            	} catch(Exception e ) { }
			            	
			            	if( !testResult ) {
			            		conditional.item(inx).getParentNode().removeChild( conditional.item(inx) );
			            	}
			            }
					}
					/**조건부 표시 영역 처리 끝 **/		
		
					Iterator<String> it = mailData.keySet().iterator();
					while (it.hasNext()) {
						String key = it.next();
		
						if( mailData.get(key) instanceof LGCOMData ) {
							LGCOMData _item = (LGCOMData)mailData.get(key);
							
							Iterator<String> it2 = _item.keySet().iterator();
							while (it2.hasNext()) {
								String key2 = it2.next();
							    String value2 = _item.getString( key2 );
		
							    //태그 안쪽의 정보를 선택하는 경우 
							    NodeList nodeList = (NodeList) xpath.evaluate("//*[@data-template='"+key+"' and @data-type='record']//*[contains( text(), '" + key2 + "')]", document, XPathConstants.NODESET);
								for (int inx = 0; inx < nodeList.getLength(); inx++) {
									Node node = nodeList.item(inx);
									String newText = nodeList.item(inx).getTextContent().replaceAll( "\\[" + key2 + "\\]" , value2 );
									node.setTextContent( newText );
								}

								//속성의 정보를 가지고 있는 것을 선택하는 경우 
							    nodeList = (NodeList) xpath.evaluate("//*[@data-template='"+key+"' and @data-type='record']//attribute::*[contains(., '"+key2+"')]", document, XPathConstants.NODESET);
								for (int inx = 0; inx < nodeList.getLength(); inx++) {
									Node node = nodeList.item(inx);
									String newText = nodeList.item(inx).getTextContent().replaceAll( "\\[" + key2 + "\\]" , value2 );
									node.setTextContent( newText );
								}
								
							}
						} else if( mailData.get(key) instanceof List ){
							List<LGCOMData> itemList = (List<LGCOMData>)mailData.get(key);
							//System.out.println(list);
							Node templateItem = (Node) xpath.evaluate("//*[@data-template='"+key+"' and @data-type='list']" , document, XPathConstants.NODE );
							//System.out.println( templateItem.getParentNode().getNodeName() );
							Node clone = null;
							
							for( LGCOMData recored : itemList ) {
								clone = templateItem.cloneNode(true);
								templateItem.getParentNode().appendChild( clone );
								
								Iterator<String> it2 = recored.keySet().iterator();
								while( it2.hasNext() ) {
									String key2 = it2.next();
									String value2 = recored.getString(key2);
									
									NodeList tdList = clone.getChildNodes();
									for( int inx = 0 ; inx < tdList.getLength() ; inx++ ) {
										Node tdItem = tdList.item(inx);
										String newText = tdItem.getTextContent().replaceAll( "\\[" + key2 + "\\]" , value2 );
										tdItem.setTextContent( newText );
									}
								}
							}
							
							templateItem.getParentNode().removeChild( templateItem );
						}
					} 
					
					StringWriter writer = new StringWriter();
					Transformer xformer = TransformerFactory.newInstance().newTransformer();
					xformer.setOutputProperty(OutputKeys.INDENT, "yes");
					xformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");
					xformer.transform(new DOMSource(document), new StreamResult(writer));
					
					converted = writer.toString().replaceAll("\\<\\?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"\\?\\>", "");
				} catch( Exception e ) {
					item.set("errorReasonDesc", e.getMessage() );
					item.set("status", "E"); // ERROR
				} finally{
					commonDao.update( "Mail.updateMailInfo", item );
				}
				/**** 제목 치환 부분 ***/		
				subjectText = replaceWithData( subjectText, mailData.getData("subject") );
				item.set("mailClobContent", converted);
			} else {
				converted   = item.getString("mailClobContent");
				subjectText = item.getString("subjectContent");
			}
			
			item.set("subjectContent", subjectText);
			
			// 내용 치환 에러 
			if(!item.isNull(item.getString("status")) && item.getString("status").equals("E")){
				return null;
			}		
			
			//LOGGER.debug("*****메일 데이터 (보내기 직전) ******"); 
			//LOGGER.debug(item);			
			/* 메일 발송을 담당하는 부분 */
			try {
				MailSender mailSender = mailSenderFactory.createMailSender();
				mailSender.setFromMailAddress( item.getString("senderEmailAddr") );
				mailSender.setToMailAddress( item.getString("receiptEmailAddr") ); 
				mailSender.setSubject(subjectText);
				
				if( fileNames.size() > 0 ) {
					String [] arr = new String[fileNames.size()];
					fileNames.toArray( arr );
					mailSender.setHtmlAndFile(converted, arr);
				} else {
					mailSender.setHtml(converted);
				}

				mailSender.send();
				LOGGER.debug("***** 발송 ******"); 
				item.set("status", "C"); // Complete
				
			} catch( Exception e ) {
				e.printStackTrace();
				item.set("errorReasonDesc", e.getMessage() );
				item.set("status", "E"); // ERROR
			} finally {
				commonDao.update( "Mail.updateMailInfo", item ); 
			}
		}
		
		return null;
	}
	
	private String replaceWithData( String text, LGCOMData data ) {
		Iterator<String> it = data.keySet().iterator();
		while( it.hasNext() ) {
			String key = it.next();
			String value = data.getString(key);
			text = text.replaceAll( "\\[" + key + "\\]" , value );
			LOGGER.debug("key " + key );
			LOGGER.debug("value " + value );
			LOGGER.debug("text " + text );
		} 
		
		return text;
	}
	
	private void arrangeData(LGCOMData arranged, LGCOMData data, String rootKey) {
		Iterator<String> it = data.keySet().iterator();
		String newKey = "";
		while (it.hasNext()) {
			String key = it.next();
			Object value = data.get(key);
			if (value instanceof LGCOMData) {
				arrangeData(arranged, (LGCOMData) value, key);
			} else {
				if ("".equals(rootKey)) {
					arranged.set(key, value);
				} else {
					arranged.set(rootKey + "." + key, value);
				}
			}
		}
	}
}
