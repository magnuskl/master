let player = null; // Video.js player object
let vjsConfig = null; // Video.js configuration object

function loadVideoJSConfig() {
    vjsConfig = {
        // Standard video element options
        'autoplay':        true,
        'loop':            true,
        'muted':           true,
        'preload':        'auto',
        'controls':        true,
        'dblclick':        false,
        // Video.js specific options
        'responsive':      true,
        'liveui':          true,
        'fill':            true,
        'poster':         'poster.png',
        'sources': [{
            // 'type': 'application/dash+xml',
            // 'src':  './livestream/out.mpd'
            // }, {
            // 'type':    'application/x-mpegURL',
            // 'src':     './livestream/master.m3u8'
            // }, {
            'type': 'video/mp4',
            'src':  './assets/video.mp4'
            // }, {
            }],
        'plugins': {
            'vr': {
               'projection':     'FISHEYE_WALL',
               'motionControls':  false,
            }
        },
        'controlBar': {
            // Crashes videojs-vr on Safari on iOS if false.
            'fullscreenToggle':       true,
            'pictureInPictureToggle': false,
        },
        'html5': {
            'hls': {
                'overrideNative': true,
                'debug':          true
            }
        }
    };

    // analyticsConfig = {
    //     'key':            '0bb3e735-7464-4e5e-86a4-6458b437eb65',
    //     'userId':          getCookie('userID')          || 'n/a',
    //     'customData1':     getCookie('sessionID')       || 'n/a',
    //     'customData2':     navigator.userAgent          || 'n/a',
    //     // 'customData3': ''
    //     // 'customData4': ''
    //     // 'customData5': ''
    // };

    player = videojs('player', vjsConfig);
    // analytics = bitmovin.analytics.adapters.VideojsAdapter
    //     (analyticsConfig, player);

    // player.vr();
    // player.qualityLevels();
    // player.hlsQualitySelector();
}

loadVideoJSConfig();
