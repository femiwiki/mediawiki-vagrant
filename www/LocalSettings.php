<?php

require_once "LocalSettings.base.php";

# URL config
$wgScriptPath = "";
$wgArticlePath = "/w/$1";
$wgResourceBasePath = $wgScriptPath;
$wgEnableCanonicalServerLink = true;

# Client-side cache management
$wgStyleVersion = '20170106_2';
$wgResourceLoaderMaxage = array(
    'versioned' => array(
        // Squid/Varnish but also any other public proxy cache between the client and MediaWiki
        'server' => 90 * 24 * 60 * 60, // 90 days
        // On the client side (e.g. in the browser cache).
        'client' => 90 * 24 * 60 * 60, // 90 days
    ),
    'unversioned' => array(
        'server' => 3 * 60, // 3 mins
        'client' => 3 * 60, // 3 mins
    ),
);

# Server-side cache management
$wgMainCacheType = CACHE_ACCEL;
$wgCacheDirectory = "/opt/__WIKI_ID__/cache";
$wgUseFileCache = true;

# Upload
$wgEnableUploads = true;
$wgUseInstantCommons = true;

# Locale
$wgLanguageCode = "ko";
$wgLocaltimezone = "Asia/Seoul";

# Default user preferences
$wgEnotifUserTalk = true;

# Misc.
$wgEmergencyContact = "__WIKI_ADMIN_EMAIL__";
$wgPasswordSender = "__WIKI_ADMIN_EMAIL__";
$wgDefaultUserOptions['numberheadings'] = 1;

# Restbase
$wgVirtualRestConfig['modules']['restbase'] = array(
    // RESTBase server URL (string)
    'url' => 'http://__DOMAIN__:7231',
    // Wiki domain to use (string)
    'domain' => '__DOMAIN__',
    // request timeout in seconds (integer or null, optional)
    'timeout' => 100,
    // cookies to forward to RESTBase/Parsoid (string or false, optional)
    'forwardCookies' => false,
    // HTTP proxy to use (string or null, optional)
    'HTTPProxy' => null,
    // whether to parse URL as if they were meant for Parsoid (boolean, optional)
    'parsoidCompat' => false,
);

# Extensions
## VisualEditor
wfLoadExtension( 'VisualEditor' );
$wgVisualEditorSupportedSkins[] = 'femiwiki';
$wgDefaultUserOptions['visualeditor-enable'] = 1;
$wgHiddenPrefs[] = 'visualeditor-enable';
$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;
#$wgVisualEditorRestbaseURL = 'http://__DOMAIN__:7231/__DOMAIN__/v1/page/html/';
#$wgVisualEditorFullRestbaseURL = 'http://__DOMAIN__:7231/__DOMAIN__/';

?>
