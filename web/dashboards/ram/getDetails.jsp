<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'>
		<td colspan='2'>D�tails m�moire RAM</td>
	</tr>
	<tr>
		<td class='admin'>M�moire RAM r�serv�e en MB</td>
		<td class='admin2'><%=Runtime.getRuntime().totalMemory()/(1024*1024) %></td>
	</tr>
	<tr>
		<td class='admin'>M�moire RAM maximale en MB</td>
		<td class='admin2'><%=Runtime.getRuntime().maxMemory()/(1024*1024) %></td>
	</tr>
	<tr>
		<td class='admin'>M�moire RAM utilis�e en MB</td>
		<td class='admin2'><%=(Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory())/(1024*1024) %></td>
	</tr>
	<tr>
		<td class='admin'>M�moire RAM libre en MB</td>
		<td class='admin2'><%=Runtime.getRuntime().freeMemory()/(1024*1024) %></td>
	</tr>
</table>