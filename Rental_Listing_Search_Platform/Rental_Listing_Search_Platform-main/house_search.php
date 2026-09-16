<?php
    include "guest_login.php";
    $ID = "1";
    $landlord_id = "1";
    $rent_price = "99999";
    $address = "nga";
    $room_type = "doghouse";

    $query = ("select * from house where ID = ?");
    $stmt = $db ->prepare($query);
    $error = $stmt ->execute(array($ID));
    $result = $stmt ->fetchAll();

    for($i=0; $i<count($result); $i++){
        echo "ID:".$result[$i]['id'].'<br>'.
            "landlord_id:". $result [$i]['landlord_id'].'<br>'.
            "rent_price:". $result [$i]['rent_price'].'<br>'.
            "address:". $result [$i]['address'].'<br>'.
            "room_type:". $result [$i]['room_type'].'<br>'.
            '<br>';
    }
?>