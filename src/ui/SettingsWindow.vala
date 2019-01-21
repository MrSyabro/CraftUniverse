/* SetingsWindow.vala
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
	[GtkTemplate (ui="/org/gnome/CraftUniverse/ui/SettingsWindow.ui")]
	class SettingsWindow : Dialog {
        [GtkChild]SpinButton jRAM_SpinButton;
		[GtkChild]Entry jArg_Entry;
		[GtkChild]Entry jPath_Entry;
		[GtkChild]Switch jShowConsole_Switch;
		[GtkChild]Switch lBuildSync_Switch;
		[GtkChild]Switch lAutoClose_Switch;
		[GtkChild]Switch lAutoLogin_Switch;
		[GtkChild]Button save_Button;
		[GtkChild]Button cancell_Button;

		public SettingsWindow(Gtk.Application app) throws Error {
            set_application(app);
			set_icon(new Gdk.Pixbuf.from_resource("/org/gnome/CraftUniverse/res/icon.png"));
            save_Button.clicked.connect(save_Button_click);
			cancell_Button.clicked.connect(cancell_Button_click);
			show.connect(show_settings);
		}


		void show_settings(){
			jRAM_SpinButton.set_value(Launcher.settings.jRAM);
			jArg_Entry.set_text(Launcher.settings.jArg);
			jPath_Entry.set_text(Launcher.settings.jPath);
			jShowConsole_Switch.set_active(Launcher.settings.jShowClonsole);

			lBuildSync_Switch.set_active(Launcher.settings.lBuildSync);
			lAutoClose_Switch.set_active(Launcher.settings.lAutoClose);
			lAutoLogin_Switch.set_active(Launcher.settings.lAutoLogin);
		}

		public void save_Button_click(){
			// Сохранение настроек
			Launcher.settings.jRAM = jRAM_SpinButton.get_value_as_int();
			Launcher.settings.jArg = jArg_Entry.get_text();
			Launcher.settings.jPath = jPath_Entry.get_text();
			Launcher.settings.jShowClonsole = jShowConsole_Switch.active;

			Launcher.settings.lBuildSync = lBuildSync_Switch.active;
			Launcher.settings.lAutoClose = lAutoClose_Switch.active;
			Launcher.settings.lAutoLogin = lAutoLogin_Switch.active;

			Launcher.settings.save();
			close();
		}

		public void cancell_Button_click(){
			// Отмена изменения настроек
			close();
		}
	}
}
