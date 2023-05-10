package be.mxs.common.util.io;

import java.lang.management.ManagementFactory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Pointer;
import be.openclinic.system.SH;
import uk.org.primrose.vendor.standalone.PrimroseLoader;

public class SendInvoicesToOBR {

	public static void main(String[] args) throws SQLException {
		//Préparation des paramètres pour se connecter aux bases de données
		String processid=ManagementFactory.getRuntimeMXBean().getName();
		System.out.println(processid+" - Loading primrose configuration "+args[0]);
		try {
			PrimroseLoader.load(args[0], true);
			System.out.println(processid+" - Primrose loaded");
		}
		catch(Exception e) {
			System.out.println(processid+" - Error - Closing system");
			System.exit(0);
		}
		try {
			MedwanQuery.getInstance(false);
			System.out.println(processid+" - MedwanQuery loaded");
		}
		catch(Exception e) {
			System.out.println(processid+" - Error - Closing system");
			System.exit(0);
		}

		Connection conn = SH.getOpenClinicConnection();
		PreparedStatement ps = conn.prepareStatement("select * from oc_patientinvoices where oc_patientinvoice_status='closed' and not exists (select * from oc_pointers where oc_pointer_key='OBR.INV.'||oc_patientinvoice_serverid||'.'||oc_patientinvoice_objectid)");
		ResultSet rs = ps.executeQuery();
		while(rs.next()) {
			String uid = rs.getString("oc_patientinvoice_serverid")+"."+rs.getString("oc_patientinvoice_objectid");
			if(OBR.addPatientInvoice(uid, false)) {
				System.out.println("Facture "+uid+" ajoutée à l'OBR avec succès");
				Pointer.storePointer("OBR.INV."+uid, "");
			}
			else {
				System.out.println("Facture "+uid+" pas ajoutée à l'OBR");
			}

		}
		System.exit(0);
	}

}
