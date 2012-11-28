<?php

$username="alchemi1_joey";
$password="maggie";
$database="alchemi1_agonscores";

mysql_connect(localhost,$username,$password);
@mysql_select_db($database) or die( "Unable to select database");

$one = $_GET['name']; 
$two = $_GET['score']; 

$query="INSERT into highScores (name, score) VALUES ('$one', '$two')";   
mysql_query($query) or die("Data not written.");

mysql_close();
?>

<?php include('makeXML.php'); ?>