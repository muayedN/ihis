<%@include file="/includes/validateUser.jsp"%>
<%= sCSSNORMAL %>
<%= sJSPROTOTYPE %>
<%
	String sBegin = SH.p(request,"begin");
	String sEnd = SH.p(request,"end");
	if(sBegin.length()==0){
		sBegin=SH.getSQLDate(new java.util.Date(new java.util.Date().getTime()-SH.getTimeDay()*7));
	}
	if(sEnd.length()==0){
		sEnd=SH.getSQLDate(new java.util.Date());
	}
%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='10'><%=getTran(request,"web.manage","manageOpenCarenetTraffic",sWebLanguage) %></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","begindate",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDateField("begin", "transactionForm", sBegin, true, false, sWebLanguage, sCONTEXTPATH) %></td>
			<td class='admin'><%=getTran(request,"web","enddate",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDateField("end", "transactionForm", sEnd, true, false, sWebLanguage, sCONTEXTPATH) %></td>
			<td class='admin2' colspan='6'><input type='submit' name='submitButton' id='submitButton' class='button' value='<%=getTranNoLink("web","find",sWebLanguage)%>'/></td>
		</tr>
		<tr><td colspan='10'><hr/></td></tr>
		<tr class='admin'>
			<td><%=getTran(request,"web","id",sWebLanguage) %></td>
			<td><%=getTran(request,"web","datereceived",sWebLanguage) %></td>
			<td><%=getTran(request,"web","datesent",sWebLanguage) %></td>
			<td><%=getTran(request,"web","fromserver",sWebLanguage) %></td>
			<td><%=getTran(request,"web","fromip",sWebLanguage) %></td>
			<td><%=getTran(request,"web","toserver",sWebLanguage) %></td>
			<td><%=getTran(request,"web","toip",sWebLanguage) %></td>
			<td colspan='3'><%=getTran(request,"web","error",sWebLanguage) %></td>
		</tr>
		<%
			Hashtable servers = new Hashtable();
			Connection conn = SH.getStatsConnection();
			PreparedStatement ps = conn.prepareStatement("select * from ghb_servers");
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				servers.put(rs.getInt("ghb_server_id"),rs.getString("ghb_server_name"));
			}
			rs.close();
			ps.close();
			ps = conn.prepareStatement("select * from ghb_messages where ghb_message_receiveddatetime>=? and ghb_message_receiveddatetime<? order by ghb_message_receiveddatetime");
			ps.setDate(1,SH.toSQLDate(sBegin));
			ps.setDate(2,SH.toSQLDate(SH.parseDate(sEnd).getTime()+SH.getTimeDay()));
			rs = ps.executeQuery();
			while(rs.next()){
				out.println("<tr>");
				out.println("<td class='admin'>"+rs.getString("ghb_message_id")+"</td>");
				out.println("<td class='admin'>"+SH.formatDate(rs.getDate("ghb_message_receiveddatetime"),SH.fullDateFormatSS)+"</td>");
				out.println("<td class='admin'>"+SH.formatDate(rs.getDate("ghb_message_delivereddatetime"),SH.fullDateFormatSS)+"</td>");
				out.println("<td class='admin'>"+servers.get(rs.getInt("ghb_message_sourceserverid"))+"</td>");
				out.println("<td class='admin'>"+rs.getString("ghb_message_sourceip")+"</td>");
				out.println("<td class='admin'>"+servers.get(rs.getInt("ghb_message_targetserverid"))+"</td>");
				out.println("<td class='admin'>"+rs.getString("ghb_message_targetip")+"</td>");
				out.println("<td class='admin'>"+servers.get(SH.c(rs.getString("ghb_message_error")))+"</td>");
				out.println("</tr>");
			}
			rs.close();
			ps.close();
			conn.close();
		%>
	</table>
</form>