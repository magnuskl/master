/*
 * Set a cookie.
 */
function setCookie(name, value, days) {
    if (!navigator.cookieEnabled) {
        console.warn('setCookie: Cookies not enabled');
        return;
    }
  
    const now = new Date;
    now.setTime(now.getTime() + 24 * 60 * 60 * 1000 * days);
    document.cookie = name + '=' + value
                           + ';path=/;expires='
                           + now.toGMTString();
}

/*
 * Get a cookie.
 */
function getCookie(name) {
    if (!navigator.cookieEnabled) {
        console.warn('getCookie: Cookies not enabled');
        return;
    }

    const value = document.cookie.match('(^|;) ?' + name + '=([^;]*)(;|$)');
    return value ? value[2] : null;
}

/*
 * Delete a cookie.
 */
function deleteCookie(name) { setCookie(name, '', -1); }

/*
 * Check if a particular cookie is set.
 */
function isSetCookie(name) {
    return getCookie(name) != null ? true : false;
}

/*
 * Generate a UUID (compliant with RFC4122 version 4).
 */ 
function uuidv4() {
    return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
    (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).
    toString(16)
    );
}
