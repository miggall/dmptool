!function(){function e(e){return e&&e.__esModule?e.default:e}var t={};var n=function(e){var n=t[e];if(null==n)throw new Error("Could not resolve bundle with id "+e);return n};(function(e){for(var n=Object.keys(e),r=0;r<n.length;r++)t[n[r]]=e[n[r]]})(JSON.parse('{"3f8kp":"main.js","pAGPy":"1-large.6a047be8.jpg","2ZIk4":"2-large.13932f92.jpg","6viVv":"3-large.2e3ab041.jpg","3yYTo":"4-large.29293cd2.jpg","7CzQ8":"5-large.e80fb2f4.jpg"}'));const r=()=>document.querySelector("#js-navtoggle"),a=()=>document.querySelector("#js-headernav"),o=()=>{a().hidden=!1,r().setAttribute("aria-expanded",!0)},d=()=>{a().hidden=!0,r().setAttribute("aria-expanded",!1)},i=window.getComputedStyle(document.documentElement).getPropertyValue("--breakpoints").split(","),[c,s]=i,l=e=>{e.matches?o():d()},u=()=>{const e=window.matchMedia(`(min-width: ${c})`);document.querySelector(".c-header")&&(r().addEventListener("click",(()=>{!0===a().hidden?o():d()})),!0===a().hidden?o():d()),l(e),e.addListener(l)};var f=()=>(()=>{const e=document.querySelector("#js-user-profile"),t=document.querySelector("#js-user-profile__button"),n=document.querySelector("#js-user-profile__menu"),r=()=>{n.hidden=!0,t.setAttribute("aria-expanded",!1)},a=t=>{e.contains(t.target)||r()};e&&(t.addEventListener("click",(()=>{!0===n.hidden?(n.hidden=!1,t.setAttribute("aria-expanded",!0)):r()})),window.addEventListener("click",a),window.addEventListener("focusin",a))})();var g=()=>(()=>{const e=document.querySelector("#js-language"),t=document.querySelector("#js-language__button"),n=document.querySelector("#js-language__menu"),r=()=>{n.hidden=!0,t.setAttribute("aria-expanded",!1)},a=t=>{e.contains(t.target)||r()};document.querySelector("#js-language")&&(t.addEventListener("click",(()=>{!0===n.hidden?(n.hidden=!1,t.setAttribute("aria-expanded",!0)):r()})),window.addEventListener("click",a),window.addEventListener("focusin",a))})();var p=()=>(()=>{const e=document.querySelector("#js-admin"),t=document.querySelector("#js-admin__button"),n=document.querySelector("#js-admin__menu"),r=()=>{n.hidden=!0,t.setAttribute("aria-expanded",!1)},a=t=>{e.contains(t.target)||r()};e&&(t.addEventListener("click",(()=>{!0===n.hidden?(n.hidden=!1,t.setAttribute("aria-expanded",!0)):r()})),window.addEventListener("click",a),window.addEventListener("focusin",a))})();var m=()=>(()=>{const e=document.querySelector("#js-calltoaction");if(e){const t=document.querySelector("#js-login"),n=window.getComputedStyle(t),r=parseInt(n.width)+parseInt(n.margin);window.CSS.supports("grid-template-columns: subgrid")||e.style.setProperty("--calltoaction-grid-columns",`auto ${r}px`)}})();var h=()=>(()=>{if(document.querySelector(".t-home")){images=document.querySelector("#js-heroimage__images").value,console.log(images),console.log(images[0]),console.log(images.value);let e=JSON.parse(`${images}`);const t=Math.floor(Math.random()*e.length),n=document.querySelector(".js-heroimage"),r=60,a=`linear-gradient(hsl(0, 0%, ${r}%), hsl(0, 0%, ${r}%)), url('${e[t]}')`;n.style.setProperty("--hero-image",a)}})();var v=()=>(()=>{const e=$("#j-blog__content").val();if(e){const t=JSON.parse(`${e.replace(/\\"/g,'"').replace(/\\'/g,"'")}`),n=e=>{const n=$(".c-blog__content");n.hide(),n.html(`<a href="${t[e].link}" target="_blank" class="has-new-window-popup-info">${t[e].title}</a>`),n.fadeIn(100)},r=e=>{setTimeout((()=>{n(e),r(e>=t.length-1?0:e+1)}),8e3)};n(0),r(1)}})(),y=null;var _,w=function(){return y||(y=function(){try{throw new Error}catch(t){var e=(""+t.stack).match(/(https?|file|ftp):\/\/[^)\n]+/g);if(e)return(""+e[0]).replace(/^((?:https?|file|ftp):\/\/.+)\/[^/]+$/,"$1")+"/"}return"/"}()),y},S=n;function b(e){if(""===e)return".";var t="/"===e[e.length-1]?e.slice(0,e.length-1):e,n=t.lastIndexOf("/");return-1===n?".":t.slice(0,n)}function j(e,t){if(e===t)return"";var n=e.split("/");"."===n[0]&&n.shift();var r,a,o=t.split("/");for("."===o[0]&&o.shift(),r=0;(r<o.length||r<n.length)&&null==a;r++)n[r]!==o[r]&&(a=r);var d=[];for(r=0;r<n.length-a;r++)d.push("..");return o.length>a&&d.push.apply(d,o.slice(a)),d.join("/")}(_=function(e,t){return j(b(S(e)),S(t))})._dirname=b,_._relative=j;w(),_("3f8kp","pAGPy"),w(),_("3f8kp","2ZIk4"),w(),_("3f8kp","6viVv"),w(),_("3f8kp","3yYTo"),w(),_("3f8kp","7CzQ8");if(window.addEventListener("load",(()=>{u(),f(),g(),p(),m(),h(),v()})),document.querySelector("#js-tests2")){document.querySelector("#js-tests2 output").innerText="Yes"}}();