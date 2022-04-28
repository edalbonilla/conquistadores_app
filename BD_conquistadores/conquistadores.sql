-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 22-04-2022 a las 18:31:02
-- Versión del servidor: 10.4.17-MariaDB
-- Versión de PHP: 7.3.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `conquistadores`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `countEstudios` (IN `miembro` VARCHAR(75), OUT `estudio` INT(10))  BEGIN
 SELECT count(*) 
 INTO estudio
 FROM estudiobiblico 
 where codDuo = (SELECT codDuo 
                 FROM asignacionduo 
                 where asignacionduo.miembro = miembro);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `countEstudiosClub` (IN `club` VARCHAR(75), OUT `estudio` INT(10))  BEGIN
 SELECT count(*) 
 INTO estudio
 FROM estudiobiblico 
 where codDuo = (SELECT codDuo 
                 FROM duomisionero 
                 where duomisionero.club = club);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `creacionDuo` (IN `club` VARCHAR(8), IN `miembro1` VARCHAR(8), IN `miembro2` VARCHAR(8))  BEGIN
	DECLARE codigo varchar(20);
    
    SELECT codigoDuo(club) into codigo;
    
	insert into duomisionero(codDuo, club, status, created_at) VALUES(codigo,club, 1, now());
    INSERT INTO asignacionduo(codDuo, miembro) VALUES (codigo, miembro1);
    INSERT INTO asignacionduo(codDuo, miembro) VALUES (codigo, miembro2);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `creacionPlan` (IN `club` VARCHAR(8), IN `encargado` VARCHAR(8), IN `nombre` VARCHAR(100), IN `objetivo` VARCHAR(100), IN `lugar` TEXT, IN `materiales` VARCHAR(100), IN `costos` DOUBLE, IN `fchaIni` DATETIME, IN `fchaFin` DATETIME)  BEGIN
    
	INSERT INTO `items`(`NombreActividad`, `estado`, `Club`, `Encargado`) VALUES (nombre, 1, club, encargado);
    INSERT INTO `detalleitems`(`objetivo`, `lugar`, `materiales`, `costos`, `fhInicio`, `fhFin`, `idItems`) VALUES (objetivo, lugar, materiales, costos, fchaIni, fchaFin, (SELECT idItem FROM items WHERE NombreActividad = nombre ));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createClub` (IN `pCodClub` VARCHAR(8), IN `pNombreClub` VARCHAR(75), IN `pIglesia` VARCHAR(100), IN `pDistrito` VARCHAR(50), IN `pZona` VARCHAR(10), IN `pcodCampo` VARCHAR(8), IN `pCodUsuario` VARCHAR(8))  BEGIN
INSERT INTO `club`(`codClub`, `nombreClub`, `iglesia`, `distrito`, `zona`, `codCampo`, USER, DATECREATE) VALUES (pCodClub,pNombreClub,pIglesia,pDistrito,pZona,pcodCampo,pCodUsuario, now());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `edad` (IN `miembro` VARCHAR(75), OUT `edad` INT(10))  BEGIN
 SELECT TIMESTAMPDIFF(YEAR, miembros.fechaNacimiento, now()) 
 into edad
 FROM miembros 
 where miembros.codUsuario = miembro ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ingresoUsuarios` (IN `pCodMiembro` VARCHAR(8), IN `pNombre` VARCHAR(100), IN `pFechaNacimiento` DATE, IN `pEmail` VARCHAR(75), IN `pTelfono` VARCHAR(10), IN `pContraseña` VARCHAR(10), IN `pTipoUser` INT(1), IN `pFechaRegistro` DATE, IN `pEstado` VARCHAR(1), IN `pCodCampo` VARCHAR(8), IN `pBautizado` VARCHAR(1), IN `pCategoria` VARCHAR(1))  begin 
INSERT INTO miembros(codUsuario, nombre, fechaNacimiento, email, telefono, bautizado, categoria) VALUES (pCodMiembro,pNombre,pFechaNacimiento,pEmail,pTelfono,pBautizado,pCategoria);
INSERT INTO usuario (codMiembro, contraseña, tipoUsuario, fechaRegistro, estado, codCampo) VALUES (pCodMiembro, sha2(pContraseña,256), pTipoUser, pFechaRegistro, pEstado, pCodCampo);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `pEmail` VARCHAR(75), IN `pContraseñaa` VARCHAR(256), OUT `resp` INT(10))  BEGIN
 SELECT u.idUsuario
 into resp FROM usuario as u INNER JOIN miembros as m on u.codMiembro = m.codUsuario WHERE m.email = pEmail AND u.contraseña = sha2(pContraseñaa,256);
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `porcentajeAsistencia` (IN `miembro` VARCHAR(75), OUT `asistencia` INT(10))  BEGIN
 select ((select COUNT(*) from asistencia as a where a.asistencia = 1 and a.codUsuario = miembro)*100)/count(DISTINCT(fecha)) 
 into asistencia
 from asistencia where codUsuario in (SELECT miembros.codUsuario from miembros where miembros.codClub = (select mi.codClub from miembros as mi where mi.codUsuario = miembro));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prueba` (IN `nombreParam` VARCHAR(60))  BEGIN
INSERT INTO pais (nombre) 
VALUES (nombreParam);
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `codigoDuo` (`codigoClub` VARCHAR(10)) RETURNS VARCHAR(40) CHARSET latin1 BEGIN
	declare detCodigo varchar(20);
    
    select concat(c.codClub,(FLOOR(1 + RAND() * (99999999 - 1 + 1)))) into detCodigo from club c where c.codClub = codigoClub;
        
    RETURN detCodigo;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `EXT_PRIORIDAD` (`cliente_prioridad` VARCHAR(5)) RETURNS VARCHAR(20) CHARSET latin1 BEGIN
 CASE cliente_prioridad

 WHEN 'A' THEN
 RETURN 'Alto';
 WHEN 'M' THEN
 RETURN 'Medio';
 WHEN 'B' THEN
 RETURN 'Bajo';
 ELSE
 RETURN 'NN';
 END CASE;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getCodDuo` (`codClub` VARCHAR(10)) RETURNS VARCHAR(20) CHARSET latin1 BEGIN
 DECLARE getCod varchar(20); 
 SET getCod = codClub;
 
 RETURN getCod;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alergias`
--

CREATE TABLE `alergias` (
  `idAlergias` int(8) NOT NULL,
  `codMiembro` varchar(8) NOT NULL,
  `alergia` varchar(75) NOT NULL,
  `nivelGravedad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `alergias`
--

INSERT INTO `alergias` (`idAlergias`, `codMiembro`, `alergia`, `nivelGravedad`) VALUES
(5, 'ZY3001D', '', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `area`
--

CREATE TABLE `area` (
  `idArea` int(11) NOT NULL,
  `nombreArea` varchar(75) NOT NULL,
  `descripcion` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `prueba` (
  `idArea` int(11) NOT NULL,
  `nombreArea` varchar(75) NOT NULL,
  `descripcion` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
--
-- Volcado de datos para la tabla `area`
--

INSERT INTO `area` (`idArea`, `nombreArea`, `descripcion`) VALUES
(1, 'Espiritual', 'Actividades Espirituales');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignacionduo`
--

CREATE TABLE `asignacionduo` (
  `id` int(11) NOT NULL,
  `codDuo` varchar(20) NOT NULL,
  `miembro` varchar(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `asignacionduo`
--

INSERT INTO `asignacionduo` (`id`, `codDuo`, `miembro`) VALUES
(1, 'ZDM224416487342', 'ZY3001D'),
(2, 'CDH320031094822', 'LG0044M');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignacionmiembro`
--

CREATE TABLE `asignacionmiembro` (
  `idAsignacion` int(11) NOT NULL,
  `codMiembro` varchar(8) CHARACTER SET latin1 NOT NULL,
  `codMinisterio` varchar(8) CHARACTER SET latin1 NOT NULL,
  `fechaIngreso` date NOT NULL,
  `status` int(1) NOT NULL,
  `observacion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asistencia`
--

CREATE TABLE `asistencia` (
  `idAsistencia` int(11) NOT NULL,
  `codUsuario` varchar(8) NOT NULL,
  `fecha` date NOT NULL,
  `asistencia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `asistencia`
--

INSERT INTO `asistencia` (`idAsistencia`, `codUsuario`, `fecha`, `asistencia`) VALUES
(1, 'YL0030V', '2020-01-19', 1),
(2, 'ZY3001D', '2020-01-19', 1),
(3, 'LG0044M', '2020-01-19', 1),
(4, 'YL0030V', '2020-02-11', 1),
(5, 'MB0103B', '2020-02-11', 1),
(6, 'ZY3001D', '2020-02-11', 0),
(7, 'LG0044M', '2020-02-11', 1),
(8, 'ZY3001D', '2020-02-16', 1),
(9, 'MB0103B', '2020-02-16', 0),
(10, 'LG0044M', '2020-02-16', 0),
(11, 'YL0030V', '2020-02-16', 0),
(12, 'ZY3001D', '2020-02-23', 0),
(13, 'LG0044M', '2020-02-23', 1),
(14, 'YL0030V', '2020-02-23', 1),
(15, 'MB0103B', '2020-02-23', 1),
(16, 'MB0103B', '2020-09-28', 1),
(17, 'YL0030V', '2020-09-28', 0),
(18, 'LG0044M', '2020-09-28', 1),
(19, 'ZY3001D', '2020-09-28', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `campo`
--

CREATE TABLE `campo` (
  `codCampo` varchar(8) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `idPais` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `campo`
--

INSERT INTO `campo` (`codCampo`, `nombre`, `idPais`) VALUES
('AMAS', 'Asociación Metropolitana Adventista Salvadoreña', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `claseprogrersiva`
--

CREATE TABLE `claseprogrersiva` (
  `idClase` int(11) NOT NULL,
  `nombre` varchar(75) NOT NULL,
  `nivel` varchar(15) NOT NULL,
  `categoria` varchar(15) NOT NULL,
  `descripcion` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `claseprogrersiva`
--

INSERT INTO `claseprogrersiva` (`idClase`, `nombre`, `nivel`, `categoria`, `descripcion`) VALUES
(1, 'Abejita', '1', '1', 'Clase de  abejitas'),
(2, 'Especialidad de Perros', '1', '2', 'Especialidad de Perros');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `condicionmedica`
--

CREATE TABLE `condicionmedica` (
  `idCondicion` int(11) NOT NULL,
  `codMiembro` varchar(8) CHARACTER SET latin1 NOT NULL,
  `condicion` varchar(150) NOT NULL,
  `medicamento` text NOT NULL,
  `nivelCondicion` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configsigesco`
--

CREATE TABLE `configsigesco` (
  `idConfig` int(11) NOT NULL,
  `keyName` text NOT NULL,
  `valor` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalleitems`
--

CREATE TABLE `detalleitems` (
  `objetivo` text NOT NULL,
  `lugar` varchar(100) NOT NULL,
  `materiales` text NOT NULL,
  `costos` double NOT NULL,
  `fhInicio` datetime NOT NULL,
  `fhFin` datetime NOT NULL,
  `idDetalleItems` int(11) NOT NULL,
  `idItems` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalleitems`
--

INSERT INTO `detalleitems` (`objetivo`, `lugar`, `materiales`, `costos`, `fhInicio`, `fhFin`, `idDetalleItems`, `idItems`) VALUES
('promover el club en mi cominidad', 'iglesia San Roque', 'pastel, piñatas, jugos, desechables', 50, '2020-01-05 08:00:00', '2020-01-05 11:00:00', 2, 2),
('para inscripciones', 'iglesia san roque', 'hojas de inscripcion', 12, '2020-01-12 00:00:00', '2020-01-12 00:00:00', 3, 3),
('reuniones normales', 'iglesia san roqeu', 'ninguno', 0, '2020-02-02 00:00:00', '2020-02-02 00:00:00', 4, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `directiva`
--

CREATE TABLE `directiva` (
  `id` int(11) NOT NULL,
  `codClub` varchar(8) NOT NULL,
  `codMiembro` varchar(8) NOT NULL,
  `cargo` varchar(11) NOT NULL,
  `año` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `directiva`
--

INSERT INTO `directiva` (`id`, `codClub`, `codMiembro`, `cargo`, `año`) VALUES
(1, 'ZDM2244', 'ZY3001D', 'DIR_AVE', '2019'),
(10, 'ZDM2244', 'YL0030V', 'DIR_CON', '2020');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `duomisionero`
--

CREATE TABLE `duomisionero` (
  `codDuo` varchar(20) NOT NULL,
  `club` varchar(8) NOT NULL,
  `status` int(1) NOT NULL,
  `created_at` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `duomisionero`
--

INSERT INTO `duomisionero` (`codDuo`, `club`, `status`, `created_at`) VALUES
('CDH320031094822', 'CDH3200', 1, '2019-12-14'),
('dsda', '', 0, '0000-00-00'),
('ZDM224416487342', 'prueba', 1, '2019-12-14'),
('ZDM224431221804', 'ZDM2244', 1, '2019-12-14'),
('ZDM224433045174', 'ZDM2244', 1, '2019-12-14'),
('ZDM224460334750', 'ZDM2244', 1, '2019-12-14'),
('ZDM224496364422', 'zzss45', 1, '2019-12-14');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estudio`
--

CREATE TABLE `estudio` (
  `idEstudio` int(11) NOT NULL,
  `idEstudioBiblico` varchar(20) NOT NULL,
  `idTema` int(11) NOT NULL,
  `fechaEstudio` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estudiobiblico`
--

CREATE TABLE `estudiobiblico` (
  `codEstudio` varchar(20) NOT NULL,
  `nombreEstudio` varchar(75) NOT NULL,
  `fechaNacimiento` date NOT NULL,
  `direccion` text NOT NULL,
  `email` varchar(50) NOT NULL,
  `contacto` varchar(10) NOT NULL,
  `codDuo` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `estudiobiblico`
--

INSERT INTO `estudiobiblico` (`codEstudio`, `nombreEstudio`, `fechaNacimiento`, `direccion`, `email`, `contacto`, `codDuo`) VALUES
('fhgs', 'Ronald Eduardo Bonilla', '2020-02-03', 'prueba de direccion', 'edal@gmail,com', '22564872', 'ZDM224416487342'),
('fhgssw', 'Ronald2 Eduardo Bonilla', '2020-02-03', 'prueba de direccion', 'edl@gmail,com', '22564872', 'CDH320031094822'),
('fhgsw', 'Ronald2 Eduardo Bonilla', '2020-02-03', 'prueba de direccion', 'edl@gmail,com', '22564872', 'ZDM224416487342');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `iglesia`
--

CREATE TABLE `iglesia` (
  `codIglesia` varchar(8) NOT NULL,
  `nombre` varchar(75) NOT NULL,
  `distrito` varchar(50) NOT NULL,
  `zona` varchar(10) NOT NULL,
  `codCampo` varchar(8) NOT NULL,
  `estado` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `iglesia`
--

INSERT INTO `iglesia` (`codIglesia`, `nombre`, `distrito`, `zona`, `codCampo`, `estado`) VALUES
('CDH3200', 'Concejo AMAS', ' ', ' ', 'AMAS', '1'),
('ZDM2244', 'San Roque', 'San Roque', '2', 'AMAS', NULL),
('ZNS3140', 'Jehova Nissi', 'La Mendez', '1', 'AMAS', NULL),
('ZQT0101', 'Almagor', 'La mendez', '2', 'AMAS', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `investidura`
--

CREATE TABLE `investidura` (
  `idInvestidura` int(11) NOT NULL,
  `idClase` int(11) NOT NULL,
  `codMiembro` varchar(8) NOT NULL,
  `lugar` varchar(50) NOT NULL,
  `fecha` date NOT NULL,
  `investido` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `investidura`
--

INSERT INTO `investidura` (`idInvestidura`, `idClase`, `codMiembro`, `lugar`, `fecha`, `investido`) VALUES
(1, 2, 'ZY3001D', 'San Roque', '2020-01-14', 1),
(2, 1, 'ZY3001D', 'San Roque', '2020-02-10', 1),
(3, 2, 'YL0030V', 'casa', '2020-09-01', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `items`
--

CREATE TABLE `items` (
  `idItem` int(11) NOT NULL,
  `NombreActividad` varchar(100) NOT NULL,
  `estado` int(1) NOT NULL,
  `area` int(11) NOT NULL,
  `Encargado` varchar(10) NOT NULL,
  `idPlan` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `items`
--

INSERT INTO `items` (`idItem`, `NombreActividad`, `estado`, `area`, `Encargado`, `idPlan`) VALUES
(2, 'Promocion CLub', 1, 1, 'YL0030V', 1),
(3, 'inscripcion de club', 1, 1, 'YL0030V', 1),
(4, 'Actividades Regulares, desarrollo de Clases y especialidades', 1, 1, 'YL0030V', 1),
(5, 'prueba items', 1, 1, 'YL0030V', 1),
(6, 'prueba items', 1, 1, 'YL0030V', 1),
(7, 'prueba items', 1, 1, 'ZY3001D', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `leccion`
--

CREATE TABLE `leccion` (
  `idLeccion` int(11) NOT NULL,
  `nombre` varchar(75) NOT NULL,
  `descripcion` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `leccion`
--

INSERT INTO `leccion` (`idLeccion`, `nombre`, `descripcion`) VALUES
(1, 'Fe de Jesus', 'La fe de jesus');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `miembros`
--

CREATE TABLE `miembros` (
  `codUsuario` varchar(8) NOT NULL,
  `codClub` varchar(8) DEFAULT NULL,
  `nombre` varchar(100) NOT NULL,
  `foto` varchar(50) DEFAULT NULL,
  `sexo` varchar(1) DEFAULT NULL,
  `fechaNacimiento` date NOT NULL,
  `idTipoSanguineo` int(8) DEFAULT NULL,
  `email` varchar(75) NOT NULL,
  `telefono` varchar(10) NOT NULL,
  `bautizado` varchar(1) DEFAULT NULL,
  `estado` varchar(1) DEFAULT NULL,
  `categoria` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `miembros`
--

INSERT INTO `miembros` (`codUsuario`, `codClub`, `nombre`, `foto`, `sexo`, `fechaNacimiento`, `idTipoSanguineo`, `email`, `telefono`, `bautizado`, `estado`, `categoria`) VALUES
('FK3334G', NULL, 'prueba', NULL, NULL, '1989-03-23', NULL, 'edwin.ncecs@gmail.com', '61803200', '1', NULL, '4'),
('KZ1000M', NULL, 'prueba', NULL, NULL, '1989-03-23', NULL, 'edwin.ncecs@gmail.com', '61803200', '1', NULL, '4'),
('LG0044M', 'ZDM2244', 'david robert kk', '8b4cee40-1787-4189-a963-bcc95a65af47.jpg', 'H', '1989-03-23', 1, 'keiri.ncecjs@gmail.com', '61803200', '1', '1', '2'),
('MB0103B', 'ZDM2244', 'david robert2', 'e25e3270-7dbd-40a5-948e-3b967142103a.jpg', 'H', '1989-12-23', 1, 'keirrr.ncecjs@gmail.com', '2278-1524', '1', '1', '3'),
('QP2001M', NULL, 'prueba', NULL, NULL, '1989-03-23', NULL, 'edal.bonilla@gmail.com', '61803200', '1', NULL, '4'),
('QT0131M', NULL, 'Adonay Molina', NULL, NULL, '1989-03-23', NULL, 'adonay.molin@gmail.com', '61803200', '1', NULL, '4'),
('SM4100Q', 'ZNS3140', 'daniel perez', 'f390d8ab-8fee-4626-b287-eb9ac550c8c7.png', 'H', '2006-02-01', 1, 'prueba@gmail.com', '2222222', '0', '1', '1'),
('ST0102C', NULL, 'prueba', NULL, NULL, '1989-03-23', NULL, 'edwin.ncecs@gmail.com', '89898989', '1', NULL, '4'),
('US8641', 'ZQT0101', 'Edwin Alfredo Bonilla Hernández', 'na', 'M', '1989-03-23', 1, 'edwin.bonilla@udb.edu.sv', '6180-3200', '1', '2', '3'),
('WR1421G', NULL, 'prueba', NULL, NULL, '1989-03-23', NULL, 'edwin.ncecs@gmail.com', '89898989', '1', NULL, '4'),
('WT0141K', NULL, 'David Ferrer Gonzalez', NULL, NULL, '2019-02-25', NULL, 'edwin.ncecs@gmail,com', '12451245', '1', NULL, '4'),
('XD3313W', NULL, 'Adonay Molina', NULL, NULL, '1989-03-23', NULL, 'adonay.molin@gmail.com', '89898989', '1', NULL, '4'),
('YL0030V', 'ZDM2244', 'david roberto Ferrer Coto', 'dc49b2fa-80f1-4f36-a647-154d973efae2.jpg', 'H', '1989-03-23', 1, 'keiri.ncecs@gmail.com', '61803200', '1', '1', '1'),
('ZY3001D', 'ZDM2244', 'Wendy Ferrer de ', 'edwdwdas.PNG', 'M', '1989-02-01', 1, 'edal.bonilla@hotmail.com', '22271234', '1', '1', '3');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ministerio`
--

CREATE TABLE `ministerio` (
  `codMinisterio` varchar(8) CHARACTER SET latin1 NOT NULL,
  `idMinisterio` int(3) NOT NULL,
  `alias` varchar(75) DEFAULT NULL,
  `codIglesia` varchar(8) CHARACTER SET latin1 NOT NULL,
  `fechaCreacion` date NOT NULL,
  `status` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pais`
--

CREATE TABLE `pais` (
  `idPais` int(11) NOT NULL,
  `nombre` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `pais`
--

INSERT INTO `pais` (`idPais`, `nombre`) VALUES
(1, 'El Salvador');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `plantrabajo`
--

CREATE TABLE `plantrabajo` (
  `idPlan` int(11) NOT NULL,
  `temaPlan` varchar(100) NOT NULL,
  `añoPlan` varchar(4) NOT NULL,
  `objetivoGeneral` text NOT NULL,
  `codClub` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `plantrabajo`
--

INSERT INTO `plantrabajo` (`idPlan`, `temaPlan`, `añoPlan`, `objetivoGeneral`, `codClub`) VALUES
(1, 'pruebas 2020', '2020', 'gsdfgasdgasdfgasdgasdgsg', 'ZDM2244'),
(2, 'sadasd', '2020', 'dsaDSDSAD', 'ZQT0101');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `responsables`
--

CREATE TABLE `responsables` (
  `IDRESPONSABLE` int(11) NOT NULL,
  `EMAIL` varchar(255) DEFAULT NULL,
  `MOVIL` varchar(255) DEFAULT NULL,
  `NOMBRE` varchar(255) DEFAULT NULL,
  `TELEFONO` varchar(255) DEFAULT NULL,
  `codMiembro` varchar(255) DEFAULT NULL,
  `parentesco` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `responsables`
--

INSERT INTO `responsables` (`IDRESPONSABLE`, `EMAIL`, `MOVIL`, `NOMBRE`, `TELEFONO`, `codMiembro`, `parentesco`) VALUES
(1, 'edal@gmail.com', 'sdfaf', 'edwin bonilla', 'dssda', 'YL0030V', NULL),
(2, 'edal@gmail.com', 'sdfaf', 'edwin bonilla', 'dssda', 'LG0044M', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `temaleccion`
--

CREATE TABLE `temaleccion` (
  `idTema` int(11) NOT NULL,
  `idLeccion` int(11) NOT NULL,
  `nombreTema` varchar(75) NOT NULL,
  `descripcion` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tiposanguineo`
--

CREATE TABLE `tiposanguineo` (
  `idTipo` int(8) NOT NULL,
  `grupo` varchar(10) NOT NULL,
  `RH` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tiposanguineo`
--

INSERT INTO `tiposanguineo` (`idTipo`, `grupo`, `RH`) VALUES
(1, 'O', 'positivo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idUsuario` int(11) NOT NULL,
  `codMiembro` varchar(8) NOT NULL,
  `contraseña` varchar(256) NOT NULL,
  `tipoUsuario` int(11) NOT NULL,
  `fechaRegistro` date NOT NULL,
  `estado` varchar(1) NOT NULL,
  `codCampo` varchar(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idUsuario`, `codMiembro`, `contraseña`, `tipoUsuario`, `fechaRegistro`, `estado`, `codCampo`) VALUES
(1, 'US8641', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 7, '2019-02-27', '1', '1'),
(7, 'ZY3001D', 'fe065834d17f72cfa3f31254525d500656fcd4f6c99d3f848767599585d69aa9', 1, '2019-03-03', '2', ' '),
(8, 'WT0141K', '8807b761a993770cddda5a9c9f0ba62fe0c0e7a091006946379989ace76a6d34', 4, '2020-01-26', '2', ' '),
(12, 'ST0102C', '102a7ef90c1fcfa8de985cde1bdc78e3225e1f84e9bf50665dc3ab44a779fd20', 7, '2020-02-22', '2', ' '),
(14, 'QT0131M', '01814ebb2c3cce4235183252c79343530ff1853244d9789fbacac66b24b67678', 2, '2020-09-28', '2', ' '),
(15, 'QP2001M', '797c52fd8b08e17ef81a7b71411f1889df9add42fe124d7277a926de9ae7eaf7', 7, '2020-09-28', '2', ' ');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `alergias`
--
ALTER TABLE `alergias`
  ADD PRIMARY KEY (`idAlergias`),
  ADD UNIQUE KEY `codMiembro_2` (`codMiembro`),
  ADD KEY `codMiembro` (`codMiembro`);

--
-- Indices de la tabla `area`
--
ALTER TABLE `area`
  ADD PRIMARY KEY (`idArea`);

--
-- Indices de la tabla `asignacionduo`
--
ALTER TABLE `asignacionduo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `miembro_2` (`miembro`),
  ADD KEY `DuoAsignacion` (`codDuo`),
  ADD KEY `miembro` (`miembro`),
  ADD KEY `codDuo` (`codDuo`);

--
-- Indices de la tabla `asignacionmiembro`
--
ALTER TABLE `asignacionmiembro`
  ADD PRIMARY KEY (`idAsignacion`),
  ADD KEY `CHK_Miembro_Asignacion` (`codMiembro`),
  ADD KEY `CHK_Ministerio_Asignacion` (`codMinisterio`);

--
-- Indices de la tabla `asistencia`
--
ALTER TABLE `asistencia`
  ADD PRIMARY KEY (`idAsistencia`),
  ADD KEY `FK_miembro_asistencia` (`codUsuario`);

--
-- Indices de la tabla `campo`
--
ALTER TABLE `campo`
  ADD PRIMARY KEY (`codCampo`),
  ADD KEY `fk_pais_campo` (`idPais`);

--
-- Indices de la tabla `claseprogrersiva`
--
ALTER TABLE `claseprogrersiva`
  ADD PRIMARY KEY (`idClase`);

--
-- Indices de la tabla `condicionmedica`
--
ALTER TABLE `condicionmedica`
  ADD PRIMARY KEY (`idCondicion`),
  ADD KEY `codMiembro` (`codMiembro`);

--
-- Indices de la tabla `configsigesco`
--
ALTER TABLE `configsigesco`
  ADD PRIMARY KEY (`idConfig`);

--
-- Indices de la tabla `detalleitems`
--
ALTER TABLE `detalleitems`
  ADD PRIMARY KEY (`idDetalleItems`),
  ADD KEY `idItems` (`idItems`);

--
-- Indices de la tabla `directiva`
--
ALTER TABLE `directiva`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_club_directiva` (`codClub`),
  ADD KEY `fk_miembro_directiva` (`codMiembro`);

--
-- Indices de la tabla `duomisionero`
--
ALTER TABLE `duomisionero`
  ADD PRIMARY KEY (`codDuo`);

--
-- Indices de la tabla `estudio`
--
ALTER TABLE `estudio`
  ADD PRIMARY KEY (`idEstudio`),
  ADD KEY `fk_estubi_estudio` (`idEstudioBiblico`),
  ADD KEY `fk_leccion_estudio` (`idTema`);

--
-- Indices de la tabla `estudiobiblico`
--
ALTER TABLE `estudiobiblico`
  ADD PRIMARY KEY (`codEstudio`);

--
-- Indices de la tabla `iglesia`
--
ALTER TABLE `iglesia`
  ADD PRIMARY KEY (`codIglesia`),
  ADD KEY `fk_campo_club` (`codCampo`);

--
-- Indices de la tabla `investidura`
--
ALTER TABLE `investidura`
  ADD PRIMARY KEY (`idInvestidura`),
  ADD KEY `fk_miembro_clase` (`codMiembro`),
  ADD KEY `fk_clase_inv` (`idClase`);

--
-- Indices de la tabla `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`idItem`),
  ADD KEY `idPlan` (`idPlan`),
  ADD KEY `Club` (`area`) USING BTREE;

--
-- Indices de la tabla `leccion`
--
ALTER TABLE `leccion`
  ADD PRIMARY KEY (`idLeccion`);

--
-- Indices de la tabla `miembros`
--
ALTER TABLE `miembros`
  ADD PRIMARY KEY (`codUsuario`),
  ADD KEY `fk_club_miembro` (`codClub`),
  ADD KEY `fk_miembro_tsangre` (`idTipoSanguineo`);

--
-- Indices de la tabla `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `ministerio`
--
ALTER TABLE `ministerio`
  ADD PRIMARY KEY (`codMinisterio`),
  ADD KEY `CHK_Iglesia_Ministerio` (`codIglesia`),
  ADD KEY `idMinisterio` (`idMinisterio`);

--
-- Indices de la tabla `pais`
--
ALTER TABLE `pais`
  ADD PRIMARY KEY (`idPais`);

--
-- Indices de la tabla `plantrabajo`
--
ALTER TABLE `plantrabajo`
  ADD PRIMARY KEY (`idPlan`);

--
-- Indices de la tabla `responsables`
--
ALTER TABLE `responsables`
  ADD PRIMARY KEY (`IDRESPONSABLE`),
  ADD KEY `fk_miembro_rsponsable` (`codMiembro`);

--
-- Indices de la tabla `temaleccion`
--
ALTER TABLE `temaleccion`
  ADD PRIMARY KEY (`idTema`),
  ADD KEY `fk_leccion_tema` (`idLeccion`);

--
-- Indices de la tabla `tiposanguineo`
--
ALTER TABLE `tiposanguineo`
  ADD PRIMARY KEY (`idTipo`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idUsuario`),
  ADD KEY `fk_miembro_ususario` (`codMiembro`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `alergias`
--
ALTER TABLE `alergias`
  MODIFY `idAlergias` int(8) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `area`
--
ALTER TABLE `area`
  MODIFY `idArea` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `asignacionduo`
--
ALTER TABLE `asignacionduo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `asignacionmiembro`
--
ALTER TABLE `asignacionmiembro`
  MODIFY `idAsignacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `asistencia`
--
ALTER TABLE `asistencia`
  MODIFY `idAsistencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de la tabla `claseprogrersiva`
--
ALTER TABLE `claseprogrersiva`
  MODIFY `idClase` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `condicionmedica`
--
ALTER TABLE `condicionmedica`
  MODIFY `idCondicion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `configsigesco`
--
ALTER TABLE `configsigesco`
  MODIFY `idConfig` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalleitems`
--
ALTER TABLE `detalleitems`
  MODIFY `idDetalleItems` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `directiva`
--
ALTER TABLE `directiva`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `estudio`
--
ALTER TABLE `estudio`
  MODIFY `idEstudio` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `investidura`
--
ALTER TABLE `investidura`
  MODIFY `idInvestidura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `items`
--
ALTER TABLE `items`
  MODIFY `idItem` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `leccion`
--
ALTER TABLE `leccion`
  MODIFY `idLeccion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `pais`
--
ALTER TABLE `pais`
  MODIFY `idPais` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `plantrabajo`
--
ALTER TABLE `plantrabajo`
  MODIFY `idPlan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `responsables`
--
ALTER TABLE `responsables`
  MODIFY `IDRESPONSABLE` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `temaleccion`
--
ALTER TABLE `temaleccion`
  MODIFY `idTema` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tiposanguineo`
--
ALTER TABLE `tiposanguineo`
  MODIFY `idTipo` int(8) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `alergias`
--
ALTER TABLE `alergias`
  ADD CONSTRAINT `fk_miembro_alergia` FOREIGN KEY (`codMiembro`) REFERENCES `miembros` (`codUsuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `asignacionduo`
--
ALTER TABLE `asignacionduo`
  ADD CONSTRAINT `fk_duo_asignacion` FOREIGN KEY (`codDuo`) REFERENCES `duomisionero` (`codDuo`);

--
-- Filtros para la tabla `asignacionmiembro`
--
ALTER TABLE `asignacionmiembro`
  ADD CONSTRAINT `CHK_Miembro_Asignacion` FOREIGN KEY (`codMiembro`) REFERENCES `miembros` (`codUsuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `CHK_Ministerio_Asignacion` FOREIGN KEY (`codMinisterio`) REFERENCES `ministerio` (`codMinisterio`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `campo`
--
ALTER TABLE `campo`
  ADD CONSTRAINT `fk_pais_campo` FOREIGN KEY (`idPais`) REFERENCES `pais` (`idPais`);

--
-- Filtros para la tabla `condicionmedica`
--
ALTER TABLE `condicionmedica`
  ADD CONSTRAINT `CHK_Miembro_CondicionMedica` FOREIGN KEY (`codMiembro`) REFERENCES `miembros` (`codUsuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalleitems`
--
ALTER TABLE `detalleitems`
  ADD CONSTRAINT `FK_items_detalleItems` FOREIGN KEY (`idItems`) REFERENCES `items` (`idItem`);

--
-- Filtros para la tabla `estudio`
--
ALTER TABLE `estudio`
  ADD CONSTRAINT `fk_estubi_estudio` FOREIGN KEY (`idEstudioBiblico`) REFERENCES `estudiobiblico` (`codEstudio`),
  ADD CONSTRAINT `fk_leccion_estudio` FOREIGN KEY (`idTema`) REFERENCES `temaleccion` (`idTema`);

--
-- Filtros para la tabla `iglesia`
--
ALTER TABLE `iglesia`
  ADD CONSTRAINT `fk_campo_club` FOREIGN KEY (`codCampo`) REFERENCES `campo` (`codCampo`);

--
-- Filtros para la tabla `investidura`
--
ALTER TABLE `investidura`
  ADD CONSTRAINT `fk_clase_inv` FOREIGN KEY (`idClase`) REFERENCES `claseprogrersiva` (`idClase`);

--
-- Filtros para la tabla `items`
--
ALTER TABLE `items`
  ADD CONSTRAINT `fk_area_items` FOREIGN KEY (`area`) REFERENCES `area` (`idArea`),
  ADD CONSTRAINT `fk_plan_items` FOREIGN KEY (`idPlan`) REFERENCES `plantrabajo` (`idPlan`);

--
-- Filtros para la tabla `miembros`
--
ALTER TABLE `miembros`
  ADD CONSTRAINT `fk_miembro_tsangre` FOREIGN KEY (`idTipoSanguineo`) REFERENCES `tiposanguineo` (`idTipo`);

--
-- Filtros para la tabla `ministerio`
--
ALTER TABLE `ministerio`
  ADD CONSTRAINT `CHK_Iglesia_Ministerio` FOREIGN KEY (`codIglesia`) REFERENCES `iglesia` (`codIglesia`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `responsables`
--
ALTER TABLE `responsables`
  ADD CONSTRAINT `fk_miembro_rsponsable` FOREIGN KEY (`codMiembro`) REFERENCES `miembros` (`codUsuario`);

--
-- Filtros para la tabla `temaleccion`
--
ALTER TABLE `temaleccion`
  ADD CONSTRAINT `fk_leccion_tema` FOREIGN KEY (`idLeccion`) REFERENCES `leccion` (`idLeccion`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
