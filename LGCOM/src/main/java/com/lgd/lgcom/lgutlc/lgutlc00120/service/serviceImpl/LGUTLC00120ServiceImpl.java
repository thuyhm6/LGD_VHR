/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00120ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2016. 10. 27.  	forain  최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00120.service.serviceImpl;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;

import javax.annotation.Resource;
import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import javax.imageio.stream.MemoryCacheImageOutputStream;

import org.apache.commons.io.FileUtils;
import org.apache.poi.sl.usermodel.Slide;
import org.apache.poi.sl.usermodel.SlideShow;
import org.apache.poi.sl.usermodel.SlideShowFactory;
import org.aspectj.util.FileUtil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00120.service.LGUTLC00120Service;

import devonframe.util.NullUtil;
import devonframe.util.StringUtil;


/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00120.service.serviceImpl.LGUTLC00120ServiceImpl.java
 * </PRE>
 *
 * @Author    forain
 * @Date	   2016. 10. 27. 오전 9:03:23
 * @Version
 */
@Service("LGUTLC00120Service")
public class LGUTLC00120ServiceImpl implements LGUTLC00120Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00120ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	@Value("common_directory_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
	String repositoryPath = null;

	@Value("downloadURL_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
	String downloadUrl = null;

	@Value("manual_convert_flag")
	String manualConvertFlag = null;

	@Value("manual_path_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
	String manualPath = null;

	/**
	 * Desc : Menu Tree 목록 조회
	 * @Method Name : retrieveMenuTreeList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMenuTreeList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00120.retrieveMenuTreeList", param);
	}

	/**
	 * Desc : Menu에 구성된 Manual 정보 조회
	 * @Method Name : retrieveMenuManualData
	 * @param  param
	 * @return LGCOMData
	 * @throws IOException
	 * @throws SQLException
	 */
	public LGCOMData retrieveMenuManualData(LGCOMData param) throws SQLException, IOException {
		LOGGER.debug("param = " + param);
		/* Manual 정보 조회 */
		LGCOMData detail = this.commonDao.select("LGUTLC00120.retrieveMenuManualData", param);
		if(detail != null) {
			/* CLOB 변환 */
			Object obj = detail.get("manualContent");
			if(obj != null) {
				if(obj instanceof java.sql.Clob) {
					String content = LGCOMUtils.clobToString((java.sql.Clob)obj);
					// Executable Img 처리
					content = LGCOMUtils.removeExecutableImgTag(content);
					// XSS 처리
					content = LGCOMUtils.xssFilter(content);
					// Style 태그 제거
					content = content.replaceAll("<style[^>]*>(.*?)\\<\\/style>","");
					// IMG src 속성 경로 치환
					content = LGCOMUtils.getReplaceImageString(content);
					detail.set("manualContent", content);
				}
			}
		}
		return detail;
	}

	/**
	 * Desc : Manual 정보 저장
	 * @Method Name : saveManualData
	 * @param  param
	 * @return LGCOMData
	 */
	public void saveManualData(LGCOMData param) {
		/* Manual 정보가 있다면 */
		if(!NullUtil.isNone(param.getString("manualContent"))) {
			param.set("manualContent",LGCOMUtils.decodeReplaceString(param.getString("manualContent")));
		}
		LOGGER.debug("param = " + param);
		/* PPT 파일 변환 여부가 Y이면 */
		LOGGER.debug("manualConvertFlag = " + manualConvertFlag);
		if("Y".equals(LGCOMUtils.getValueFromProjectProperties(manualConvertFlag))) {
			/* 첨부된 파일이 존재하면 */
			if(param.containsKey("manualAttachFileId") && !NullUtil.isNone(param.getString("manualAttachFileId"))) {
				/* PPT 또는 PPTX 파일을 Parsing해서 이미지 파일로 저장한다. */
				new Thread(new ExportImage(this.commonDao,param,this.repositoryPath,this.downloadUrl,this.manualPath)).start();
			}
		}
		this.commonDao.update("LGUTLC00120.saveManualData",param);
	}

	/**
	 * Desc : Manual 정보 삭제
	 * @Method Name : deleteManualData
	 * @param  param
	 * @return LGCOMData
	 * @throws IOException
	 * @throws SQLException
	 */
	public void deleteManualData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		this.commonDao.update("LGUTLC00120.deleteManualData",param);
	}

	/**
	 * Desc : Manual 첨부파일 삭제
	 * @Method Name : deleteManualAttachFile
	 * @param  param
	 * @return LGCOMData
	 */
	public void deleteManualAttachFile(LGCOMData param) {
		LOGGER.debug("param = " + param);
		// 기생성된 메뉴얼 파일을 삭제한다.
		String exportPath = LGCOMUtils.getValueFromProjectProperties(manualPath);
		String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU").toLowerCase();
		String manualPath = exportPath + systemCode + "/" + param.getString("manualProgramId") + "/" + param.getString("manualLanguageCode");
		LOGGER.debug("manualPath = " + manualPath);
		try {
			FileUtils.deleteDirectory(new File(manualPath));
		} catch(IOException ie) {
		    LOGGER.error(ie.getMessage(),ie);
		}
		// 첨부파일정보 삭제
		this.commonDao.delete("LGSYSC00210.deleteAttachFileInfo",param);
		this.commonDao.update("LGUTLC00120.updateManualAttachFileId",param);
	}

	/**
	 * Desc : Manual 정보 조회
	 * @Method Name : retrieveMenuManualViewData
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMenuManualViewData(LGCOMData param) throws SQLException, IOException {
		LOGGER.debug("param = " + param);
		/* Manual 정보 조회 */
		List<LGCOMData> manualList = this.commonDao.selectList("LGUTLC00120.retrieveMenuManualViewData", param);
		List<LGCOMData> resultList = LGCOMData.createList();
		
		if(manualList != null && manualList.size() > 0) {
			for( LGCOMData detail: LGCOMUtils.emptyIfNull(manualList) ) {
				StringBuffer buffer = new StringBuffer();
				/* PPT 파일 convert 여부가 Y일 경우에만 */
				if("Y".equals(LGCOMUtils.getValueFromProjectProperties(manualConvertFlag))) {
					/* 첨부파일이 있다면 파일 컨텐츠를 생성한다. */
					if(!NullUtil.isNone(detail.getString("attachFileId"))) {
					    String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCode").toLowerCase();
						String manualPath = LGCOMUtils.getValueFromProjectProperties(this.manualPath) + systemCode + "/" + param.getString("manualProgramId") + "/" + param.getString("manualLanguageCode");
						String manualUrl = "/" + systemCode + "/manual/" + systemCode + "/" + param.getString("manualProgramId") + "/" + param.getString("manualLanguageCode");
						LOGGER.debug("manualPath = " + manualPath);
						LOGGER.debug("manualUrl = " + manualUrl);
						String[] manualFiles = FileUtil.listFiles(new File(manualPath));
						for(int i=0; i < manualFiles.length; i++) {
							if(i > 0) {
								buffer.append("<br/>");
							}
							buffer.append("<img src=\""+manualUrl+"/"+manualFiles[i]+"\" border=\"0\" style=\"width:100%;margin-bottom:5px;\"/>");
						}
					}
					buffer.append("<hr/>");
				}
				/* CLOB 변환 */
				Object obj = detail.get("manualContent");
				if(obj != null) {
					if(obj instanceof java.sql.Clob) {
						String content = LGCOMUtils.clobToString((java.sql.Clob)obj);
						// Executable Img 처리
						content = LGCOMUtils.removeExecutableImgTag(content);
						// XSS 처리
						content = LGCOMUtils.xssFilter(content);
						// Style 태그 제거
						content = content.replaceAll("<style[^>]*>(.*?)\\<\\/style>","");
						// IMG src 속성 경로 치환
						content = LGCOMUtils.getReplaceImageString(content);
						buffer.append(content);
					}
				}
				detail.set("manualContent",buffer.toString());
				resultList.add(detail);
			}
		}
		return resultList;
	}

	/**
	 * Desc : Manual 편집 모드로 이동
	 * @Method Name : retrieveManualModify
	 * @param  param
	 */
	public void retrieveManualModify(LGCOMData param) {
		LOGGER.debug("param = " + param);
	}

	/**
	 * <PRE>
	 * com.lgd.lgcom.lgutlc.lgutlc00205.service.serviceImpl.LGUTLC00205ServiceImpl.ExportImage.java
	 * PPT 또는 PPTX 파일을 읽어서 Image 파일로 Export 하는 Thread
	 * </PRE>
	 *
	 * @Author    forain
	 * @Date	   2016. 11. 4. 오후 5:06:52
	 * @Version
	 */
	class ExportImage implements Runnable {
		CommonDao dao;
		LGCOMData param;

		String repositoryDir;
		String downloadUrl;
		String exportPath;
		String manualPath;
		String systemCode;

		/**
		 * Constructor
		 */
		public ExportImage(CommonDao dao, LGCOMData args, String filePath, String downloadurl, String manualPath) {
			this.dao = dao;
			this.param = args;
			this.repositoryDir = LGCOMUtils.getValueFromProjectProperties(filePath);
			this.downloadUrl = LGCOMUtils.getValueFromProjectProperties(downloadurl);
			this.exportPath = LGCOMUtils.getValueFromProjectProperties(manualPath);
			this.systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU");
		}

		/**
		 * @see java.lang.Runnable#run()
		 */
		@Override
		public void run() {
			LOGGER.debug("start convert ppt to png files.");
			// 주어진 첨부파일 아이디로 실제 파일을 Access 한다.
			LGCOMData fileParam = new LGCOMData();
			fileParam.set("downloadURL",this.downloadUrl);
			fileParam.set("reqNumber",this.param.getString("manualAttachFileId"));
			List<LGCOMData> attachFiles = this.dao.selectList("LGSYSC00210.selectAttachmentListByReqNumber",fileParam);
			File menualFile;
			// 메뉴얼 파일을 생성할 경로를 생성한다.
			this.manualPath = this.exportPath + this.systemCode.toLowerCase() + "/" + this.param.getString("manualProgramId") + "/" + this.param.getString("manualLanguageCode");
			LOGGER.debug("manualPath = " + this.manualPath);
			// 기존경로를 삭제후 재생성한다.
			try {
				File dirFile = new File(manualPath);
				if(dirFile.exists() && dirFile.isDirectory()) {
					FileUtils.forceDelete(dirFile);
				}
				FileUtils.forceMkdir(dirFile);
			} catch(IOException ie1) {
				ie1.printStackTrace();
			}

			for(LGCOMData fileItem: LGCOMUtils.emptyIfNull(attachFiles) ) {
				menualFile = new File(this.repositoryDir + this.systemCode + "/" + fileItem.getString("fileId"));
				LOGGER.debug("menualFile = " + menualFile.getAbsolutePath());
				try {
					this.generatePngImageFile(menualFile);
				} catch(IOException ie2) {
					ie2.printStackTrace();
				}
			}
			LOGGER.debug("completed convert ppt to png files.");
		}

		/**
		 * Desc : PPT 파일을 받아 이미지 파일로 생성한다.
		 * @Method Name : generatePngImageFile
		 * @param pptFile
		 * @throws IOException
		 */
		private synchronized void generatePngImageFile(File pptFile) throws IOException {
			String imageExt = "jpg";
			FileInputStream fis = new FileInputStream(pptFile);
			SlideShow<?,?> ppt = SlideShowFactory.create(fis);
			//ppt.setPageSize(new Dimension(1040,720));
			fis.close();
			Dimension pgsize = ppt.getPageSize();
			List<? extends Slide<?,?>> slideList = (List<? extends Slide<?,?>>)ppt.getSlides();
			int inx = 1;
			// 설정에 맞는 writer를 찾기 위해 enumerate를 해야 합니다.
			Iterator<ImageWriter> iter = ImageIO.getImageWritersByFormatName(imageExt);
			// image writer를 고르고(특별히 원하는 writer가 없다면)
			ImageWriter writer = (ImageWriter)iter.next();
			ImageWriteParam iwp = writer.getDefaultWriteParam();
			iwp.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
			iwp.setCompressionQuality(1);   // an integer between 0 and 1

			for(Slide<?,?> slide: slideList) {
				BufferedImage img = new BufferedImage(pgsize.width, pgsize.height,BufferedImage.TYPE_INT_RGB);
				Graphics2D graphics = img.createGraphics();
				// default rendering options
				graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING,RenderingHints.VALUE_ANTIALIAS_ON);
				graphics.setRenderingHint(RenderingHints.KEY_RENDERING,RenderingHints.VALUE_RENDER_QUALITY);
				//graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION,RenderingHints.VALUE_INTERPOLATION_BICUBIC);
				graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION,RenderingHints.VALUE_INTERPOLATION_BILINEAR);
				graphics.setRenderingHint(RenderingHints.KEY_FRACTIONALMETRICS,RenderingHints.VALUE_FRACTIONALMETRICS_ON);
				//clear the drawing area
				graphics.setColor(Color.white);
				graphics.clearRect(0,0,pgsize.width,pgsize.height);
				//graphics.fillRect(0,0,pgsize.width, pgsize.height);
				graphics.fill(new Rectangle2D.Float(0,0,pgsize.width, pgsize.height));
				graphics.drawImage(img, 0, 0, null);
				//render
				slide.draw(graphics);
				graphics.dispose();
				// 메뉴얼 파일명
				String manualName = this.param.getString("manualProgramId") + "_" + StringUtil.leftPad(inx+"",(byte)0x30,3) + "." + imageExt;
				LOGGER.debug("manualName = " + manualName);
				//creating an image file as output
				FileOutputStream out = new FileOutputStream(new File(this.manualPath,manualName));
				ImageOutputStream ios = new MemoryCacheImageOutputStream(out);
				/* 이미지를 쓴다. */
				writer.setOutput(ios);
				IIOImage image = new IIOImage(img, null, null);
				writer.write(null, image, iwp);
				out.close();
				ios.close();
				inx++;
			}
			ppt.close();
		}
	}
}
