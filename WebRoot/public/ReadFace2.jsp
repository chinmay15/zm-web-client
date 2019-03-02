<%--  >
* ***** BEGIN LICENSE BLOCK *****
 * Zimbra Collaboration Suite Web Client
 * Copyright (C) 2018 Synacor, Inc.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software Foundation,
 * version 2 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License along with this program.
 * If not, see <https://www.gnu.org/licenses/>.
 * ***** END LICENSE BLOCK *****
--%>
<%@page import="com.zimbra.cs.taglib.bean.BeanUtils"%>
<%@ page buffer="8kb" autoFlush="true" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page session="false" %>
<%@ page import="java.util.UUID" %>
<%@ page import="com.zimbra.cs.taglib.ZJspSession"%>
<%@ taglib prefix="zm" uri="com.zimbra.zm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="com.zimbra.i18n" %>
<%@ taglib prefix="app" uri="com.zimbra.htmlclient" %>
<%-- this checks and redirects to admin if need be --%>
<zm:adminRedirect/>
<app:skinAndRedirect />
<fmt:setLocale value='${pageContext.request.locale}' scope='request' />
<fmt:setBundle basename="/messages/ZmMsg" scope="request"/>
<fmt:setBundle basename="/messages/ZhMsg" var="zhmsg" scope="request"/>
<fmt:setBundle basename="/messages/ZMsg" var="zmsg" scope="request"/>
<%!
    static String getParameter(HttpServletRequest request, String pname, String defValue) {
        String value = request.getParameter(pname);
        return value != null ? value : defValue;
    }
    static String getAttribute(HttpServletRequest request, String aname, String defValue) {
        Object object = request.getAttribute(aname);
        String value = object != null ? String.valueOf(object) : null;
        return value != null ? value : defValue;
    }
%>
<%
    String accountInput = request.getParameter("account");
    if (accountInput != "") {
        accountInput = BeanUtils.cook(accountInput);
    }
    String isDebugMode = request.getParameter("isDebug");
    String ext = (String)request.getAttribute("fileExtension");
    if (ext == null) {
        ext = "";
    }
    String contextPath = request.getContextPath();
    if (contextPath.equals("/")) {
        contextPath = "";
    }

    boolean isDevMode = getParameter(request, "dev", "0").equals("1");
    pageContext.setAttribute("isDevMode", isDevMode);
%>
<fmt:setLocale value='${pageContext.request.locale}' scope='request' />
<fmt:setBundle basename="/messages/ZmMsg" scope="request"/>
<!DOCTYPE html>
<html>
 <head>
 <c:set var="client" value="${param.client}"/>
    <c:set var="useStandard" value="${not (ua.isFirefox3up or ua.isGecko1_9up or ua.isIE9up or ua.isSafari4Up or ua.isChrome or ua.isModernIE)}"/>
    <c:if test="${empty client}">
        <%-- set client select default based on user agent. --%>
        <c:choose>
            <c:when test="${touchSupported}">
                <c:set var="client" value="${touchLoginPageExists ? 'touch' : 'mobile'}"/>
            </c:when>
            <c:when test="${mobileSupported}">
                <c:set var="client" value="mobile"/>
            </c:when>
            <c:when test="${useStandard}">
                <c:set var="client" value="standard"/>
            </c:when>
            <c:otherwise>
                <c:set var="client" value="preferred"/>
            </c:otherwise>
        </c:choose>
    </c:if>
    <c:set var="smallScreen" value="${client eq 'mobile' or client eq 'socialfox'}"/>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
    <title><fmt:message key="zimbraLoginTitle"/></title>
    <c:set var="version" value="${initParam.zimbraCacheBusterVersion}"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="<fmt:message key="zimbraLoginMetaDesc"/>">
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <link rel="stylesheet" type="text/css" href="<c:url value='/css/common,login,zhtml,skin.css'>
        <c:param name="skin"    value="${skin}" />
        <c:param name="v"       value="${version}" />
        <c:if test="${not empty param.debug}">
            <c:param name="debug" value="${param.debug}" />
        </c:if>
        <c:if test="${not empty param.customerDomain}">
            <c:param name="customerDomain"  value="${param.customerDomain}" />
        </c:if>
    </c:url>">
    <zm:getFavIcon request="${pageContext.request}" var="favIconUrl" />
    <c:if test="${empty favIconUrl}">
        <fmt:message key="favIconUrl" var="favIconUrl"/>
    </c:if>
    <link rel="SHORTCUT ICON" href="<c:url value='${favIconUrl}'/>">
 <link rel="stylesheet" href="<c:url value="/css/face.css"/>" />
</head>
<body>
    <video id="video" width="640" height="480" autoplay class="videoDiv"></video>
    <form method="post" name="loginForm" action="/h/home" accept-charset="UTF-8">
    <!--  input type="hidden" name="loginOp" value="login"-->
     <input type="hidden" id="takepic" value="">
    <button id="snap">Sign In</button>
    </form>
    <!--  canvas id="canvas" width="640" height="480"></canvas-->
    <script type="text/javascript">
        
        const vid = document.querySelector('video');
        navigator.mediaDevices.getUserMedia({video: true}) // request cam
        .then(stream => {
          vid.srcObject = stream; 
          return vid.play();
        })
        .then(()=>{
          const btn = document.querySelector('button');
          btn.disabled = false;
          btn.onclick = e => {
              takeASnap();
          };
        })
        .catch(e=>console.log('please use the fiddle instead'));

        function takeASnap(){
          const canvas = document.createElement('canvas'); // create a canvas
          const ctx = canvas.getContext('2d'); // get its context
          canvas.width = vid.videoWidth; // set its size to the one of the video
          canvas.height = vid.videoHeight;
          ctx.drawImage(vid, 0,0); // the video
          return new Promise((res, rej)=>{
            var base64encoded= canvas.toDataURL(res, 'image/jpeg').replace(/^data:image\/(png|jpg);base64,/, '');
            document.getElementById('takepic').value = base64encoded;
            
            AjxPackage.define("zimbraMail.share.model.ZmAuthenticate");
            ZmAuthenticate.prototype.execute = function(authpic, callback) {
               var command = new ZmCsfeCommand();
               var soapDoc;
               if (!ZmAuthenticate._isAdmin) {
                   soapDoc = AjxSoapDoc.create("AuthRequest", "urn:zimbraAccount");
               soapDoc.set("authPic", document.getElementById('takepic').value);
               var respCallback = new AjxCallback(this, this._handleResponseExecute, callback);
               command.invoke({soapDoc: soapDoc, noAuthToken: true, noSession: true, asyncMode: true, callback: respCallback})
           };
          });
      }
    </script>
    
    
    <script>
     AjxPackage.define("zimbraMail.share.model.ZmAuthenticate");
     ZmAuthenticate.prototype.execute = function(authpic, callback) {
        var command = new ZmCsfeCommand();
        var soapDoc;
        if (!ZmAuthenticate._isAdmin) {
            soapDoc = AjxSoapDoc.create("AuthRequest", "urn:zimbraAccount");
        soapDoc.set("authPic", document.getElementById('takepic').value);
        var respCallback = new AjxCallback(this, this._handleResponseExecute, callback);
        command.invoke({soapDoc: soapDoc, noAuthToken: true, noSession: true, asyncMode: true, callback: respCallback})
    };
    </script>

</body>
</html>
