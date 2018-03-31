/* AuthWindow.vala
 *
 * Copyright (C) 2018 MrSyabro
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;

namespace CraftUniverse {
	[GtkTemplate (ui="/org/gnome/CraftUniverse/res/AuthWindow.ui")]
	class AuthWindow : Dialog {
		public static UserData user_data;
		[GtkChild]Entry login_entry;
		[GtkChild]Entry pass_entry;
		[GtkChild]Button reg_button;
		[GtkChild]Button auth_button;
		[GtkChild]CheckButton auto_auth_chek_button;
		[GtkChild]Spinner spinner;

		public AuthWindow (Gtk.Application app) throws Error {
			set_application(app);
			set_icon(new Gdk.Pixbuf.from_resource("/org/gnome/CraftUniverse/res/icon.png"));
			show.connect(auth_window_show);
			auth_button.clicked.connect(auth_button_click);
			reg_button.clicked.connect(reg_button_click);
			auto_auth_chek_button.set_active(Launcher.settings.lAutoLogin);
		}

		public void auth_window_show(){
			try {
				File user_data_file = File.new_for_path(Launcher.settings.Dir + Settings.lDir + "UserData.json");
				FileInputStream udf_is;
				MainLoop auth_ml = new MainLoop();
				if (user_data_file.query_exists() && Launcher.settings.lAutoLogin){
					udf_is = user_data_file.read ();
					DataInputStream udf_dis = new DataInputStream(udf_is);
					user_data = Json.gobject_from_data(typeof(UserData), udf_dis.read_upto("\0", 1, null)) as UserData;
					User.auth.begin(user_data, (obj, res) => {
						user_data = User.auth.end(res);
						Launcher.main_window.show_all();
						close();
						auth_ml.quit();
					});
				  } else { set_sensitive(true); spinner.active = false; }
			  } catch (Error e) { error(e.message); }
		}

		public void auth_button_click() {
			set_sensitive(false);
			spinner.active = true;
			user_data = new UserData();
			user_data.username = login_entry.text;
			user_data.password = pass_entry.text;
			MainLoop auth_ml = new MainLoop();
			User.auth.begin(user_data, (obj, res) => {
				user_data = User.auth.end(res);
				Launcher.main_window.show_all();
				close();
				auth_ml.quit();
			});
			Launcher.settings.lAutoLogin = auto_auth_chek_button.active;
			Launcher.settings.save();
		}

		public void reg_button_click(){

		}
	}
}
