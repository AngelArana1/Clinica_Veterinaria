package examen.veterinaria.repository;

import examen.veterinaria.model.Especie;
import examen.veterinaria.model.Mascota;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


public class RepositorioMascotaMySQL implements RepositorioMascota {

    @Override
    public List<Mascota> cargarTodos() {
        List<Mascota> lista = new ArrayList<>();
        String sql = "{CALL sp_listar_mascotas()}";
        try (Connection conn = ConexionMySQL.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) {
                lista.add(new Mascota(
                        rs.getString("codigo"),
                        rs.getString("nombre"),
                        Especie.valueOf(rs.getString("especie")),
                        rs.getInt("edad"),
                        rs.getString("cedula_cliente")
                ));
            }
            return lista;
        } catch (SQLException e) {
            throw new PersistenciaException("No se pudieron listar las mascotas desde MySQL.", e);
        }
    }

    @Override
    public List<String> listarConDueno() {
        List<String> filas = new ArrayList<>();
        String sql = "{CALL sp_listar_mascotas_con_dueno()}";
        try (Connection conn = ConexionMySQL.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) {
                filas.add(rs.getString("codigo") + " | "
                        + rs.getString("nombre") + " | "
                        + rs.getString("especie") + " | "
                        + rs.getInt("edad") + " anios | Dueño: "
                        + rs.getString("cedula_cliente") + " | Cliente: "
                        + rs.getString("nombre_cliente"));
            }
            return filas;
        } catch (SQLException e) {
            throw new PersistenciaException("No se pudieron listar las mascotas con duenio desde MySQL.", e);
        }
    }

    @Override
    public void insertar(Mascota mascota) {
        String sql = "{CALL sp_insertar_mascota(?, ?, ?, ?, ?)}";
        try (Connection conn = ConexionMySQL.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, mascota.getCodigo());
            cs.setString(2, mascota.getNombre());
            cs.setString(3, mascota.getEspecie().name());
            cs.setInt(4, mascota.getEdad());
            cs.setString(5, mascota.getCedulaCliente());
            cs.executeUpdate();
        } catch (SQLException e) {
            throw new PersistenciaException("No se pudo insertar la mascota en MySQL.", e);
        }
    }

    @Override
    public void actualizar(Mascota mascota) {
        String sql = "{CALL sp_actualizar_mascota(?, ?, ?, ?, ?)}";
        try (Connection conn = ConexionMySQL.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, mascota.getCodigo());
            cs.setString(2, mascota.getNombre());
            cs.setString(3, mascota.getEspecie().name());
            cs.setInt(4, mascota.getEdad());
            cs.setString(5, mascota.getCedulaCliente());
            cs.executeUpdate();
        } catch (SQLException e) {
            throw new PersistenciaException("No se pudo actualizar la mascota en MySQL.", e);
        }
    }




}
