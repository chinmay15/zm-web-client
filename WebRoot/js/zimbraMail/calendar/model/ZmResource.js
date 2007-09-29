/*
 * ***** BEGIN LICENSE BLOCK *****
 * Zimbra Collaboration Suite Web Client
 * Copyright (C) 2006 Zimbra, Inc.
 * 
 * The contents of this file are subject to the Yahoo! Public License
 * Version 1.0 ("License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://www.zimbra.com/license.
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.
 * ***** END LICENSE BLOCK *****
 */

function ZmResource(appCtxt, id, list, resType) {
	id = id ? id : Dwt.getNextId();
	ZmContact.call(this, appCtxt, id, list, ZmItem.RESOURCE);
	
	this.resType = resType;
};

ZmResource.F_capacity			= "zimbraCalResCapacity";
ZmResource.F_contactMail		= "zimbraCalResContactEmail";
ZmResource.F_locationName		= "zimbraCalResLocationDisplayName";
ZmResource.F_mail				= "mail";
ZmResource.F_name				= "displayName";
ZmResource.F_type				= "zimbraCalResType";

ZmResource.ATTR_LOCATION	= "Location";
ZmResource.ATTR_EQUIPMENT	= "Equipment";

/**
* Creates a resource from an XML node.
*
* @param node		a "calresource" XML node
* @param args		args to pass to the constructor
*/
ZmResource.createFromDom =
function(node, args) {
	var resource = new ZmResource(args.appCtxt, node.id, args.list);
	resource._loadFromDom(node);
	resource.resType = (resource.getAttr(ZmResource.F_type) == ZmResource.ATTR_LOCATION) ?
						ZmAppt.LOCATION : ZmAppt.EQUIPMENT;
	if (!resource.list) {
		var calApp = args.appCtxt.getApp(ZmZimbraMail.CALENDAR_APP);
		resource.list = (resource.resType == ZmAppt.LOCATION) ? calApp.getLocations() :
																calApp.getEquipment();
	}
	
	return resource;
};

ZmResource.prototype = new ZmContact;
ZmResource.prototype.constructor = ZmResource;

ZmResource.prototype.isLocation =
function() {
	return (this.resType == ZmAppt.LOCATION);
};

ZmResource.prototype.getEmail =
function() {
	return this.getAttr(ZmResource.F_mail);
};

ZmResource.prototype.getFullName =
function() {
	return this.getAttr(ZmResource.F_name);
};

/**
* 
*
* @param email	[object]	a ZmEmailAddress, or an email string
*/
ZmResource.prototype.initFromEmail =
function(email) {
	if (email instanceof ZmEmailAddress) {
		this.setAttr(ZmResource.F_mail, email.getAddress());
		this.setAttr(ZmResource.F_name, email.getName());
	} else {
		this.setAttr(ZmResource.F_mail, email);
	}
};
