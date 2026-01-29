/* Google search bar for site.  Maintain this custom search or others
 * by logging into google with my account and going to 
 * https://cse.google.com/cse/all.  If you're not me, and if I never
 * told you that you are then you're probably not, I can assign other
 * google users to be able to maintain the URLs for the searches. */
if (typeof ignoreGcse == 'undefined') {
	(function() {
	  var cx = '005579885767466475821:oqt5wpxqlt8';
	  var gcse = document.createElement('script');
	  gcse.type = 'text/javascript';
	  gcse.async = true;
	  gcse.src = 'https://cse.google.com/cse.js?cx=' + cx;
	  var s = document.getElementsByTagName('script')[0];
	  s.parentNode.insertBefore(gcse, s);
	})();
}

/* Add a new stylesheet, main.css.  This way I don't have to edit every single 
   HTML file. */
const linkElement = document.createElement("link");
linkElement.setAttribute("rel", "stylesheet");
linkElement.setAttribute("href", "main.css");
linkElement.setAttribute("type", "text/css");
document.head.appendChild(linkElement);

/* Get the logo URL. */
var date = new Date();
var dayOfMonth = date.getDate();
var logoIndex = dayOfMonth % 3;
var logo;
if (logoIndex == 1) logo = "ApolloPatchD.png";
else if (logoIndex == 2) logo = "ApolloPatchC.png";
else logo = "ApolloPatchA.png";

/* Template for the page's header.  You just have to substitute
   for @TITLE@ and @SUBTITLE@ and then print the result at the
   top of the <body>. */
headerTemplate = '<table summary="" nosave="" width="100%" border="1" cellpadding="10">' 
  + '<tbody>' 
  + '<tr nosave="">' 
  + '<td nosave="" align="center" valign="middle">' 
  + '<div align="center"> </div>' 
  + '<center>' 
  + '<div align="center"> </div>' 
  + '<table summary="" nosave="" width="100%">' 
  + '<tbody>' 
  + '<tr nosave="">' 
  + '<td nosave="" align="center" valign="middle">' 
  + '<div align="center"> </div>' 
  + '<table summary="" nosave="">' 
  + '<tbody>' 
  + '<tr align="center">' 
  + '<td><a href="index.html"><small>Home (AGC)</small></a><br>' 
  + '</td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="yaAGS.html"><small>AGS</small>' + '</a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="LVDC.html"><small>LVDC</small></a><br>' 
  + '</td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="Gemini.html"><small>Gemini</small></a><br>' 
  + '</td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td> <a href="download.html"><small>Downloads</small></a>' 
  + '</td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td> <a href="changes.html"><small>Change log</small></a>' 
  + '</td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td> <a href="https://github.com/rburkey2005/virtualagc/issues"><small>Bug and issues</small></a> </td>' 
  + '</tr>' 
  + '<tr nosave="" align="center">' 
  + '<td nosave=""> <a href="developer.html"><small>Developer info<small></a> </td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td valign="top"><a href="https://github.com/rburkey2005/virtualagc"><small>Code repository</small></a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td valign="top"><a href="https://archive.org/details/virtualagcproject"><small>Archival scans</small></a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td valign="top"><a href="Shuttle.html"><small>Space Shuttle</small></a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td> <a href="links2.html"><small>Main library</small></a> </td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td valign="top"><a href="links-shuttle.html"><small>Shuttle Library</small></a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td> <a href="links-probes.html"><small>Probe library</small></a> </td>' 
  + '</tr>' 
  + '</tbody>' 
  + '</table>' 
  + '<div align="center"> </div>' 
  + '</td>' 
  + '<td nosave="" align="center" valign="top">' 
  + '<center><b><font color="#999900"><font size="+3">The Virtual AGC Project<br>Spaceborne Computer Systems</font></font></b></center>' 
  + '<br>' 
  + '<b><font color="#000000"><font size="+3">@TITLE@<br>' 
  + '<small>@SUBTITLE@</small><br>' 
  + '<br>' 
  + '</font></font></b></td>' 
  + '<td nosave="" align="center" valign="middle">' 
  + '<div align="center"> </div>' 
  + '<table summary="" nosave="">' 
  + '<tbody>' 
  + '<tr align="center">' 
  + '<td style="vertical-align: top;"><a href="faq.html"><small>FAQ</small></a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="yaAGC.html"><small>yaAGC</small></a></td>' 
  + '</tr>' 
  + '<tr nosave="" align="center">' 
  + '<td nosave=""><a href="yaYUL.html"><small>yaYUL</small></a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="yaDSKY.html"><small>yaDSKY</small></a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="yaTelemetry.html"><small>yaOtherStuff<small></a><br>' 
  + '</td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="Luminary.html"><small>Luminary</small></a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="Colossus.html"><small>Colossus</small><br>' 
  + '</a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="Block1.html"><small>Block 1 AGC</small></a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td style="vertical-align: top;"><small><a href="assembly_language_manual.html">Block 2 AGC Language</a></small><br>' 
  + '</td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="ElectroMechanical.html"><small>Electrical and Mechanical<small><br>' 
  + '</a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="Pultorak.html"><small>Physical Implementations<small><br>' 
  + '</a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="DIY.html"><small>Do It Yourself<small><br>' 
  + '</a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td><a href="Restoration.html"><small>The Restoration<small><br>' 
  + '</a></td>' 
  + '</tr>' 
  + '<tr align="center">' 
  + '<td></td>' 
  + '</tr>' 
  + '</tbody>' 
  + '</table>' 
  + '<div align="center"> </div>' 
  + '</td>' 
  + '</tr>' 
  + '</tbody>' 
  + '</table>' 
  + '<div align="center"> </div>' 
  + '</center>' 
  + '<center>' 
  + '<div align="left"> </div>' 
  + '</center>' 
  + '<div align="left"> </div>' 
  + '</td>' 
  + '<td nosave="" align="center" height="200" valign="middle" width="200">' 
  + '<center><img src="' + logo + '" alt="" align="middle" height="200" hspace="0" vspace="0" width="200" border="0"> </center>' 
  + '</td>' 
  + '</tr>';
if (typeof ignoreGcse == 'undefined') {
	headerTemplate 	+= '<tr>' 
		+ '<td colspan="2" rowspan="1"><gcse:search></gcse:search><br>' 
		+ '</td>' 
		+ '</tr>';
}
headerTemplate += '</tbody>' 
  + '</table>';

/* 
 * The following function is only used for host https://virtualagc.github.io/virtualagc
 * and for local browsing.  On that "staging" version of the website and locally, there 
 * are no directories like Documents, Downloads, hrst, klabs, etc., and so references to 
 * them need to be redirected to https://www.ibiblio.org/apollo + whatever.  We simply
 * loop through all of the links in the page, and if any of them are to one of the
 * affected subdirectories, we prefix the href properly.  The single variable
 * named "correctHost" can be changed if we need to move from ibiblio.org for some
 * reason.
 */
correctHost = "https://www.ibiblio.org/apollo"
var retargetedFolders = [ "/OnnoHommes/",
                          "/AlessandroCinqueman/",
                          "/DimitrisVitoris/",
                          "/WebMirror/",
                          "/FabrizioPresentationPhotos/",
                          "/hrst/",
                          "/NARASWoverflow/",
                          "/Pultorak_files/",
                          "/Downloads/",
                          "/Artemis072Scans/",
                          "/NARA-SW/",
                          "/ScansForConversion/",
                          "/Documents/",
                          "/RileyRainey/",
                          "/YUL/",
                          "/ApolloProjectOnline/",
                          "/doc/",
                          "/klabs/",
                          "/AGCHandbook/",
                          "/KiCad/",
                          "/NARA-aperture-cards/"
]
var numRetargets = retargetedFolders.length
window.onload = function() {
	/*alert('"' + window.location.hostname + '"')*/
	if (window.location.hostname != "virtualagc.github.io" && window.location.hostname != "") 
		return
	var i, j
	var links = document.links
	var numLinks = links.length
	/*
	if (window.location.hostname == "")
		correctHost += "/"
	*/
	for (i = 0; i < numLinks; i++) {
		if ("href" in links[i]) {
			for (j = 0; j < numRetargets; j++) {
				var index = links[i].href.indexOf(retargetedFolders[j])
				if (index >= 0) {
					links[i].href = correctHost + links[i].href.substring(index)
					break
				}
			}
		}
	}
	var images = document.images
	var numImages = images.length
	for (i = 0; i < numImages; i++) {
		if ("src" in images[i]) {
			for (j = 0; j < numRetargets; j++) {
				var index = images[i].src.indexOf(retargetedFolders[j])
				if (index >= 0) {
					images[i].src = correctHost + images[i].src.substring(index)
					break
				}
			}
		}
	}
}

/*
	A button for toggling between "read more" and "read less".  To use
	it, just embed the block of HTML to which you want to add
	a READ MORE button between the following two lines of HTML:
	
	  <span id="moreUNIQUEID" style="display:none">
	  </span><br><button onclick="toggleMore('UNIQUEID')" id="buttonUNIQUEID">Read more</button>
		
	Of course, where it says UNIQUEID here (3 places), you use 
	a unique ID string for each block which you're doctoring up 
	in this manner.
*/
function toggleMore(basename) {
	var more = document.getElementById("more" + basename);
	var button = document.getElementById("button" + basename);
	if (more.style.display === "none") {
		button.innerHTML = "Read less";
		more.style.display = "inline";
	} else {
		button.innerHTML = "Read more";
		more.style.display = "none";
	}
}

