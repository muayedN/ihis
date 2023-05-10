<%@page import="java.text.*"%>
<%@include file="/includes/helper.jsp"%>
<%@page import="be.mxs.common.util.system.*,java.nio.file.*,java.nio.file.attribute.*"%>

<table width='100%'>
<%!
	public static String humanReadableByteCountBin(long bytes) {
	    long absB = bytes == Long.MIN_VALUE ? Long.MAX_VALUE : Math.abs(bytes);
	    if (absB < 1024) {
	        return bytes + " B";
	    }
	    long value = absB;
	    CharacterIterator ci = new StringCharacterIterator("KMGTPE");
	    for (int i = 40; i >= 0 && absB > 0xfffccccccccccccL >> i; i -= 10) {
	        value >>= 10;
	        ci.next();
	    }
	    value *= Long.signum(bytes);
	    return String.format("%.1f %ciB", value / 1024.0, ci.current());
	}
%>
<%
	SortedMap map = new TreeMap();
	File[] files = new File(SH.p(request,"folder")).listFiles();
	String sProject =SH.p(request,"project");
	for(int n=0;n<files.length;n++){
		File file = files[n];
		if(file.getName().startsWith(".")){
			continue;
		}
		Path path = file.toPath();
		BasicFileAttributes fatr = Files.readAttributes(path,BasicFileAttributes.class);
		String s = 	"<tr>"+
					"<td class='admin' width='1%' nowrap>"+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(fatr.creationTime().toMillis())+"&nbsp;</td>"+
					"<td class='admin2'><a style='font-size: 12px' href='"+SH.cs("backupFilesURL","http://localhost/openclinic/backup/files/")+sProject+"/"+file.getName()+"'>"+file.getName()+"</a></td>"+
					"<td class='admin2'>"+humanReadableByteCountBin(fatr.size())+"</td>"+
					"<td class='admin2'>"+(file.getName().toLowerCase().contains("inc")?"Incremental backup":"<font style='font-size: 12px;font-weight: bolder;color: red'>Full backup</font>")+"</td>"+
					"</tr>";
		map.put(-fatr.creationTime().toMillis(), s);
	}
	Iterator i = map.keySet().iterator();
	while(i.hasNext()){
		out.print(map.get(i.next()));
	}

%>
</table>