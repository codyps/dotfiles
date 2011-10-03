-- GNOME Awesome Applet - control Awesome window manager via GNOME panel
--
-- Copyright © 2010 Stefano Zacchiroli <zack@upsilon.cc>
--
-- This program is free software: you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-- more details.
--
-- You should have received a copy of the GNU General Public License along with
-- this program.  If not, see <http://www.gnu.org/licenses/>.

-- {{{ GNOME Awesome applet

function awesome_dbus_notify (signal)
   dbus_iface = "cc.upsilon.awesomeapplet.NotifyInterface"
   dbus_signal = string.format("%s.%s", dbus_iface, signal)
   dbus_send_cmd = string.format("dbus-send --type=signal / %s", dbus_signal)
   awful.util.spawn(dbus_send_cmd, false)
end

function gnome_lua_prompt ()
   dbus_name = "cc.upsilon.awesomeapplet"
   dbus_path = "/cc/upsilon/awesomeapplet"
   dbus_meth = dbus_name .. ".LuaPrompt"
   dbus_send_cmd = string.format("dbus-send --dest=%s --type=method_call %s %s", dbus_name, dbus_path, dbus_meth)
   awful.util.spawn(dbus_send_cmd, false)
end

function gnome_run_dialog ()
   -- requires "openbox" on Debian, see however http://bugs.debian.org/602594
   run_dialog_cmd = "gnome-panel-control --run-dialog"
   awful.util.spawn(run_dialog_cmd, false)
end

for i = 1, screen.count() do
   s = screen[i]
   s:add_signal("tag::history::update",
		function (t)
		   awesome_dbus_notify("LayoutUpdate")
		end)
end

awful.tag.attached_add_signal(nil, "property::layout",
			      function ()
				 awesome_dbus_notify("LayoutUpdate")
			      end)

-- }}}

