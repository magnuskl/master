/* 
 * Initialize a session.
 */
function initSession() {
    // Cookies
    if (!navigator.cookieEnabled) {
        console.warn('setCookie: Cookies not enabled');
    } else {
        if (isSetCookie('userID')) {
            userID = getCookie('userID');
        } else {
            setCookie('userID', uuidv4(), 365);
        }
        
        setCookie('sessionID', uuidv4());
    }

    // User Agent
    // if ('userAgent' in navigator) {
    //     parseUserAgent(navigator.userAgent);
    // } else {
    //     console.warn('initSession: User agent not available');
    // }

    // Geolocation
    // if ('geolocation' in navigator) {
    //     watch = navigator.geolocation.watchPosition(updatePosition);
    // } else {
    //     console.warn('initSession: Geolocation not available');
    // }

    // Network Information
    updateNWI();

    // Load Video.js configuration
    loadVideoJSConfig();

    // Log data server-side
    $.ajax({
        type: 'GET',
        url:  './scripts/log.php',
        data: {
            context:     'initSession',
            sessionID:   getCookie('sessionID')               || '',
            analyticsImpressionID:
                analytics.analytics.getCurrentImpressionId    || '',
            userID:      getCookie('userID')                  || '',
            analyticsUserID:
                analytics.analytics.sessionHandler._userId    || '',
            //  getCookie('bitmovin_analytics_uuid')          || '',
            userAgent:   navigator.userAgent                  || '',
            clientTime:  new Date().getTime()                 || ''
        }
    });
}

/*
 * End a session
 */
function termSession() {
    // Log data server-side
    $.ajax({
        type: 'GET',
        url:  './scripts/log.php',
        data: {
            context:     'termSession',
            sessionID:   getCookie('sessionID')               || '',
            analyticsImpressionID:
                analytics.analytics.getCurrentImpressionId    || '',
            userID:      '00000000-0000-0000-0000-000000000000',
            analyticsUserID:
                   analytics.analytics.sessionHandler._userId || '',
            // getCookie('bitmovin_analytics_uuid') || 'n/a',
            userAgent:   navigator.userAgent                  || '',
            clientTime:  new Date().getTime()                 || ''
        }
    });
}
