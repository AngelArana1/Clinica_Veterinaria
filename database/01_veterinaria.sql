CREATE DATABASE IF NOT EXISTS veterinaria;
USE veterinaria;
DROP TABLE IF EXISTS mascota;
DROP TABLE IF EXISTS cliente;

CREATE TABLE cliente (
                         cedula VARCHAR(20) NOT NULL,
                         nombre VARCHAR(80) NOT NULL,
                         telefono VARCHAR(20) NOT NULL,
                         CONSTRAINT pk_cliente PRIMARY KEY (cedula)
) ENGINE=InnoDB;

CREATE TABLE mascota (
                         codigo VARCHAR(15) NOT NULL,
                         nombre VARCHAR(80) NOT NULL,
                         especie  ENUM('PERRO','GATO','OTRO') NOT NULL,
                         edad INT NOT NULL,
                         cedula_cliente VARCHAR(20) NOT NULL,
                         CONSTRAINT pk_mascota PRIMARY KEY (codigo),
                         CONSTRAINT fk_mascota_cliente
                             FOREIGN KEY (cedula_cliente) REFERENCES cliente(cedula) ON DELETE RESTRICT,
                         CONSTRAINT chk_mascota_edad CHECK (edad BETWEEN 0 AND 60)
) ENGINE=InnoDB;

DROP PROCEDURE IF EXISTS sp_listar_clientes;
DROP PROCEDURE IF EXISTS sp_insertar_cliente;
DROP PROCEDURE IF EXISTS sp_listar_mascotas;
DROP PROCEDURE IF EXISTS sp_insertar_mascota;
DROP PROCEDURE IF EXISTS sp_actualizar_mascota;
DROP PROCEDURE IF EXISTS sp_eliminar_mascota;
DROP PROCEDURE IF EXISTS sp_listar_mascotas_con_dueno;

DELIMITER //

CREATE PROCEDURE sp_listar_clientes()
    SQL SECURITY DEFINER
BEGIN
SELECT cedula, nombre, telefono FROM cliente ORDER BY cedula;
END//

CREATE PROCEDURE sp_insertar_cliente(
    IN p_cedula  VARCHAR(20),
    IN p_nombre  VARCHAR(80),
    IN p_telefono VARCHAR(20)
)
    SQL SECURITY DEFINER
BEGIN
INSERT INTO cliente (cedula, nombre, telefono)
VALUES (p_cedula, p_nombre, p_telefono);
END//

CREATE PROCEDURE sp_listar_mascotas()
    SQL SECURITY DEFINER
BEGIN
SELECT codigo, nombre, especie, edad, cedula_cliente
FROM mascota ORDER BY codigo;
END//

CREATE PROCEDURE sp_insertar_mascota(
    IN p_codigo       VARCHAR(15),
    IN p_nombre       VARCHAR(80),
    IN p_especie      ENUM('PERRO','GATO','OTRO'),
    IN p_edad         INT,
    IN p_cedula_cliente VARCHAR(20)
        )
    SQL SECURITY DEFINER
BEGIN
INSERT INTO mascota (codigo, nombre, especie, edad, cedula_cliente)
VALUES (p_codigo, p_nombre, p_especie, p_edad, p_cedula_cliente);
END//

CREATE PROCEDURE sp_actualizar_mascota(
    IN p_codigo       VARCHAR(15),
    IN p_nombre       VARCHAR(80),
    IN p_especie      ENUM('PERRO','GATO','OTRO'),
    IN p_edad         INT,
    IN p_cedula_cliente VARCHAR(20)
        )
    SQL SECURITY DEFINER
BEGIN
    IF NOT EXISTS (SELECT 1 FROM mascota WHERE codigo = p_codigo) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existe la mascota que desea actualizar.';
END IF;
UPDATE mascota
SET nombre = p_nombre,
    especie = p_especie,
    edad = p_edad,
    cedula_cliente = p_cedula_cliente
WHERE codigo = p_codigo;
END//

CREATE PROCEDURE sp_eliminar_mascota(IN p_codigo VARCHAR(15))
    SQL SECURITY DEFINER
BEGIN
    IF NOT EXISTS (SELECT 1 FROM mascota WHERE codigo = p_codigo) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existe la mascota que desea eliminar.';
END IF;
DELETE FROM mascota WHERE codigo = p_codigo;
END//

CREATE PROCEDURE sp_listar_mascotas_con_dueno()
    SQL SECURITY DEFINER
BEGIN
SELECT m.codigo, m.nombre, m.especie, m.edad, m.cedula_cliente,
       c.nombre AS nombre_cliente
FROM mascota m
         INNER JOIN cliente c ON m.cedula_cliente = c.cedula
ORDER BY m.codigo;
END//
DELIMITER ;

DROP USER IF EXISTS 'vet_definer'@'localhost';
DROP USER IF EXISTS 'vet_app'@'localhost';


GRANT SELECT, INSERT ON veterinaria.cliente TO 'vet_definer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON veterinaria.mascota TO 'vet_definer'@'localhost';


GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_clientes TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_cliente TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_mascota TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_actualizar_mascota TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_eliminar_mascota TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas_con_dueno TO 'vet_app'@'localhost';

FLUSH PRIVILEGES;
