<?php
    $context = $_GET["context"];
    $file = "";
    $data = "";

    switch ($context) {
        case "updateNWI":
            $file = "../logs/nwi.csv";
            
            if (!file_exists($file)) {
                $data = "sessionID"     . "," . 
                        "rtt"           . "," .
                        "downlink"      . "," .
                        "downlinkMax"   . "," .
                        "type"          . "," .
                        "effectiveType" . "," .
                        "saveData"      . "," .
                        "clientTime"    . "," .
                        "serverTime"    . "\n";
            }
            
            $data .= $_GET["sessionID"]     . "," .
                     $_GET["rtt"]           . "," .
                     $_GET["downlink"]      . "," .
                     $_GET["downlinkMax"]   . "," .
                     $_GET["type"]          . "," .
                     $_GET["effectiveType"] . "," .
                     $_GET["saveData"]      . "," .
                     $_GET["clientTime"]    . "," .
                     time()                 . "\n";

            break;
        case "updatePosition":
            $file = "../logs/position.csv";
            
            if (!file_exists($file)) {
                $data = "sessionID"        . "," . 
                        "latitude"         . "," .
                        "longitude"        . "," .
                        "altitude"         . "," .
                        "speed"            . "," .
                        "heading"          . "," .
                        "accuracy"         . "," .
                        "altitudeAccuracy" . "," .
                        "positionTime"     . "," .
                        "clientTime"       . "," .
                        "serverTime"       . "\n";
            }

            $data .= $_GET["sessionID"]        . "," .
                     $_GET["latitude"]         . "," .
                     $_GET["longitude"]        . "," .
                     $_GET["altitude"]         . "," .
                     $_GET["speed"]            . "," .
                     $_GET["heading"]          . "," .
                     $_GET["accuracy"]         . "," .
                     $_GET["altitudeAccuracy"] . "," .
                     $_GET["positionTime"]     . "," .
                     $_GET["clientTime"]       . "," .
                     time()                    . "\n";

            break;
        case "updateQoE":
            $file = "../logs/qoe.csv";
            
            if (!file_exists($file)) {
                $data = "sessionID"  . "," . 
                        "qoeScore"   . "," .
                        "clientTime" . "," .
                        "serverTime" . "\n";
            }

            $data .= $_GET["sessionID"]        . "," .
                     $_GET["qoeScore"]         . "," .
                     $_GET["clientTime"]       . "," .
                     time()                    . "\n";

            break;
        case "initSession":
        case "termSession":
            $file = "../logs/session.csv";
            
            if (!file_exists($file)) {
                $data = "sessionID"             . "," .
                        "analyticsImpressionID" . "," .
                        "userID"                . "," . 
                        "analyticsUserID"       . "," .
                        "remoteAddr"            . "," .
                        "userAgent"             . "," .
                        "clientTime"            . "," .
                        "serverTime"            . "\n";
            }
            
            $data .= $_GET["sessionID"]             . ","   .
                     $_GET["analyticsImpressionID"] . ","   .
                     $_GET["userID"]                . ","   .
                     $_GET["analyticsUserID"]       . ","   .
                     $_SERVER["REMOTE_ADDR"]        . ",\"" .
                     $_GET["userAgent"]             . "\"," .
                     $_GET["clientTime"]            . ","   .
                     time()                         . "\n";
            break;
        default:
            error_log("Invalid context.");
            exit(1);
    }
    
    file_put_contents($file, $data, FILE_APPEND);
?>
