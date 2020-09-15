/*
  * Update position data.
  */
function updatePosition(position) {
    // Log data server-side.
    $.ajax({
        type: 'GET',
        url:  './scripts/log.php',
        data: {
	    context:          'updatePosition',
            sessionID:        getCookie('sessionID')           || '',
            latitude:         position.coords.latitude         || '',
            longitude:        position.coords.longitude        || '',
            altitude:         position.coords.altitude         || '',
            accuracy:         position.coords.accuracy         || '',
            altitudeAccuracy: position.coords.altitudeAccuracy || '',
            heading:          position.coords.heading          || '',
            speed:            position.coords.speed            || '',
            positionTime:     position.timestamp               || '',
            clientTime:       new Date().getTime()             || ''
        }
    });
}
