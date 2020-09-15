/*
 * Update QoE score.
 */
function updateQoE(qoeScore) {
    // Write data on the web page.
    let qoeDescription= 'n/a';

    switch(qoeScore) {
        case '1':
            qoeDescription = 'very poor';
            break;
        case '2':
            qoeDescription = 'poor';
            break;
        case '3':
            qoeDescription = 'normal';
            break;
        case '4':
            qoeDescription = 'good';
            break;
        case '5':
            qoeDescription = 'very good';
            break;
    }

    setField('scoreSpan', qoeScore + ' (' + qoeDescription + ')');

    // Log data server-side.
    $.ajax({
        type: 'GET',
        url:  './scripts/log.php',
        data: {
	        context:       'updateQoE',
            sessionID:     getCookie('sessionID') || '',
            qoeScore:      qoeScore               || '',
            clientTime:    new Date().getTime()   || ''
	    }
    });
}
