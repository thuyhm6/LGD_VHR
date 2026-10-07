package com.lgd.lgvhr.lgvatt.lgvatt30030.service;

import java.util.List;

import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.model.LGCOMData;

public interface LGVATT30030Service {

	/**
	 * OT Level 요청 리스트 조회
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveOtLevelRequestList(LGCOMData param) throws LGCOMException;

}
