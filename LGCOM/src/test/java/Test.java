import java.util.Random;

import com.lgd.lgcom.framework.model.LGCOMData;

public class Test {
	public static void main(String[] args) {
		Test t = new Test();
		LGCOMData data = t.makeFileLocationInfo();
		System.out.println( data.toJson() );
	}
	
	
	
	
	private LGCOMData makeFileLocationInfo() {
		LGCOMData result = new LGCOMData();
		
		StringBuffer  path = new StringBuffer();
		StringBuffer  fileLocationInfo = new StringBuffer();
		
		Random rnd = new Random();
		char c = '\u0000';
		
		for (int i = 0; i < 15; i++) {
			c = (char) ((int) (rnd.nextInt(26)) + 97);
			
			if( i <= 3 ) {
				path.append( c + "/" );
			}
			
			if( i == 4 ) {
				fileLocationInfo.append("0");
			} else {
				fileLocationInfo.append( c );
			}
		}
		
		result.set("path", path.toString() );
		result.set("fileLocationInfo", fileLocationInfo.toString() );
		return result;
	}
}
