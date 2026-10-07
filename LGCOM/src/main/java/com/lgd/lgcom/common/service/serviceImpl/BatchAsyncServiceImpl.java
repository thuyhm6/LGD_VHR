/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : BatchAsyncServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2016. 12. 16.  	박철우  	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.service.serviceImpl;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.service.BatchAsyncService;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.common.service.serviceImpl.BatchAsyncServiceImpl.java
 * </PRE>
 *
 * @Author    박철우
 * @Date	   2016. 12. 16. 오후 3:03:57
 * @Version
 */
@Service
public class BatchAsyncServiceImpl implements BatchAsyncService {
	private static LGCOMLogger logger = LGCOMLoggerFactory.getLogger(BatchAsyncServiceImpl.class);

	/**
	 * 시스템 구분(local,dev,prod)
	 */
	@Value("#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
	private String env = null;

	@Async
	public void executeBatchAsync(LGCOMData param) {
		logger.debug("param = " + param);
		String shell = ("local".equals(env)) ? "C:\\LGDWork\\workspace\\.metadata\\.plugins\\org.eclipse.wst.server.core\\tmp0\\wtpwebapps\\LGCOM\\WEB-INF\\classes\\batch_call.bat":"/sorc001/juscom01/LGCOM/war/WEB-INF/classes/batch_call.sh";
		String logFile = ("local".equals(env)) ? "C:\\LGDWork\\workspace\\LGCOM\\logs\\LGCOM-batch.log":"/sorc001/juscom01/LGCOM/war/WEB-INF/classes/bat.log";
		String arrParam = param.getString("vParam");
		logger.debug("shell = " + shell);
		logger.debug("logFile = " + logFile);
		logger.debug("arrParam = " + arrParam);

		InputStream inputStream = null;
		InputStream errorStream = null;
		BufferedReader stdOutReader = null;
		BufferedReader stdErrReader = null;
		String line = null;

		try {
			String[] exec = new String[3];
			if("local".equals(env)) {
				exec = new String[2];
				exec[0] = shell;
				exec[1] = arrParam;
				//exec[2] = " >> " + logFile;
			} else {
			    exec = new String[3];
				exec[0] = "/bin/sh";
				exec[1] = shell + " >> " + logFile + " 2>&1";
				exec[2] = arrParam;
			}
			final Process proc = Runtime.getRuntime().exec(exec);
			inputStream = proc.getInputStream();
			errorStream = proc.getErrorStream();
			stdOutReader = new BufferedReader(new InputStreamReader(inputStream));
			stdErrReader = new BufferedReader(new InputStreamReader(errorStream));
			while((line = stdOutReader.readLine()) != null) {
				logger.debug(line);
			}
			while((line = stdErrReader.readLine()) != null) {
				logger.debug(line);
			}
			proc.destroy();
		} catch(Exception e) {
			Throwable cause = e.getCause();
			if(cause == null) {
				throw new LGCOMException(e.getMessage(), e);
			} else {
				throw new LGCOMException(cause.getMessage(), cause);
			}
		} finally {
			try { if(stdOutReader!=null) {stdOutReader.close();} } catch(IOException e1){/*exception*/}
			try { if(stdErrReader!=null) {stdErrReader.close();} } catch (IOException e2) {/*exception*/}
			try { if(inputStream != null) {inputStream.close();} } catch(IOException e3){/*exception*/}
			try { if(errorStream != null) {errorStream.close();} } catch(IOException e4){/*exception*/}
		}
	}

	@Async
	public void executeBatchAsyncXmx(LGCOMData param) {
		String shell = "/sorc001/juscom01/LGCOM/war/WEB-INF/classes/batch_call_xmx.sh";
		String logFile = "/sorc001/juscom01/LGCOM/war/WEB-INF/classes/bat.log";
		String arrParam = param.getString("vParam");
		String strMemSize = param.getString("vMemSize");

		InputStream inputStream = null;
		BufferedReader bufferedReader = null;

		try {
			String[] exec = new String[4];
			exec[0] = "/bin/sh";
			exec[1] = shell + " >> " + logFile + " 2>&1";
			exec[2] = strMemSize + "G";
			exec[3] = arrParam;

			Process proc = Runtime.getRuntime().exec(exec);
			proc.getInputStream();
			inputStream = proc.getInputStream();
			bufferedReader = new BufferedReader(new InputStreamReader(inputStream));

			while(true) {
				String info = bufferedReader.readLine();
				if(info == null || "".equals(info)) {
					break;
				}
				logger.debug(info);
			}
			proc.destroy();

		} catch(Exception e) {
			Throwable cause = e.getCause();
			if(cause == null) {
				throw new LGCOMException(e.getMessage(),e);
			} else  {
				throw new LGCOMException(cause.getMessage(),cause);
			}
		} finally {
			try { if(inputStream != null) {inputStream.close();} } catch(Exception e){/*exception*/}
			try { if(bufferedReader!=null) {bufferedReader.close();} } catch(Exception e){/*exception*/}
		}
	}
}
