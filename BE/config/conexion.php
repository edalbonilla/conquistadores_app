<?php

    $server = "localhost";
    $user = "root";
    $clave = "";
    $db = "sigesco";
    $port = "3306";

    //conexion a la base de datos
    $conexion = new mysqli($server,$user,$clave,$db,$port);
    if ( $conexion-> connect_errno ) {
        die($conexion -> connect_error);
        echo "error a la conexion";
    }


    //funcion para Guardar, modifica, eliminar
    function NowQuery($sql, $conexion=null){
        if(!$conexion)global $conexion;
        $result = $conexion->query($sql);
        return $conexion-> affect_row;
    }


    //funcion para Select(Listar)
    function ObtenerRegistro($sql, $conexion = null) {
        
        if(!$conexion)global $conexion;
        $result = $conexion->query($sql);
        $resultArray = array();
        foreach($result as $registros){
            $resultArray[] = $registros;
        }
        return $resultArray;
    }
    

?>