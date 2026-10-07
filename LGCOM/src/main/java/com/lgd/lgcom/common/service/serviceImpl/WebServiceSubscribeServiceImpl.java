/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : WebServiceSubscribeServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 25.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.service.serviceImpl;

import java.io.StringReader;
import java.util.List;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathFactory;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import com.google.common.base.CaseFormat;
import com.lgd.lgcom.common.service.WebServiceSubscribeService;
import com.lgd.lgcom.common.util.HttpUtil;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

/* <PRE>
 * com.lgd.lgcom.common.service.serviceImpl.ApprovalServiceImpl.java
 * </PRE>
 *
 * @Author jhpark23
 * @Date
 * @Version
 */
@Service("webServiceSubscribeService")
public class WebServiceSubscribeServiceImpl implements WebServiceSubscribeService {
	private static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(WebServiceSubscribeServiceImpl.class);
	
	@Value("discretionary_service_endpoint_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
	private String discretionaryServiceEndpoint = null;	
	
	public LGCOMData getDiscretionaryList( LGCOMData param ) {
		
		String payload = "<?xml version='1.0' encoding='UTF-8'?>" +
				"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\">"+
				"<soapenv:Body>"+
				"<ns1:InputParameters xmlns:ns1=\"http://xmlns.oracle.com/pcbpel/adapter/db/APPS/BPEL_PROCGPSAUTHORITY/XXAUTT_RETRIEVE_AUTH_MTRX_PK5/\">"+
				"<ns1:P_IN_REC>"+
				"<ns1:P_PGM_SEQ>" + param.getString("pgmSeq")+ "</ns1:P_PGM_SEQ>"+
				"<ns1:P_ORG_ID>" + param.getString("orgId")+ "</ns1:P_ORG_ID>"+
				"<ns1:P_REQUESTOR_USER_ID>" + param.getString("requestorUserId")+ "</ns1:P_REQUESTOR_USER_ID>"+
				"<ns1:P_REQUESTOR_EMP_NO>" + param.getString("requestorEmpNo")+ "</ns1:P_REQUESTOR_EMP_NO>"+
				"<ns1:P_ADDITIONAL_TYPE_CODE></ns1:P_ADDITIONAL_TYPE_CODE>"+
				"<ns1:P_ADDITIONAL_CODE></ns1:P_ADDITIONAL_CODE>"+
				"<ns1:P_RULE1_TYPE></ns1:P_RULE1_TYPE>"+
				"<ns1:P_RULE1_CODE></ns1:P_RULE1_CODE>"+
				"<ns1:P_RULE2_TYPE></ns1:P_RULE2_TYPE>"+
				"<ns1:P_RULE2_CODE></ns1:P_RULE2_CODE>"+
				"<ns1:P_RANGE_CODE>" + param.getString("rangeCode")+ "</ns1:P_RANGE_CODE>"+
				"<ns1:P_UOM_CODE>" + param.getString("uomCode")+ "</ns1:P_UOM_CODE>"+
				"<ns1:P_RANGE_VALUE>" + param.getLong("rangeValue")+ "</ns1:P_RANGE_VALUE>"+
				"</ns1:P_IN_REC>"+
				"</ns1:InputParameters>"+
				"</soapenv:Body></soapenv:Envelope>";
		
		LGCOMData headers = new LGCOMData();
		headers.set("METHOD", "POST");
		headers.set("Content-type", "text/xml; charset=UTF-8");
		headers.set("SOAPAction",  "\"process\"" );
		headers.set("User-Agent",  "Axis2" );
		headers.set("Transfer-Encoding",  "chunked" );
		
		String response = HttpUtil.send( LGCOMUtils.getValueFromProjectProperties(discretionaryServiceEndpoint), payload, headers);
		LGCOMData result = new LGCOMData();
		
		try {
			Document document = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse( new InputSource(new StringReader(response)) );
			XPath xpath = XPathFactory.newInstance().newXPath();
			
			//�뿉�윭 �빆紐⑹쓣 癒쇱� 泥댄겕�븿 
			Node errorItem = (Node)xpath.evaluate("//detail/error", document, XPathConstants.NODE);
			
			if( errorItem == null ) {
				NodeList nodeList = (NodeList)xpath.evaluate("//P_OUT_TBL/P_OUT_TBL_ITEM", document, XPathConstants.NODESET);
			
				List<LGCOMData> list = LGCOMData.createList();
				LGCOMData item = null;
				Node node = null;
				
				//�젅肄붾뱶 �닔留뚰겮 猷⑦봽 
				for( int idx=0; idx<nodeList.getLength(); idx++ ){
					item = new LGCOMData();
					node = nodeList.item(idx);
					
					NodeList elements = node.getChildNodes();
					//�젅肄붾뱶�쓽 而щ읆 �닔 留뚰겮 猷⑦봽
					for( int jdx=0; jdx<elements.getLength(); jdx++ ){
						Node element = elements.item(jdx);
						
						String name = CaseFormat.UPPER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, element.getNodeName().replaceAll("P_", ""));
						item.set( name , element.getTextContent() );
					}
					list.add(item);
		        }
				
				result.set("result", list );
				result.set("status", "SUCCESS" );
			} else {
				LGCOMData error = new LGCOMData();
				error.set("errorCode", errorItem.getFirstChild().getTextContent() );
				error.set("errorMsg", errorItem.getLastChild().getTextContent() );
				result.set("status", "ERROR" );
				result.set("error", error );
			}
			
		} catch (Exception e) {
			throw new LGCOMException(e);
		}

		return result;
	}
}
