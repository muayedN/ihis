<%@include file="/includes/helper.jsp"%>
<%@page import="be.mxs.common.util.system.*"%>
<%= sCSSNORMAL %>
<%= sJSPROTOTYPE %>
<%
	if(request.getParameter("submitButton")!=null && SH.c(request.getParameter("accesskey")).length()>0){
		session.removeAttribute("accesskey");
		if(SH.cs("backupuser."+request.getParameter("accesskey"),"").length()>0){
			session.setAttribute("accesskey",request.getParameter("accesskey"));
		}
	}
	String accesskey = SH.c((String)session.getAttribute("accesskey"));
	String site = SH.p(request,"site");
	String sBackupFolder = (SH.cs("backupFolder","/tmp/")+"/").replaceAll("//", "/");

	if(accesskey.length()==0){
%>
		<form name='transactionForm' method='post'>
			<br/><br/><br/><br/><br/><br/><center><img width='150px' src='<%=sCONTEXTPATH%>/_img/openclinic_logo.jpg'/></center><br/>
			<center>Access key: <input type='password' class='text' name='accesskey' value=''/> <input type='submit' name='submitButton' value='Login'/></center>
		</form>
<%		
	}
	else{
		String[] sFolders = SH.cs("backupuser."+request.getParameter("accesskey"),"").split(",");
		%>
		<form name='transactionForm' method='post'>
			<br/><br/><center><img width='150px' src='<%=sCONTEXTPATH%>/_img/openclinic_logo.jpg'/></center><br/>
			<table width='100%'>
				<tr class='admin'>
					<td>
						Backup repository:&nbsp;&nbsp;&nbsp;
						<select class='text' name='site' id='site' onchange='loadfiles()'>
							<%
								for(int n=0;n<sFolders.length;n++){
									out.println("<option value='"+sFolders[n].split(":")[0].trim()+"'>"+sFolders[n].split(":")[1].trim()+"</option>");
								}
							%>
						</select>
					</td>
				</tr>
			</table>
			<div id='filelist' name='filelist'/>
		</form>
		<%
	}
%>
<script>
	function loadfiles(){
	    var url = '<c:url value="/backup/loadfiles.jsp"/>'+
	              '?folder=<%=sBackupFolder%>'+document.getElementById("site").value+
	              '&ts='+new Date().getTime()+
	              '&project='+document.getElementById("site").value;
	    new Ajax.Request(url,{
	      parameters: "",
	      onSuccess: function(resp){
	        document.getElementById("filelist").innerHTML = resp.responseText;
	      }
	    });
	  }
	
	loadfiles();
</script>