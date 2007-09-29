/*
 * ***** BEGIN LICENSE BLOCK *****
 * Zimbra Collaboration Suite Web Client
 * Copyright (C) 2005, 2006 Zimbra, Inc.
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

function ZmZimletMgr(appCtxt) {
	this._appCtxt = appCtxt;
	this._ZIMLETS = [];
	this._ZIMLETS_BY_ID = {};
	this._CONTENT_ZIMLETS = [];
}

ZmZimletMgr.prototype.constructor = ZmZimletMgr;

// Public api
ZmZimletMgr.prototype.loadZimlets =
function(zimletArray, userProps) {
	if(!zimletArray || !zimletArray.length) {return;}
	for (var i = 0; i < zimletArray.length; i++)
		this._ZIMLETS_BY_ID[zimletArray[i].zimlet[0].name] = true;
	for(var i=0; i < zimletArray.length; i++) {
		var z = new ZmZimletContext(i, zimletArray[i], this._appCtxt);
		this._ZIMLETS[i] = this._ZIMLETS_BY_ID[z.name] = z;
	}
	if (userProps) {
		for (i = 0; i < userProps.length; ++i) {
			var p = userProps[i];
			z = this._ZIMLETS_BY_ID[p.zimlet];
			if (z) {
				z.setPropValue(p.name, p._content);
			}
		}
	}
	var panelZimlets = this.getPanelZimlets();
 	if(panelZimlets && panelZimlets.length > 0) {
		var zimletTree = this._appCtxt.getTree(ZmOrganizer.ZIMLET);
	 	if (!zimletTree) {
	 		zimletTree = new ZmFolderTree(this._appCtxt, ZmOrganizer.ZIMLET);
	 		this._appCtxt.setTree(ZmOrganizer.ZIMLET, zimletTree);
	 	}
	 	zimletTree.reset();
	 	zimletTree.loadFromJs(panelZimlets);
 	}
};

ZmZimletMgr.prototype.getPanelZimlets =
function() {
	var panelZimlets = [];
	var j=0;
	for(var i=0; i < this._ZIMLETS.length; i++) {
		if(this._ZIMLETS[i].zimletPanelItem) {
			DBG.println(AjxDebug.DBG2, "Zimlets - add to panel " + this._ZIMLETS[i].name);
			panelZimlets[j++] = this._ZIMLETS[i];
		}
	}
	return panelZimlets;
};

ZmZimletMgr.prototype.getIndexedZimlets =
function() {
	var indexedZimlets = [];
	var j=0;
	for(var i=0; i < this._ZIMLETS.length; i++) {
		if(this._ZIMLETS[i].keyword) {
			DBG.println(AjxDebug.DBG2, "Zimlets - add to indexed " + this._ZIMLETS[i].name);
			indexedZimlets[j++] = this._ZIMLETS[i];
		}
	}
	return indexedZimlets;
};

ZmZimletMgr.prototype.registerContentZimlet =
function(zimletObj, type, priority) {
	var i = this._CONTENT_ZIMLETS.length;
	this._CONTENT_ZIMLETS[i] = zimletObj;
	this._CONTENT_ZIMLETS[i].type = type;
	this._CONTENT_ZIMLETS[i].prio = priority;
	DBG.println(AjxDebug.DBG2, "Zimlets - registerContentZimlet(): " + this._CONTENT_ZIMLETS[i]._zimletContext.name);
};

ZmZimletMgr.prototype.getContentZimlets =
function() {
	return this._CONTENT_ZIMLETS;
};

ZmZimletMgr.prototype.getZimlets =
function() {
	return this._ZIMLETS;
};

ZmZimletMgr.prototype.getZimletsHash =
function() {
	return this._ZIMLETS_BY_ID;
};

ZmZimletMgr.prototype.zimletExists =
function(name) {
	return this._ZIMLETS_BY_ID[name];
};

ZmZimletMgr.prototype.toString =
function() {
	return "ZmZimletMgr";
};

ZmZimletMgr.prototype.notifyZimlets = function(event) {
	var args = new Array(arguments.length - 1);
	for (var i = 0; i < args.length;)
		args[i] = arguments[++i];
	var a = this._ZIMLETS;
	for (var i = 0; i < a.length; ++i) {
		var z = a[i].handlerObject;
		if (z
		    && z instanceof ZmZimletBase // we might get here even if Zimlets were not initialized
		    && z.getEnabled()		 // avoid calling any hooks on disabled Zimlets
		    && typeof z[event] == "function")
			z[event].apply(z, args);
	}
};
