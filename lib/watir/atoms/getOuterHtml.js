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


function(){return function(){var d="function"==typeof Object.defineProperties?Object.defineProperty:function(a,b,c){if(c.get||c.set)throw new TypeError("ES3 does not support getters and setters.");a!=Array.prototype&&a!=Object.prototype&&(a[b]=c.value)},g="undefined"!=typeof window&&window===this?this:"undefined"!=typeof global?global:this;
function k(a,b){if(b){for(var c=g,e=a.split("."),h=0;h<e.length-1;h++){var f=e[h];f in c||(c[f]={});c=c[f]}e=e[e.length-1];h=c[e];f=b(h);f!=h&&null!=f&&d(c,e,{configurable:!0,writable:!0,value:f})}}
k("String.prototype.repeat",function(a){return a?a:function(a){var c;if(null==this)throw new TypeError("The 'this' value for String.prototype.repeat must not be null or undefined");c=this+"";if(0>a||1342177279<a)throw new RangeError("Invalid count value");a|=0;for(var e="";a;)if(a&1&&(e+=c),a>>>=1)c+=c;return e}});k("Math.sign",function(a){return a?a:function(a){a=Number(a);return!a||isNaN(a)?a:0<a?1:-1}});var l=this;var p=String.prototype.trim?function(a){return a.trim()}:function(a){return a.replace(/^[\s\xa0]+|[\s\xa0]+$/g,"")};function q(a,b){return a<b?-1:a>b?1:0};var r;a:{var t=l.navigator;if(t){var u=t.userAgent;if(u){r=u;break a}}r=""};var v=-1!=r.indexOf("Opera")||-1!=r.indexOf("OPR"),w=-1!=r.indexOf("Trident")||-1!=r.indexOf("MSIE"),x=-1!=r.indexOf("Edge"),y=-1!=r.indexOf("Gecko")&&!(-1!=r.toLowerCase().indexOf("webkit")&&-1==r.indexOf("Edge"))&&!(-1!=r.indexOf("Trident")||-1!=r.indexOf("MSIE"))&&-1==r.indexOf("Edge"),z=-1!=r.toLowerCase().indexOf("webkit")&&-1==r.indexOf("Edge");
function A(){var a=r;if(y)return/rv\:([^\);]+)(\)|;)/.exec(a);if(x)return/Edge\/([\d\.]+)/.exec(a);if(w)return/\b(?:MSIE|rv)[: ]([^\);]+)(\)|;)/.exec(a);if(z)return/WebKit\/(\S+)/.exec(a)}function B(){var a=l.document;return a?a.documentMode:void 0}var C=function(){if(v&&l.opera){var a;var b=l.opera.version;try{a=b()}catch(c){a=b}return a}a="";(b=A())&&(a=b?b[1]:"");return w&&(b=B(),null!=b&&b>parseFloat(a))?String(b):a}(),D={};
function E(a){if(!D[a]){for(var b=0,c=p(String(C)).split("."),e=p(String(a)).split("."),h=Math.max(c.length,e.length),f=0;!b&&f<h;f++){var N=c[f]||"",O=e[f]||"",P=RegExp("(\\d*)(\\D*)","g"),Q=RegExp("(\\d*)(\\D*)","g");do{var m=P.exec(N)||["","",""],n=Q.exec(O)||["","",""];if(0==m[0].length&&0==n[0].length)break;b=q(0==m[1].length?0:parseInt(m[1],10),0==n[1].length?0:parseInt(n[1],10))||q(0==m[2].length,0==n[2].length)||q(m[2],n[2])}while(!b)}D[a]=0<=b}}
var F=l.document,G=F&&w?B()||("CSS1Compat"==F.compatMode?parseInt(C,10):5):void 0;var H;if(!(H=!y&&!w)){var I;if(I=w)I=9<=Number(G);H=I}H||y&&E("1.9.1");w&&E("9");function J(a){if("outerHTML"in a)return a.outerHTML;var b=(9==a.nodeType?a:a.ownerDocument||a.document).createElement("DIV");b.appendChild(a.cloneNode(!0));return b.innerHTML}var K=["_"],L=l;K[0]in L||!L.execScript||L.execScript("var "+K[0]);for(var M;K.length&&(M=K.shift());){var R;if(R=!K.length)R=void 0!==J;R?L[M]=J:L[M]?L=L[M]:L=L[M]={}};; return this._.apply(null,arguments);}.apply({navigator:typeof window!='undefined'?window.navigator:null,document:typeof window!='undefined'?window.document:null}, arguments);}
