// ƒuƒ‰ƒEƒU”»•Ê‚É‚æ‚éCSSU‚è•ª‚¯

str = navigator.appName.toUpperCase();

if(str.indexOf("NETSCAPE") >= 0)
    document.write("<link rel='stylesheet' type='text/css' href='./css/style_NS.css'>");
else
    document.write("<link rel='stylesheet' type='text/css' href='./css/style_IE.css'>");

