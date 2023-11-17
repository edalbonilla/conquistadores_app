<?php
    require_once ('BE/config/conexion.php');

    $query = "SELECT * FROM ministerio";
    $resultado = ObtenerRegistro($query);
    print_r($resultado);

?>