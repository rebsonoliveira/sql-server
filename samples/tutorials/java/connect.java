// Use the JDBC driver
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;

public class connect {

	// Connect to your database.
	// Replace server name, username, and password with your credentials
	public static void main(String[] args) throws SQLException {
		String connectionString =
			"jdbc:<your_servername>;"
			+ "database=<your_databasename>;"
			+ "user=<your_username@your_servername>;"
			+ "password=<your_password>;"
			+ "encrypt=true;"
			+ "trustServerCertificate=false;"
			+ "loginTimeout=30;";

		try (Connection connection = DriverManager.getConnection(connectionString)) {

			// Create and execute a SELECT SQL statement.
			String selectSql = "SELECT TOP 10 Title, FirstName, LastName from SalesLT.Customer";
			try (Statement statement = connection.createStatement();
				ResultSet resultSet = statement.executeQuery(selectSql)) {

				// Print results from select statement
				while (resultSet.next()) {
					System.out.println(resultSet.getString(2) + " "
						+ resultSet.getString(3));
				}
			}

			// Create and execute an INSERT SQL prepared statement.
			String insertSql = "INSERT INTO SalesLT.Product (Name, ProductNumber, Color, StandardCost, ListPrice, SellStartDate) VALUES "
				+ "(?, ?, ?, ?, ?, ?);";

			try (PreparedStatement prepsInsertProduct = connection.prepareStatement(
				insertSql,
				Statement.RETURN_GENERATED_KEYS)) {

				prepsInsertProduct.setString(1, "Bike");
				prepsInsertProduct.setString(2, "B1");
				prepsInsertProduct.setString(3, "Blue");
				prepsInsertProduct.setBigDecimal(4, new BigDecimal(50));
				prepsInsertProduct.setBigDecimal(5, new BigDecimal(120));
				prepsInsertProduct.setObject(6, LocalDate.of(2016, 1, 1).atStartOfDay());
				prepsInsertProduct.executeUpdate();
				// Retrieve the generated key from the insert.
				try (ResultSet generatedKeys = prepsInsertProduct.getGeneratedKeys()) {
					// Print the ID of the inserted row.
					while (generatedKeys.next()) {
						System.out.println("Generated: " + generatedKeys.getString(1));
					}
				}
			}
		}
	}
}

