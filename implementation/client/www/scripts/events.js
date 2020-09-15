// Event listeners
window.addEventListener('load',
    function() {
        console.log('event: Initialize session');
        initSession();
    });

window.addEventListener('beforeunload',
    function() {
        console.log('event: Terminate session');
        termSession();
    });

window.addEventListener('unload',
    function() {
        console.log('event: Terminate session');
        termSession();
    });

/*
qoeRange.addEventListener('input',
    function() {
        // console.log('event: Update QoE score (' + qoeRange.value + ')');
        updateQoE(qoeRange.value);
    });
*/
