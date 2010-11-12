package com.sira;

//Imports
import java.sql.*;



/**
 *
 * Class for database access.
 * 
 * @author	mhs.
 * @version	1.
 * 
 */
public class MyDBAccess
{
	//Fields
	private static String dbUser;
	private static String dbPasswd;
	private static String dbHost;
	private static String dbPort;
	private static String dbName;
	private static String dbDriver;
	private static String dbConnectString;
	private static String dbUrl;
	private static Connection con;
	private static Statement stmt;
	private static PreparedStatement preStmt;
	private static ResultSet rs;
	
	//Methods
	/**
	 * 
	 * Constructor
	 *
	 * @param		String dbU, String dbP, String dbH, String dbPo, String dbN.
	 * @exception	no.
	 * 
	 */
	public MyDBAccess(String dbU, String dbP, String dbH, String dbPo, String dbN)
	{
		dbUser = dbU;
		dbPasswd = dbP;
		dbHost = dbH;
		dbPort = dbPo;
		dbName = dbN;
		dbDriver = "oracle.jdbc.driver.OracleDriver";
		dbConnectString = dbHost + ":" + dbPort + ":" + dbName;
		dbUrl = "jdbc:oracle:thin:@" + dbConnectString;
		try {
		    //DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());	    	   
		    Class driverClass = Class.forName(dbDriver);
		    con = DriverManager.getConnection(dbUrl, dbUser, dbPasswd);
		}
		catch (Exception e) {
		    e.printStackTrace();
		}
	}
	

    public String getHtmlSelectAllg(String iName,String iSql,String iOption) {

	Statement stmt;
	ResultSet rs;
	ResultSetMetaData  rsmd;
	String retString = new String();
	
	retString = "\n<SELECT NAME=\"" + iName + "\">";
	retString += iOption;
	try {
	    stmt = con.createStatement();
	    stmt.executeQuery(iSql);
	    rs = stmt.getResultSet();
	    rsmd = rs.getMetaData();
	    while (rs.next()) {
		// Der Wert des Auswahlfeldes wird durch das Letzte Feld des Selektierten Datensatzes bestimmt
		retString += "\n<OPTION VALUE=\"" + rs.getString(rsmd.getColumnCount()) +"\">";
		// Alle Felder bis auf das Letzte werden im Auswahlfeld angezeigt...
		for  (int lauf=1;lauf<rsmd.getColumnCount();lauf++) {
		    retString += rs.getString(lauf) + " ";
		}
	    }
	    rs.close();
	    stmt.close();
	}
	catch (SQLException sqlEx) {
	    sqlEx.printStackTrace();
	    retString += "<OPTION> Methode getHtmlSelectAllg: Fehler beim Datenbankzugriff";
	}	
	retString += "</SELECT>\n";
	return retString;
    }

 public String getHtmlSelectSpezial(String iName,String iSql,String iOption) {

	Statement stmt;
	ResultSet rs;
	ResultSetMetaData  rsmd;
	String retString = new String();
	String mat = "";
	
	retString = "\n<SELECT NAME=\"" + iName + "\">";
	retString += iOption;
	try {
	    stmt = con.createStatement();
	    stmt.executeQuery(iSql);
	    rs = stmt.getResultSet();
	    rsmd = rs.getMetaData();
	    while (rs.next()) {
		// Der Wert des Auswahlfeldes wird durch das Letzte Feld des Selektierten Datensatzes bestimmt
		mat = rs.getString(1);
		retString += "\n<OPTION VALUE=\""+mat+"-" + rs.getString(rsmd.getColumnCount()) +"\">";
		// Alle Felder bis auf das Letzte werden im Auswahlfeld angezeigt...
		for  (int lauf=1;lauf<rsmd.getColumnCount();lauf++) {
		    retString += rs.getString(lauf) + " ";
		}
	    }
	    rs.close();
	    stmt.close();
	}
	catch (SQLException sqlEx) {
	    sqlEx.printStackTrace();
	    retString += "<OPTION> Methode getHtmlSelectAllg: Fehler beim Datenbankzugriff";
	}	
	retString += "</SELECT>\n";
	return retString;
    }

    
	/**
	 * 
	 * Method openConnection: starts a connection to database.
	 * 
	 * @param		no.
	 * @return		void.
	 * @exception	no.
	 * 
	 */
    public void openConnection()
    {
	//Comment out, if JNDI database connection is used
	try
	    {
		Class driverClass = Class.forName(dbDriver);
	    }
	catch(Exception e)
	    {
		System.out.println("Exception in openConnection (Driver not found)!\n" +
				   e.toString());
	    }
	try
	    {
		con = DriverManager.getConnection(dbUrl, dbUser, dbPasswd);
	    }
	catch(Exception e)
	    {
		System.out.println("Exception in openConnection (Could not connect)!\n" +
				   e.toString());
	    }
    }
    
    public Connection getConnection() {
	return con;
    }
    
         /**
	 * 
	 * Method setAutoCommitOff:sets auto commit off.
	 * 
	 * @param		no.
	 * @return		void.
	 * @exception	no.
	 * 
	 */
	public void setAutoCommitOff()
	{
		try
		{
			con.setAutoCommit(false);
		}
		catch(Exception e)
		{
			System.out.println("Exception in setAutoCommitOff!\n" +
			e.toString());
		}
	}
	
	/**
	 * 
	 * Method setAutoCommitOn: sets auto commit on.
	 * 
	 * @param		no.
	 * @return		void.
	 * @exception	no.
	 * 
	 */
	public void setAutoCommitOn()
	{
		try
		{
			con.setAutoCommit(true);
		}
		catch(Exception e)
		{
			System.out.println("Exception in setAutoCommitOn!\n" +
			e.toString());
		}
	}
	
	/**
	 * 
	 * Method setCommit: set commit on data changes of connection.
	 * 
	 * @param		no.
	 * @return		void.
	 * @exception	no.
	 * 
	 */
	public void setCommit()
	{
		try
		{
			con.commit();
		}
		catch(Exception e)
		{
			System.out.println("Exception in setCommit!\n" +
			e.toString());
		}
	}
	
	/**
	 * 
	 * Method setRollback: set rollback on data changes of connection.
	 * 
	 * @param		no.
	 * @return		void.
	 * @exception	no.
	 * 
	 */
	public void setRollback()
	{
		try
		{
			con.rollback();
		}
		catch(Exception e)
		{
			System.out.println("Exception in setRollback!\n" +
			e.toString());
		}
	}
	
	/**
	 * 
	 * Method closeConnection: close the connection to database.
	 * 
	 * @param		Connection conn.
	 * @return		void.
	 * @exception	no.
	 * 
	 */
	public void closeConnection(Connection conn)
	{
		try
		{
			if(conn!=null)
			{
				conn.close();
			}
		}
		catch(Exception e)
		{
			System.out.println("Error in close connection!\n" + e.toString());
		}
	}
	
	/**
	 *
	 * Method closeConnection: close the connection to database.
	 *
	 * @param		no.
	 * @return		void.
	 * @exception	no.
	 *
	 */
	public void closeConnection()
	{
		try
		{
			if(con!=null)
			{
				con.close();
			}
		}
		catch(Exception e)
		{
			System.out.println("Error in close connection!\n" + e.toString());
		}
	}
	
	/**
	 * 
	 * Method closeDBResources: closing statements, resultsets and
	 * database connections.
	 * 
	 * @param		Connection conn, PreparedStatement ps, ResultSet rs.
	 * @return		void.
	 * @exception	no.
	 * 
	 */
	public void closeDBResources(Connection conn, PreparedStatement ps, ResultSet rs)
	{
		// Close result set, if any
		try
		{
			if (rs!=null)
			{
				rs.close();
			}
		}
		catch(Exception e)
		{
			System.out.println("Error closing result set!\n" + e.toString());
		}
		// Close perpared statement, if any
		try
		{
			if (ps!=null)
			{
				ps.close();
			}
		}
		catch(Exception e)
		{
			System.out.println("Error closing result set!\n" + e.toString());
		}
		// Close connection, if any
		closeConnection(conn);
	}
	
	/**
	 *
	 * Method closeDBResources: closing statements, resultsets and
	 * database connections.
	 *
	 * @param		PreparedStatement ps, ResultSet rs.
	 * @return		void.
	 * @exception	no.
	 *
	 */
	public void closeDBResources(PreparedStatement ps, ResultSet rs)
	{
		// Close result set, if any
		try
		{
			if (rs!=null)
			{
				rs.close();
			}
		}
		catch(Exception e)
		{
			System.out.println("Error closing result set!\n" + e.toString());
		}
		// Close perpared statement, if any
		try
		{
			if (ps!=null)
			{
				ps.close();
			}
		}
		catch(Exception e)
		{
			System.out.println("Error closing result set!\n" + e.toString());
		}
		// Close connection, if any
		closeConnection();
	}
	
	/**
	 * 
	 * Method prepareStatement: prepares the statement.
	 * 
	 * @param		String statement.
	 * @return		PreparedStatement.
	 * @exception	no.
	 * 
	 */
	public PreparedStatement prepareStatement(String statement)
	{
		preStmt = null;
		try
		{
			preStmt = con.prepareStatement(statement);
		}
		catch(Exception e)
		{
			System.out.println("Error preparing Statement\n! "+
			e.toString());
		}
		return preStmt;
	}
       	
	/**
	 * 
	 * Method prepareChangeStatement: executes statement and returns
	 * the number of rows, which are attached by this statement.
	 * 
	 * @param		Prepared Statement p.
	 * @return		int.
	 * @exception	no.
	 * 
	 */
	public int preparedChangeStatement(PreparedStatement p)
	{
		int ChangedDataSets = 0;
		try
		{
			ChangedDataSets = p.executeUpdate();
		}
		catch(SQLException e)
		{
			System.out.println("Error in execution of perparedChangeStatement!\n" +
			e.toString());
		}
		return ChangedDataSets;
	}
	
	/**
	 * 
	 * Method prepareSelectStatement: executes select statement.
	 * 
	 * @param		Prepared Statement p.
	 * @return		ResultSet.
	 * @exception	no.
	 * 
	 */
	public ResultSet preparedSelectStatement(PreparedStatement p)
	{
		ResultSet rs=null;
		try
		{
			rs = p.executeQuery();
		}
		catch(Exception e)
		{
			System.out.println("Error in execution perpared select statement!\n"+
			e.toString());
		}
		return rs;
	}
		
}    //end class MyDBAccess