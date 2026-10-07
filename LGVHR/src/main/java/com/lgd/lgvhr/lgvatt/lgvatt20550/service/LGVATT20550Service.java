package com.lgd.lgvhr.lgvatt.lgvatt20550.service;

import java.util.List;

import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.model.LGCOMData;
/**
 * @author HMS - HMS_20210703
 * Request for swap weekly holiday
 *
 */
public interface LGVATT20550Service {
	/**
	 * Swap holiday 요청 리스트 조회
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveSwapRequestList(LGCOMData param) throws LGCOMException;
}
