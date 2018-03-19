/* MainWindow.vala
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
    [GtkTemplate (ui="/org/gnome/CraftUniverse/res/MainWindow.ui")]
    class MainWindow : ApplicationWindow {
		[GtkChild]IconView builds_IconView;
		[GtkChild]Gtk.ListStore builds_ListStore;
		[GtkChild]Entry jRAM_Entry;
		[GtkChild]Entry jArg_Entry;
		[GtkChild]Entry jPath_Entry;
		[GtkChild]CheckButton jShowConsole_CheckButton;
		[GtkChild]Entry mMainClass_Entry;
		[GtkChild]CheckButton mForge_CheckButton;
		[GtkChild]CheckButton lBuildSync_CheckButton;
		[GtkChild]CheckButton lAutoClose_CheckButton;
		[GtkChild]CheckButton lAutoLogin_CheckButton;
		[GtkChild]Button save_Button;
		[GtkChild]Button cancell_Button;
		TreeIter iter;
		Gee.TreeMap<string, Build> builds_list;

		public MainWindow(Gtk.Application app) {
			set_application(app);
			set_icon(new Gdk.Pixbuf.from_resource("/org/gnome/CraftUniverse/res/icon.png"));
			builds_IconView.set_pixbuf_column (0);
			builds_IconView.set_text_column (1);
			show.connect(main_window_show);
			builds_IconView.item_activated.connect(builds_list_activate);
			save_Button.clicked.connect(save_Button_click);
			cancell_Button.clicked.connect(cancell_Button_click);
		}

		public void main_window_show(){
			show_settings();

			MainLoop builds_ml = new MainLoop();
			BuildUtils.load_builds.begin((obj, res) => {
				builds_list = BuildUtils.load_builds.end(res);
				builds_ml.quit();
			});
			builds_ml.run();

			Gdk.Pixbuf build_icon;
			foreach(Build build in builds_list.values){
				if(build.img && Launcher.settings.lNET){
					File icon_file = File.new_for_uri(Launcher.settings.site + "icons/" + build.dir + ".png");
					build_icon = new Gdk.Pixbuf.from_stream_at_scale(icon_file.read(), 32, 32, true);
				} else {
					build_icon = new Gdk.Pixbuf.from_file_at_size(Launcher.settings.Dir + Launcher.settings.lDir + "icons/default.png", 32, 32);
				}
				builds_ListStore.append(out iter);
				builds_ListStore.set(iter, 0, build_icon, 1, build.name.data, 2, build.dir.data);
			}
		}

		public void builds_list_activate(TreePath path) {
			// Запуск игры
			Value b_dir;
			StarterWindow starter = new StarterWindow(application);
			builds_ListStore.get_iter(out iter, path);
			builds_ListStore.get_value(iter, 2, out b_dir);
			starter.start_game(builds_list[(string)b_dir]);
		}

		public void save_Button_click(){
			// Сохранение настроек
			Launcher.settings.jRAM = jRAM_Entry.get_text();
			Launcher.settings.jArg = jArg_Entry.get_text();
			Launcher.settings.jPath = jPath_Entry.get_text();
			Launcher.settings.jShowClonsole = jShowConsole_CheckButton.get_active();

			Launcher.settings.mMainClass = mMainClass_Entry.get_text();
			Launcher.settings.jShowClonsole = jShowConsole_CheckButton.get_active();

			Launcher.settings.lBuildSync = lBuildSync_CheckButton.get_active();
			Launcher.settings.lAutoClose = lAutoClose_CheckButton.get_active();
			Launcher.settings.lAutoLogin = lAutoLogin_CheckButton.get_active();

			Launcher.settings.save();
		}

		public void cancell_Button_click(){
			// Отмена изменения настроек
			show_settings();
		}

		void show_settings(){
			jRAM_Entry.set_text(Launcher.settings.jRAM);
			jArg_Entry.set_text(Launcher.settings.jArg);
			jPath_Entry.set_text(Launcher.settings.jPath);
			jShowConsole_CheckButton.set_active(Launcher.settings.jShowClonsole);

			mMainClass_Entry.set_text(Launcher.settings.mMainClass);
			mForge_CheckButton.set_active(Launcher.settings.mForge);

			lBuildSync_CheckButton.set_active(Launcher.settings.lBuildSync);
			lAutoClose_CheckButton.set_active(Launcher.settings.lAutoClose);
			lAutoLogin_CheckButton.set_active(Launcher.settings.lAutoLogin);
		}
	}
}