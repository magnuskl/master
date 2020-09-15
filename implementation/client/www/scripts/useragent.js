/*
 * Parse a full user agent string into human-readable form.
 */
function parseUserAgent(fullUserAgent) {
    const xhttp = new XMLHttpRequest();
    const endpoint = 'https://api.whatismybrowser.com/api/v2/user_agent_parse';
    const apiKey = '312a75e595dea88a28907f8d88e0eeb9';
    const body = { 'user_agent' : fullUserAgent };

    if (!xhttp) {
        console.warn('parseUserAgent: XML HTTP request not available');
        return;
    }
    
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            const response = JSON.parse(this.response);
            const simpleUserAgent = response.parse.simple_software_string;
        }
    }
    
    xhttp.open ('POST', endpoint, true);
    xhttp.setRequestHeader('Content-Type', 'application/json');
    xhttp.setRequestHeader('X-API-KEY', apiKey);
    xhttp.send(JSON.stringify(body));
}
