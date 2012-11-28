<?php

$username="alchemi1_joey";
$password="maggie";
$database="alchemi1_agonscores";
$table_name = "highScores";

$connection = mysql_connect(localhost,$username,$password);
@mysql_select_db($database) or die( "Unable to select database");

$query = "select * from " . $table_name;
$result = mysql_query($query, $connection) or die("Could not complete database query");
$num = mysql_num_rows($result);

if ($num != 0) {
	$file= fopen("highScores.xml", "w");
	$_xml ="<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\r\n";
	$_xml .="<SCORES>\r\n";
	while ($row = mysql_fetch_array($result)) {
		if ($row["name"]) {
			$_xml .="\t<HIGHSCORE NAME=\"" . $row["name"] . "\" NUMBER=\"" . $row["score"] . "\" />\r\n";
 		} else {
			$_xml .="\t<HIGHSCORE NAME=\"Nothing Returned\" NUMBER=\"Nothing Returned\" />\r\n";
			} 
		}

		$_xml .="</SCORES>";
		fwrite($file, $_xml);
		fclose($file);

		echo "Score has been saved.";

} else {
	echo "No Records found";
} 
mysql_close();
?>