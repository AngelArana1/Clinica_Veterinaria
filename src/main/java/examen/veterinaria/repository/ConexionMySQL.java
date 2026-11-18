package examen.veterinaria.repository;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;



public final class ConexionMySQL {

    private ConexionMySQL() {
    }

    public static Connection getConnection() throws SQLException {
        String url = System.getenv("VET_DB_URL");
        String user = System.getenv("VET_DB_USER");
        String password = System.getenv("VET_DB_PASSWORD");

        if (url == null || url.isBlank()) {
            throw new IllegalStateException("Falta la variable de entorno VET_DB_URL.");
        }
        if (user == null || user.isBlank()) {
            throw new IllegalStateException("Falta la variable de entorno VET_DB_USER.");
        }

        return DriverManager.getConnection(url, user, password == null ? "" : password);
    }
}
