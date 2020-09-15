/*
 * Update network information data.
 */
function updateNWI() {
    // Log data server-side.
    const nwi = navigator.connection;
    
    if (!nwi) {
        console.warn('updateNWI: Network Information API not available');
        return;
    }

    $.ajax({
        type: 'GET',
        url:  './scripts/log.php',
        data: { context:       'updateNWI',
                sessionID:     getCookie('sessionID') || '',
                rtt:           nwi.rtt                || '',
                downlink:      nwi.downlink           || '',
                downlinkMax:   nwi.downlinkMax        || '',
                type:          nwi.type               || '',
                effectiveType: nwi.effectiveType      || '',
                saveData:      nwi.saveData           || '',
                clientTime:    new Date().getTime()   || ''
              }
    });
}
