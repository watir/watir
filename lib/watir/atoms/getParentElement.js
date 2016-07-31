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

function(){return function(){var d=this;function e(a,b){function c(){}c.prototype=b.prototype;a.g=b.prototype;a.prototype=new c};function g(a){for(var b=1;b<arguments.length;b++)var c=String(arguments[b]).replace(/\$/g,"$$$$"),a=a.replace(/\%s/,c);return a}function h(a,b){if(a<b)return-1;else if(a>b)return 1;return 0};var i,l,m,n;function o(){return d.navigator?d.navigator.userAgent:null}n=m=l=i=!1;var p;if(p=o()){var q=d.navigator;i=p.indexOf("Opera")==0;l=!i&&p.indexOf("MSIE")!=-1;m=!i&&p.indexOf("WebKit")!=-1;n=!i&&!m&&q.product=="Gecko"}var r=l,s=n,v=m,w;
a:{var x="",y;if(i&&d.opera)var z=d.opera.version,x=typeof z=="function"?z():z;else if(s?y=/rv\:([^\);]+)(\)|;)/:r?y=/MSIE\s+([^\);]+)(\)|;)/:v&&(y=/WebKit\/(\S+)/),y)var A=y.exec(o()),x=A?A[1]:"";if(r){var B,C=d.document;B=C?C.documentMode:void 0;if(B>parseFloat(x)){w=String(B);break a}}w=x}var D={};
function E(a){var b;if(!(b=D[a])){b=0;for(var c=String(w).replace(/^[\s\xa0]+|[\s\xa0]+$/g,"").split("."),f=String(a).replace(/^[\s\xa0]+|[\s\xa0]+$/g,"").split("."),t=Math.max(c.length,f.length),u=0;b==0&&u<t;u++){var L=c[u]||"",M=f[u]||"",N=RegExp("(\\d*)(\\D*)","g"),O=RegExp("(\\d*)(\\D*)","g");do{var j=N.exec(L)||["","",""],k=O.exec(M)||["","",""];if(j[0].length==0&&k[0].length==0)break;b=h(j[1].length==0?0:parseInt(j[1],10),k[1].length==0?0:parseInt(k[1],10))||h(j[2].length==0,k[2].length==0)||
h(j[2],k[2])}while(b==0)}b=D[a]=b>=0}return b};function F(a){this.stack=Error().stack||"";if(a)this.message=String(a)}e(F,Error);e(function(a,b){b.unshift(a);F.call(this,g.apply(null,b));b.shift();this.f=a},F);!r||E("9");!s&&!r||r&&E("9")||s&&E("1.9.1");r&&E("9");function G(a,b,c,f,t){this.b=!!b;if(a&&(this.a=a))this.c=typeof f=="number"?f:this.a.nodeType!=1?0:this.b?-1:1;this.d=t!=void 0?t:this.c||0;this.b&&(this.d*=-1);this.e=!c}e(G,function(){});G.prototype.a=null;G.prototype.c=0;e(function(a,b,c,f){G.call(this,a,b,c,null,f)},G);function H(a){for(a=a.parentNode;a&&a.nodeType!=1&&a.nodeType!=9&&a.nodeType!=11;)a=a.parentNode;return a&&a.nodeType==1?a:null}var I="_".split("."),J=d;!(I[0]in J)&&J.execScript&&J.execScript("var "+I[0]);for(var K;I.length&&(K=I.shift());)!I.length&&H!==void 0?J[K]=H:J=J[K]?J[K]:J[K]={};; return this._.apply(null,arguments);}.apply({navigator:typeof window!='undefined'?window.navigator:null}, arguments);}
