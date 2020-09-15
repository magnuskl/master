// Globals
let player = null; // Video.js player object
let analytics = null; // Bitmovin Analytics object
let watch = null; // HTML5 geolocation watch object
let vjsConfig = null; // Video.js configuration object
let analyticsConfig = null; // Bitmovin Analytics configuration object
let qoeRange = document.getElementById('qoeRange'); // QoE range object

/*
 * Set a field on the web page.
 */
function setField(id, value) {
    const element = document.getElementById(id);

    if (!element) {
        console.warn('setField: Element not found.');
        return;
    }

    document.getElementById(id).innerHTML = value ? value : 'n/a';
}
