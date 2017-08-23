// Copyright 2011 Software Freedom Conservatory
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// This code is a modification getOuterHtml.js which was built by the Selenium code base

function(){return function(){var d=this;function e(a,b){function c(){}c.prototype=b.prototype;a.b=b.prototype;a.prototype=new c};function f(a){this.stack=Error().stack||"";if(a)this.message=String(a)}e(f,Error);function i(a){for(var b=1;b<arguments.length;b++){var c=String(arguments[b]).replace(/\$/g,"$$$$");a=a.replace(/\%s/,c)}return a}
function j(a,b){var c=0,A=String(a).replace(/^[\s\xa0]+|[\s\xa0]+$/g,"").split("."),B=String(b).replace(/^[\s\xa0]+|[\s\xa0]+$/g,"").split("."),H=Math.max(A.length,B.length);for(var l=0;c==0&&l<H;l++){var I=A[l]||"",J=B[l]||"",K=RegExp("(\\d*)(\\D*)","g"),L=RegExp("(\\d*)(\\D*)","g");do{var g=K.exec(I)||["","",""],h=L.exec(J)||["","",""];if(g[0].length==0&&h[0].length==0)break;c=k(g[1].length==0?0:parseInt(g[1],10),h[1].length==0?0:parseInt(h[1],10))||k(g[2].length==0,h[2].length==0)||k(g[2],h[2])}while(c==
0)}return c}function k(a,b){if(a<b)return-1;else if(a>b)return 1;return 0};e(function(a,b){b.unshift(a);f.call(this,i.apply(null,b));b.shift();this.a=a},f);var m,n,o,p;function q(){return d.navigator?d.navigator.userAgent:null}p=o=n=m=false;var r;if(r=q()){var s=d.navigator;m=r.indexOf("Opera")==0;n=!m&&r.indexOf("MSIE")!=-1;o=!m&&r.indexOf("WebKit")!=-1;p=!m&&!o&&s.product=="Gecko"}var t=n,u=p,v=o,w;
a:{var x="",y;if(m&&d.opera){var z=d.opera.version;x=typeof z=="function"?z():z}else{if(u)y=/rv\:([^\);]+)(\)|;)/;else if(t)y=/MSIE\s+([^\);]+)(\)|;)/;else if(v)y=/WebKit\/(\S+)/;if(y){var C=y.exec(q());x=C?C[1]:""}}if(t){var D,E=d.document;D=E?E.documentMode:undefined;if(D>parseFloat(x)){w=String(D);break a}}w=x}var F={};!t||F["9"]||(F["9"]=j(w,"9")>=0);t&&(F["9"]||(F["9"]=j(w,"9")>=0));function G(a){if("textcontent"in a)return a.textContent;else{var b=(a.nodeType==9?a:a.ownerDocument||a.document).createElement("div");b.appendChild(a.cloneNode(true));return b.textContent}}var M="_".split("."),N=d;!(M[0]in N)&&N.execScript&&N.execScript("var "+M[0]);for(var O;M.length&&(O=M.shift());)if(!M.length&&G!==undefined)N[O]=G;else N=N[O]?N[O]:N[O]={};; return this._.apply(null,arguments);}.apply({navigator:typeof window!='undefined'?window.navigator:null}, arguments);}
