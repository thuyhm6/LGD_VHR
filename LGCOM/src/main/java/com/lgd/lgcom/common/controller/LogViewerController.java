/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LogViewerController.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 2. 16.  	forain  	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.controller;

import java.io.FileNotFoundException;
import java.io.RandomAccessFile;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.google.gson.Gson;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.common.controller.LogViewerController.java
 * </PRE>
 *
 * @Author    forain
 * @Date	   2017. 2. 16. 오전 10:07:34
 * @Version
 */
@Controller
public class LogViewerController {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LogViewerController.class);

	@Value("#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
	String env = null;

	Gson gson = new Gson();

	/**
	 * Desc : 로그를 조회하는 화면 Open
	 * @Method Name : openLogViewer
	 * @return ModelAndView
	 * @throws Exception
	 */
	@RequestMapping(value="/logviewer")
	public ModelAndView openLogViewer() throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("common/logViewer");
		// 로그 구분 Combo 세팅
		List<LGCOMData> logTypeCombo = LGCOMData.createList();
		LGCOMData item =  new LGCOMData();
		
		if("local".equalsIgnoreCase(env)) {
			item.set("code",this.env+"|WAS||");
		} else {
			item.set("code",this.env+"|WAS|/logs001/juscom01/jeus7|JeusServer.log");
		}
		item.set("name","WAS");
		
		logTypeCombo.add(item);
		// SPRING
		item = new LGCOMData();
		if("local".equalsIgnoreCase(env)) {
			item.set("code",this.env+"|SPRING|C:/LGDWork/workspace/{systemCode}/logs|{systemCode}-webapp.log");
		} else {
			item.set("code",this.env+"|SPRING|/logs001/juscom01/spring/logs|{systemCode}-webapp.log");
		}
		item.set("name","SPRING");
		logTypeCombo.add(item);
		mav.addObject("logType", this.gson.toJson(logTypeCombo));
		return mav;
	}

	/**
	 * Desc : 로그 파일을 읽는다.
	 * @Method Name : readLogFile
	 * @param  logPath
	 * @param  systemCode
	 * @param  grepOptions
	 * @return String
	 */
	@RequestMapping(value="/logviewer/logtail",method=RequestMethod.POST)
	public @ResponseBody String readLogFile(@RequestParam(value="logPos", required=true)       String logPos     ,
	                                        @RequestParam(value="systemCode", required=true)   String systemCode ,
	                                        @RequestParam(value="grepOptions", required=false) String grepOptions,
	                                        @RequestParam(value="pEndPoint", required=false)   String pEndPoint  ) {
		LOGGER.debug("logPos      = " + logPos);
		LOGGER.debug("systemCode  = " + systemCode);
		LOGGER.debug("grepOptions = " + grepOptions);
		LOGGER.debug("pEndPoint   = " + pEndPoint);
		// 파일 경로 조합
		// [0] : local, dev, prod
		// [1] : Log Type
		// [2] : Log Path
		// [3] : Log File Name
		String[] losPositions = StringUtils.split(logPos,"|");
		long preEndPoint = (pEndPoint == null) ? 0 : Long.parseLong(pEndPoint + "");
		String fileName = null;
		LGCOMData result = new LGCOMData();
		
		if(losPositions.length == 4) {
			if("WAS".equalsIgnoreCase(losPositions[1])) {
				fileName = losPositions[2] + "/" + systemCode + "/" + losPositions[3];
			} else if("SPRING".equalsIgnoreCase(losPositions[1])) {
				String logFilePath = LGCOMUtils.nvl(losPositions[2]).replaceAll("(\\{systemCode\\})",systemCode.toUpperCase());
				String logFileName = LGCOMUtils.nvl(losPositions[3]).replaceAll("(\\{systemCode\\})",systemCode.toUpperCase());
				fileName = logFilePath + "/" + logFileName;
			}
			LOGGER.debug("fileName = " + fileName);

			StringBuilder logline = new StringBuilder();
			long startPoint = 0l;
			long endPoint = 0l;
			RandomAccessFile file = null;
			try {
				file = new RandomAccessFile(fileName, "r");
				endPoint = file.length();
				startPoint = (preEndPoint > 0) ? preEndPoint : 0l;
				file.seek(startPoint);

				String str;
				while((str = file.readLine()) != null) {
					logline.append(new String(str.getBytes("8859_1"),"UTF-8")).append("\n");
					endPoint = file.getFilePointer();
					file.seek(endPoint);
				}
				result.set("logCode", 0);
				result.set("logEndPoint",endPoint);
				result.set("logLine",logline.toString());
			} catch(FileNotFoundException fnfe) {
				logline.append("File does not exist.");
				fnfe.printStackTrace();
			} catch(Exception e) {
				logline.append("Sorry. An error has occurred.");
				e.printStackTrace();
			} finally {
				try {file.close();} catch(Exception e) {/*exception*/}
			}
		} else {
			result.set("logCode", -1);
			result.set("logMessage", "Invalid log path : " + losPositions[0]);
		}
		return this.gson.toJson(result);
	}
}
