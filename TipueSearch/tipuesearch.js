
/*
Tipue Search 7.1
Copyright (c) 2019 Tipue
Tipue Search is released under the MIT License
http://www.tipue.com/search

Modified slightly by Ron Burkey.  Places where that has been done are marked with the initials RSB.
I can make these changes because I understand the pattern of data that's being fed in.
2019-04-15	Deleted ellipsis ("...") that was being automatically suffixed to the displayed text.
2019-04-16	Modified how the titles were being displayed to make them more verbose and self-explanatory
						without having to increase the size of the downloaded content .js.  Similarly, modified
						how URLs are displayed.
2019-04-18	Accounted for 2-character revision codes, I hope.  (No way to test right now.)
2019-06-11	The title formatting mentioned on 2019-04-16 only works properly for MIT drawing numbers:
						i.e., pure digits followed by "-", "A", ..., "AA", etc.  Various other types which we've
						been getting (mainly MIL and GAEC docs) don't have numbers that follow that pattern, so
						I've had to modify the formatter for those special cases, and may have to modify it in the
						future for other special cases as well.
*/

var milspec = ["DOD", "MIL", "MMM", "FED", "QQ"]; /* RSB */
(function($) {

     $.fn.tipuesearch = function(options) {

          var set = $.extend( {
          
          'contextBuffer'          : 60,
          'contextLength'          : 60,
          'contextStart'           : 90,
          'debug'                  : false,
          'descriptiveWords'       : 25,
          'footerPages'            : 3,
          'highlightTerms'         : true,
          'imageZoom'              : true,
          'minimumLength'          : 3,
          'newWindow'              : false,
          'show'                   : 10,
          'showContext'            : true,
          'showRelated'            : true,
          'showTime'               : true,
          'showTitleCount'         : true,
          'showURL'                : true,
          'wholeWords'             : true
          }, options);
          
          return this.each(function() {
               
               var tipuesearch_t_c = 0;                         
               
               var tipue_search_w = '';
               if (set.newWindow)
               {
                    tipue_search_w = ' target="_blank"';      
               }

               function getURLP(name)
               {
                    var locSearch = location.search;
                    var splitted = (new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(locSearch)||[,""]);
                    var searchString = splitted[1].replace(/\+/g, '%20');
                    try
                    {
                         searchString = decodeURIComponent(searchString);
                    }
                    catch(e)
                    {
                         searchString = unescape(searchString);
                    }
                    return searchString || null;
               }
               
               if (getURLP('q'))
               {
                    $('#tipue_search_input').val(getURLP('q'));
                    getTipueSearch(0, true);
               }               
               
               $(this).keyup(function(event)
               {
                    if(event.keyCode == '13')
                    {
                         getTipueSearch(0, true);
                    }
               });
               

               function getTipueSearch(start, replace)
               {
                    window.scrollTo(0, 0);
                    
                    var out = '';
                    var show_replace = false;
                    var show_stop = false;
                    var standard = true;
                    var c = 0;
                    var found = [];
                    
                    var d_o = $('#tipue_search_input').val();
                    d_o = d_o.replace(/\+/g, ' ').replace(/\s\s+/g, ' ');
 
                    d_o = $.trim(d_o);
                    var d = d_o.toLowerCase();
                    
                    if ((d.match("^\"") && d.match("\"$")) || (d.match("^'") && d.match("'$")))
                    {
                         standard = false;
                    }
                    
                    var d_w = d.split(' ');
                    
                    if (standard)
                    {
                         d = '';
                         for (var i = 0; i < d_w.length; i++)
                         {
                              var a_w = true;
                              for (var f = 0; f < tipuesearch_stop_words.length; f++)
                              {
                                   if (d_w[i] == tipuesearch_stop_words[f])
                                   {
                                        a_w = false;
                                        show_stop = true;          
                                   }
                              }
                              if (a_w)
                              {
                                   d = d + ' ' + d_w[i];
                              }
                         }
                         d = $.trim(d);
                         d_w = d.split(' ');
                    }
                    else
                    {
                         d = d.substring(1, d.length - 1);
                    }
               
                    if (d.length >= set.minimumLength)
                    {
                         if (standard)
                         {
                              if (replace)
                              {
                                   var d_r = d;
                                   for (var i = 0; i < d_w.length; i++)
                                   {
                                        for (var f = 0; f < tipuesearch_replace.words.length; f++)
                                        {
                                             if (d_w[i] == tipuesearch_replace.words[f].word)
                                             {
                                                  d = d.replace(d_w[i], tipuesearch_replace.words[f].replace_with);
                                                  show_replace = true;
                                             }
                                        }
                                   }
                                   d_w = d.split(' ');
                              }                   
                    
                              var d_t = d;
                              for (var i = 0; i < d_w.length; i++)
                              {
                                   for (var f = 0; f < tipuesearch_stem.words.length; f++)
                                   {
                                        if (d_w[i] == tipuesearch_stem.words[f].word)
                                        {
                                             d_t = d_t + ' ' + tipuesearch_stem.words[f].stem;
                                        }
                                   }
                              }
                              d_w = d_t.split(' ');

                              for (var i = 0; i < tipuesearch.pages.length; i++)
                              {
                                   var score = 0;
                                   var s_t = tipuesearch.pages[i].text;
                                   for (var f = 0; f < d_w.length; f++)
                                   {
                                        if (set.wholeWords)
                                        {
                                             var pat = new RegExp('\\b' + d_w[f] + '\\b', 'gi');
                                        }
                                        else
                                        {
                                             var pat = new RegExp(d_w[f], 'gi');
                                        }
                                        if (tipuesearch.pages[i].title.search(pat) != -1)
                                        {
                                             var m_c = tipuesearch.pages[i].title.match(pat).length;
                                             score += (20 * m_c);
                                        }
                                        if (tipuesearch.pages[i].text.search(pat) != -1)
                                        {
                                             var m_c = tipuesearch.pages[i].text.match(pat).length;
                                             score += (20 * m_c);
                                        }
                                        if (tipuesearch.pages[i].tags)
                                        {
                                             if (tipuesearch.pages[i].tags.search(pat) != -1)
                                             {
                                                  var m_c = tipuesearch.pages[i].tags.match(pat).length;
                                                  score += (10 * m_c);
                                             }
                                        }
                                        if (tipuesearch.pages[i].url.search(pat) != -1)
                                        {
                                             score += 20;
                                        }
                                        
                                        if (score != 0)
                                        {
                                             for (var e = 0; e < tipuesearch_weight.weight.length; e++)
                                             {
                                                  if (tipuesearch.pages[i].url == tipuesearch_weight.weight[e].url)
                                                  {
                                                       score += tipuesearch_weight.weight[e].score;
                                                  }
                                             }
                                        }
                                        
                                        if (d_w[f].match('^-'))
                                        {
                                             pat = new RegExp(d_w[f].substring(1), 'i');
                                             if (tipuesearch.pages[i].title.search(pat) != -1 || tipuesearch.pages[i].text.search(pat) != -1 || tipuesearch.pages[i].tags.search(pat) != -1)
                                             {
                                                  score = 0;     
                                             }    
                                        }
                                   }
                                   
                                   if (score != 0)
                                   {
                                        found.push(
                                        {
                                             "score": score,
                                             "title": tipuesearch.pages[i].title,
                                             "desc": s_t,
                                             "img": tipuesearch.pages[i].img, 
                                             "url": tipuesearch.pages[i].url,
                                             "note": tipuesearch.pages[i].note
                                        });
                                        c++;                                                                   
                                   }
                              }
                         }
                         else
                         {
                              for (var i = 0; i < tipuesearch.pages.length; i++)
                              {
                                   var score = 0;
                                   var s_t = tipuesearch.pages[i].text;
                                   var pat = new RegExp(d, 'gi');
                                   if (tipuesearch.pages[i].title.search(pat) != -1)
                                   {
                                        var m_c = tipuesearch.pages[i].title.match(pat).length;
                                        score += (20 * m_c);
                                   }
                                   if (tipuesearch.pages[i].text.search(pat) != -1)
                                   {
                                        var m_c = tipuesearch.pages[i].text.match(pat).length;
                                        score += (20 * m_c);
                                   }
                                   if (tipuesearch.pages[i].tags)
                                   {
                                        if (tipuesearch.pages[i].tags.search(pat) != -1)
                                        {
                                             var m_c = tipuesearch.pages[i].tags.match(pat).length;
                                             score += (10 * m_c);
                                        }
                                   }
                                   if (tipuesearch.pages[i].url.search(pat) != -1)
                                   {
                                        score += 20;
                                   }
                                   
                                   if (score != 0)
                                   {
                                        for (var e = 0; e < tipuesearch_weight.weight.length; e++)
                                        {
                                             if (tipuesearch.pages[i].url == tipuesearch_weight.weight[e].url)
                                             {
                                                  score += tipuesearch_weight.weight[e].score;
                                             }
                                        }
                                   }
                              
                                   if (score != 0)
                                   {
                                        found.push(
                                        {
                                             "score": score,
                                             "title": tipuesearch.pages[i].title,
                                             "desc": s_t,
                                             "img": tipuesearch.pages[i].img,
                                             "url": tipuesearch.pages[i].url,
                                             "note": tipuesearch.pages[i].note
                                        });
                                        c++;                                                                  
                                   }                              
                              }
                         }                         
                         
                         if (c != 0)
                         {
                              if (set.showTitleCount && tipuesearch_t_c == 0)
                              {
                                   var title = document.title;
                                   document.title = '(' + c + ') ' + title;
                                   tipuesearch_t_c++;
                              }                         

                              if (c == 1)
                              {
                                   out += '<div id="tipue_search_results_count">' + tipuesearch_string_4;
                              }
                              else
                              {
                                   var c_c = c.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                                   out += '<div id="tipue_search_results_count">' + c_c + ' ' + tipuesearch_string_5;
                              }
                              if (set.showTime)
                              {
                                   var endTimer = new Date().getTime();
                                   var time = (endTimer - startTimer) / 1000;
                                   out += ' (' + time.toFixed(2) + ' ' + tipuesearch_string_14 + ')';
                                   set.showTime = false;
                              }
                              out += '</div>';
                                   
                              if (set.showRelated && standard)
                              {
                                   var ront = '';
                                   f = 0;
                                   for (var i = 0; i < tipuesearch_related.Related.length; i++)
                                   {
                                        if (d == tipuesearch_related.Related[i].search)
                                        {
                                             if (!f)
                                             {
                                                  out += '<div class="tipue_search_related">' + tipuesearch_string_10 + ': ';
                                             }
                                             if (show_replace)
                                             {
                                                  d_o = d;
                                             }
                                             
                                             if (tipuesearch_related.Related[i].include)
                                             {
                                                  var r_d = d_o + ' ' + tipuesearch_related.Related[i].related;
                                             }
                                             else
                                             {
                                                  var r_d = tipuesearch_related.Related[i].related;
                                             }                                             
                                             
                                             ront += '<a class="tipue_search_related_btn" id="' + r_d + '">' + tipuesearch_related.Related[i].related + '</a>, ';
                                             f++;         
                                        }
                                   }
                                   if (f)
                                   {
                                        ront = ront.slice(0, -2);
                                        ront += '.</div>';
                                        out += ront;
                                   }   
                              }

                              if (show_replace)
                              {
                                   out += '<div id="tipue_search_replace">' + tipuesearch_string_2 + ' ' + d + '. ' + tipuesearch_string_3 + ' <a id="tipue_search_replaced">' + d_r + '</a></div>';
                              }
                              
                              found.sort(function(a, b) { return b.score - a.score } );
                              
                              var l_o = 0;
                              
                              if (set.imageZoom)
                              {
                                   out += '<div id="tipue_search_image_modal"><div class="tipue_search_image_close">&#10005;</div><div class="tipue_search_image_block"><a id="tipue_search_zoom_url"><img id="tipue_search_zoom_img"></a><div id="tipue_search_zoom_text"></div></div></div>';    
                              }
                              
                              for (var i = 0; i < found.length; i++)
                              {
                                   if (l_o >= start && l_o < set.show + start)
                                   {
                                        out += '<div class="tipue_search_result">';
                                        
                                        /* RSB */
                                        /* out += '<div class="tipue_search_content_title"><a href="' + found[i].url + '"' + tipue_search_w + '>' +  found[i].title + '</a></div>'; */
                                        
                                        /* 
                                         * Fix up the search title to be a bit nicer. What's being fed in is 
                                         * NR-T-S-F, and that's a bit too terse ... but I don't want to 
                                         * modify the .js that's feeding in this content, because the file
                                         * is quite big already. Also, in place of simple strings of digits N
                                         * as the drawing number, the following special cases (MIL, GAEC, and 
                                         * others) also need to be handled:
                                         * 		JDCn
                                         * 		LDWn-n
                                         * 		MIL-c-n			(c string of uppercase letters)
                                         * 		MMM-c-n
                                         * 		DOD-c-n
                                         * 		FED-c-n
                                         * 		QQ-c-n
                                         * 		RIB n				(with a space between RIB and n)
                                         */
                                        var title;
																				var drawingFields;
																				var dfStart;
																				/*
																				var splitAt = 8;
																				if (found[i].title[splitAt] != "-")
																					splitAt = 9;
																				title = found[i].title.substring(0, splitAt);
                                        drawingFields = found[i].title.substring(splitAt + 1).split("-");
																				*/
                                        drawingFields = found[i].title.split("-");
                                        dfStart = 1
                                        isSK = false
                                        if (drawingFields[0].substring(0, 3) == "LDW" || drawingFields[0].substring(0, 3) == "LIS") {
                                        	drawingFields[0] = drawingFields[0] + "-" + drawingFields[1]
                                        	dfStart = 2
                                        } else if (drawingFields[0].substring(0,2) == "SK") {
                                        	isSK = true
                                        	drawingFields[0] = drawingFields[0] + "-" + drawingFields[1]
                                        	dfStart = 2
                                        	if (!isNaN(drawingFields[2])) {
                                        		drawingFields[0] = drawingFields[0] + "-" + drawingFields[2]
                                        		dfStart = 3
                                        	}
                                   			} else if (milspec.includes(drawingFields[0])) {
                                        	drawingFields[0] = drawingFields[0] + "-" + drawingFields[1] + "-" + drawingFields[2]
                                        	dfStart = 3
                                   			}
                                        if (drawingFields[dfStart] == "")	{ /* Rev "-"? */
                                        	drawingFields[0] += "-"
                                        	dfStart += 1
                                        }
                                        title = drawingFields[0]
                                        if (isSK) {
                                        	rev = title.slice(-6)
                                        	title = title.substring(0, title.length - 6)
                                        } else {
	                                        var maybeRev = title.charAt(title.length - 2)
	                                        if (maybeRev >= "A" && maybeRev <= "Z") {
	                                        	rev = title.slice(-2)
	                                        	title = title.substring(0, title.length - 2)
	                                        } else {
	                                        	rev = title.slice(-1)
	                                        	title = title.substring(0, title.length - 1)
	                                        }
                                        }
                                        title += " rev \"" + rev + "\""
                                        /*drawingFields.splice(0, 1)*/
                                        if (drawingFields[dfStart] == "1")
                                        	title += ", drawing";
                                        else if (drawingFields[dfStart] == "2")
                                        	title += ", test requirements";
                                        else
                                        	title += ", type " + drawingFields[dfStart];
                                        title += ", sheet " + drawingFields[dfStart + 1] + ", frame " + drawingFields[dfStart + 2]
                                        
                                        /* Output the pepped up title. */
                                        out += '<div class="tipue_search_content_title"><a href="' + found[i].url + '"' + tipue_search_w + '>' +  title + '</a></div>';
                                        /* /RSB */
                                                                           
                                        if (set.debug)
                                        {                                             
                                             out += '<div class="tipue_search_content_debug">Score: ' + found[i].score + '</div>';
                                        }
                                        
                                        if (set.showURL)
                                        {
                                             var s_u = found[i].url.toLowerCase();
                                             
                                             /* RSB */
                                             /*
                                              * What Tipue Search wants to display as the URL (namely, the actual URL)
                                              * is too big and complex.  We want to tone it down to be just informative
                                              * enough without overwhelming.  Most of the URLs are from archive.org,
                                              * but some are from ibiblio.org, and the two need to be processed differently.
                                              */
                                             var fields = s_u.split("/");
                                             if (fields[0] == "http:" || fields[0] == "https:")
                                            	 fields = fields.splice(2);
                                             if (fields[0].substring(0,4) == "www.")
                                            	 fields[0] = fields[0].substring(4);
                                             if (fields[0] == "archive.org") {
                                            	 var pageNumber
                                            	 var group
                                            	 var n = fields[2].search("#");
                                            	 if (n < 0) {
                                            		 group = fields[2]
                                            		 if (fields.length >= 5)
                                            			 pageNumber = fields[4].substring(1)
                                            		 else
                                            			 pageNumber = "1"
                                            	 } else {
                                            		 group = fields[2].substring(0,n)
                                            		 pageNumber = fields[3].substring(1)
                                            	 }
                                            	 s_u = "Internet Archive virtualagcproject, " + group + ", page " + pageNumber;
                                             } else {
                                            	 var n = s_u.search("/apollo/");
                                            	 if (n >= 0)
                                            		 s_u = "Virtual AGC site, " + s_u.substring(n + 8);
                                             }
                                             
                                             /* /RSB */
                                             
                                             if (s_u.indexOf('http://') == 0)
                                             {
                                                  s_u = s_u.slice(7);
                                             }     
                                             
                                             out += '<div class="tipue_search_content_url"><a href="' + found[i].url + '"' + tipue_search_w + '>' + s_u + '</a></div>';
                                        }
                                        
                                        if (found[i].img)
                                        {
                                             if (set.imageZoom)
                                             {
                                                  out += '<div class="tipue_search_image"><img class="tipue_search_img tipue_search_image_zoom" src="' + found[i].img + '" alt="' + found[i].title + '" data-url="' + found[i].url + '"></div>';     
                                             }
                                             else
                                             {
                                                  out += '<div class="tipue_search_image"><a href="' + found[i].url + '"' + tipue_search_w + '><img class="tipue_search_img" src="' + found[i].img + '" alt="' + found[i].title + '"></a></div>';
                                             }
                                        }
                                        
                                        if (found[i].desc)
                                        {                                        
                                             var t = found[i].desc;

                                             if (set.showContext)
                                             {
                                                  d_w = d.split(' ');
                                                  var s_1 = found[i].desc.toLowerCase().indexOf(d_w[0]);
                                                  if (s_1 > set.contextStart)
                                                  {
                                                       var t_1 = t.substr(s_1 - set.contextBuffer);
                                                       var s_2 = t_1.indexOf(' ');
                                                       t_1 = t.substr(s_1 - set.contextBuffer + s_2);
                                                       t_1 = $.trim(t_1);
                                                       
                                                       if (t_1.length > set.contextLength)
                                                       {                                                      
                                                            t = '... ' + t_1;
                                                       }
                                                  }   
                                             }
                                             
                                             if (standard)
                                             {
                                                  d_w = d.split(' ');
                                                  for (var f = 0; f < d_w.length; f++)
                                                  {
                                                       if (set.highlightTerms)
                                                       {
                                                            var patr = new RegExp('(' + d_w[f] + ')', 'gi');
                                                            t = t.replace(patr, "<h0011>$1<h0012>");
                                                       }
                                                  }
                                             }
                                             else if (set.highlightTerms)
                                             {
                                                  var patr = new RegExp('(' + d + ')', 'gi');
                                                  t = t.replace(patr, "<span class=\"tipue_search_content_bold\">$1</span>");
                                             }
                                                                                  
                                             var t_d = '';
                                             var t_w = t.split(' ');
                                             if (t_w.length < set.descriptiveWords)
                                             {
                                                  t_d = t;
                                             }
                                             else
                                             {
                                                  for (var f = 0; f < set.descriptiveWords; f++)
                                                  {
                                                       t_d += t_w[f] + ' '; 	
                                                  }
                                             }
                                             t_d = $.trim(t_d);
                                             /* RSB
                                             if (t_d.charAt(t_d.length - 1) != '.')
                                             {
                                                  t_d += ' ...';
                                             }
                                             */
                                             
                                             t_d = t_d.replace(/h0011/g, 'span class=\"tipue_search_content_bold\"');
                                             t_d = t_d.replace(/h0012/g, '/span');
                                             
                                             out += '<div class="tipue_search_content_text">' + t_d + '</div>';
                                        }
                                        
                                        if (found[i].note)
                                        {
                                             out += '<div class="tipue_search_note">' + found[i].note + '</div>';    
                                        }                                       
                                        
                                        out += '</div>';
                                   }
                                   l_o++;     
                              }                              

                              if (c > set.show)
                              {
                                   var pages = Math.ceil(c / set.show);
                                   var page = (start / set.show);
                                   if (set.footerPages < 3)
                                   {
                                        set.footerPages = 3;
                                   }
                                   
                                   out += '<div id="tipue_search_foot"><ul id="tipue_search_foot_boxes">';
                                   
                                   if (start > 0)
                                   {
                                       out += '<li role="navigation"><a class="tipue_search_foot_box" accesskey="b" id="' + (start - set.show) + '_' + replace + '">' + tipuesearch_string_6 + '</a></li>'; 
                                   }
                                                       
                                   if (page <= 2)
                                   {
                                        var p_b = pages;
                                        if (pages > set.footerPages)
                                        {
                                             p_b = set.footerPages;
                                        }                    
                                        for (var f = 0; f < p_b; f++)
                                        {
                                             if (f == page)
                                             {
                                                  out += '<li class="current" role="navigation">' + (f + 1) + '</li>';
                                             }
                                             else
                                             {
                                                  out += '<li role="navigation"><a class="tipue_search_foot_box" id="' + (f * set.show) + '_' + replace + '">' + (f + 1) + '</a></li>';
                                             }
                                        }
                                   }
                                   else
                                   {
                                        var p_b = page + set.footerPages - 1;
                                        if (p_b > pages)
                                        {
                                             p_b = pages; 
                                        }
                                        for (var f = page - 1; f < p_b; f++)
                                        {
                                             if (f == page)
                                             {
                                                  out += '<li class="current" role="navigation">' + (f + 1) + '</li>';
                                             }
                                             else
                                             {
                                                  out += '<li role="navigation"><a class="tipue_search_foot_box" id="' + (f * set.show) + '_' + replace + '">' + (f + 1) + '</a></li>';
                                             }
                                        }
                                   }                         
                                                      
                                   if (page + 1 != pages)
                                   {
                                       out += '<li role="navigation"><a class="tipue_search_foot_box" accesskey="m" id="' + (start + set.show) + '_' + replace + '">' + tipuesearch_string_7 + '</a></li>'; 
                                   }                    
                                   
                                   out += '</ul></div>';
                              }

                         }
                         else
                         {
                              out += '<div id="tipue_search_error">' + tipuesearch_string_8 + '</div>'; 
                         }
                    }
                    else
                    {
                         if (show_stop)
                         {
                              out += '<div id="tipue_search_error">' + tipuesearch_string_8 + ' ' + tipuesearch_string_9 + '</div>';     
                         }
                         else
                         {
                              if (set.minimumLength == 1)
                              {
                                   out += '<div id="tipue_search_error">' + tipuesearch_string_11 + '</div>';
                              }
                              else
                              {
                                   out += '<div id="tipue_search_error">' + tipuesearch_string_12 + ' ' + set.minimumLength + ' ' + tipuesearch_string_13 + '</div>';
                              }
                         }
                    }                
                    
                    $('#tipue_search_content').hide().html(out).slideDown(200);
                    
                    $('#tipue_search_replaced').click(function()
                    {
                         getTipueSearch(0, false);
                    });
                    
                    $('.tipue_search_related_btn').click(function()
                    {
                         $('#tipue_search_input').val($(this).attr('id'));
                         getTipueSearch(0, true);
                    });
                    
                    $('.tipue_search_image_zoom').click(function()
                    {
                         $('#tipue_search_image_modal').fadeIn(300);
                         $('#tipue_search_zoom_img').attr('src', this.src);
                         
                         var z_u = $(this).attr('data-url');
                         $('#tipue_search_zoom_url').attr('href', z_u);
                         
                         var z_o = this.alt + '<div class="tipue_search_zoom_options"><a href="' + this.src + '" target="_blank">' + tipuesearch_string_15 + '</a>&nbsp; <a href="' + z_u + '">' + tipuesearch_string_16 + '</a></div>';
                         
                         $('#tipue_search_zoom_text').html(z_o);
                    });
                    
                    $('.tipue_search_image_close').click(function()
                    {
                         $('#tipue_search_image_modal').fadeOut(300);
                    });                
               
                    $('.tipue_search_foot_box').click(function()
                    {
                         var id_v = $(this).attr('id');
                         var id_a = id_v.split('_');
                    
                         getTipueSearch(parseInt(id_a[0]), id_a[1]);
                    });                                                       
               }          
          
          });
     };
   
})(jQuery);
