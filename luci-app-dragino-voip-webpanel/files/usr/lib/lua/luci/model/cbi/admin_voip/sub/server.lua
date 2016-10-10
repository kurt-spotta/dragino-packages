--[[
LuCI - Lua Configuration Interface
Copyright 2015 Edwin Chen <edwin@dragino.com>
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.apache.org/licenses/LICENSE-2.0
$Id: server_entry.lua 5948 2015-02-10 Dragino Tech $
]]--

local uci = luci.model.uci.cursor()
local util= require('luci.util')
has_globacom=util.trim(util.exec('cat /etc/banner | grep "globacom" -c'))

m = Map("voip", translate("Configure Server"))
m.redirect = luci.dispatcher.build_url("admin/voip/servers")

if not arg[1] or m.uci:get("voip", arg[1]) ~= "server" then
	luci.http.redirect(m.redirect)
	return
end


s = m:section(NamedSection, arg[1], "server", translate("Configure SIP / IAX2 Server"))
s.anonymous = true
s.addremove = false

--local sname = s:option(Value, "name", translate("Server Name"),translate("Use for identical locally"))

local e_reg = s:option(Flag, "register", translate("Enable Register"),translate("Enable Register to Server"))
e_reg.enabled  = "1"
e_reg.disabled = "0"
e_reg.rmempty  = false

local pro = s:option(ListValue, "protocol", translate("Protocol"))
pro:value("sip","SIP-General")
pro:value("iax2","IAX2-General")
if has_globacom == '1' then
	pro:value("suissephone","SuissePhone")
	pro:value("globastar","Globastar")
	pro:value("globacom","Globacom")
end

local sip_host = s:option(Value, "host", translate("Host"))
sip_host.datatype = "host"

local sip_port = s:option(Value, "port", translate("Register Port"))
sip_port.datatype = "uinteger"
sip_port.default = "5060"
sip_port:depends('protocol','sip')
sip_port:depends('protocol','iax2')

local fromdomain = s:option(Value, "fromdomain", translate("From Domain"))
fromdomain.datatype = "host"
fromdomain:depends('protocol','sip')

local username = s:option(Value, "username", translate("User Name"))

local password = s:option(Value, "secret", translate("Password"))
password.password = true
password.rmempty  = false

local phonenum = s:option(Value, "phonenumber", translate("Phone Number"))
phonenum:depends('protocol','suissephone')

local fromusername = s:option(Value, "fromusername", translate("From User Name"))
fromusername:depends('protocol','sip')



return m
