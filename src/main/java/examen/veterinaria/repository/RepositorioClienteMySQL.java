package examen.veterinaria.repository;

import examen.veterinaria.model.Cliente;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RepositorioClienteMySQL implements RepositorioCliente {

    @Override
    public List<Cliente> cargarTodos() {
        List<Cliente> lista = new ArrayList<>();
        String sql = "{CALL sp_listar_clientes()}";
        try (Connection conn = ConexionMySQL.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) {
                lista.add(new Cliente(
                        rs.getString("cedula"),
                        rs.getString("nombre"),
                        rs.getString("telefono")
                ));
            }
            return lista;
        } catch (SQLException e) {
            throw new PersistenciaException("No se pudieron listar los clientes desde MySQL.", e);
        }
    }

    @Override
    public void insertar(Cliente cliente) {
        if (existeCliente(cliente.getCedula())) {
            throw new IllegalArgumentException("Ya existe un cliente con esa cedula.");
        }
        String sql = "{CALL sp_insertar_cliente(?, ?, ?)}";
        try (Connection conn = ConexionMySQL.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, cliente.getCedula());
            cs.setString(2, cliente.getNombre());
            cs.setString(3, cliente.getTelefono());
            cs.executeUpdate();
        } catch (SQLException e) {
            throw new PersistenciaException("No se pudo insertar el cliente en MySQL.", e);
        }
    }

    private boolean existeCliente(String cedula) {
        for (Cliente c : cargarTodos()) {
            if (c.getCedula().equalsIgnoreCase(cedula)) {
                return true;
            }
        }
        return false;
    }
}
