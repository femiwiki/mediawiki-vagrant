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
$wgMemCachedServers = [
    "127.0.0.1:11000"
];

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
## BetaFeatures
wfLoadExtension( 'BetaFeatures' );

## Cite
wfLoadExtension( 'Cite' );

## CodeEditor
wfLoadExtension( 'CodeEditor' );
$wgCodeEditorEnableCore = true;
$wgScribuntoUseCodeEditor = true;
$wgScribuntoUseGeSHi = true;

## Description2
require_once "$IP/extensions/Description2/Description2.php";

## Echo
require_once "$IP/extensions/Echo/Echo.php";

## EmbedVideo
wfLoadExtension( 'EmbedVideo' );

## GoogleRichCards
require_once "$IP/extensions/GoogleRichCards/GoogleRichCards.php";

## Flow
require_once "$IP/extensions/Flow/Flow.php";
$wgFlowEditorList = array( 'visualeditor', 'none' );
$wgFlowContentFormat = 'html';
$wgNamespaceContentModels[NS_TALK] = 'flow-board';
$wgNamespaceContentModels[NS_USER_TALK] = 'flow-board';

## OpenGraphMeta
require_once( "$IP/extensions/OpenGraphMeta/OpenGraphMeta.php" );

## ParserFunction
wfLoadExtension( 'ParserFunctions' );
$wgPFEnableStringFunctions = true;

## Renameuser
wfLoadExtension( 'Renameuser' );

## Scribunto
require_once "$IP/extensions/Scribunto/Scribunto.php";
$wgScribuntoDefaultEngine = 'luastandalone';
$wgScribuntoUseGeSHi = true;
$wgScribuntoUseCodeEditor = true;

## SimpleMathJax
require_once "$IP/extensions/SimpleMathJax/SimpleMathJax.php";

## SyntaxHighlight_GeSHi
wfLoadExtension( 'SyntaxHighlight_GeSHi' );

## Thanks
wfLoadExtension( 'Thanks' );

## UserMerge
wfLoadExtension( 'UserMerge' );

## VisualEditor
wfLoadExtension( 'VisualEditor' );
$wgVisualEditorSupportedSkins[] = 'femiwiki';
$wgVisualEditorAvailableNamespaces = array(
    NS_SPECIAL => true,
    NS_MAIN => true,
    NS_TALK => true,
    NS_USER => true,
    NS_USER_TALK => true,
    NS_PROJECT => true,
    NS_PROJECT_TALK => true,
    NS_HELP => true,
    NS_HELP_TALK => true,
    "_merge_strategy" => "array_plus",
);
$wgDefaultUserOptions['visualeditor-enable'] = 1;
$wgHiddenPrefs[] = 'visualeditor-enable';
$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;
$wgVirtualRestConfig['modules']['parsoid'] = array(
    'url' => 'http://__PARSOID_DOMAIN__:8142',
    'domain' => '__DOMAIN__',
    'prefix' => '__DOMAIN__',
);

## WikiEditor
wfLoadExtension( 'WikiEditor' );
$wgDefaultUserOptions['usebetatoolbar'] = 1;
$wgDefaultUserOptions['usebetatoolbar-cgd'] = 1;
$wgDefaultUserOptions['wikieditor-preview'] = 1;
$wgDefaultUserOptions['wikieditor-publish'] = 1;

# Femiwiki specifics
## Skin
$wgLogo = "$wgResourceBasePath/skins/Femiwiki/images/logo-1200-630.png";
$wgDefaultSkin = "femiwiki";
wfLoadSkin("Femiwiki");

## BBS
define("NS_BBSFREE", 3902);
define("NS_BBSFREE_TALK", 3903);
$wgExtraNamespaces[NS_BBSFREE] = "자유게시판";
$wgExtraNamespaces[NS_BBSFREE_TALK] = "자유게시판토론";
$wgContentNamespaces[] = NS_BBSFREE;

## Permission
$wgGroupPermissions['*']['createaccount'] = true;
$wgGroupPermissions['bureaucrat']['usermerge'] = true;
$wgGroupPermissions['bureaucrat']['renameuser'] = true;
$wgGroupPermissions['sysop']['deletelogentry'] = true;
$wgGroupPermissions['sysop']['deleterevision'] = true;

$wgGroupPermissions['*']['edit'] = false;

$wgGroupPermissions['user']['edit'] = true;
$wgGroupPermissions['seeder']['edit'] = true;
$wgGroupPermissions['bureaucrat']['edit'] = true;

## Copyright
$wgRightsPage = "페미위키:저작권";
$wgRightsUrl = "https://creativecommons.org/licenses/by-sa/4.0/deed.ko";
$wgRightsText = "CCL 저작자표시-동일조건변경허락 4.0 국제 라이선스";
$wgRightsIcon = "$wgResourceBasePath/resources/assets/licenses/cc-by-sa.png";

?>
