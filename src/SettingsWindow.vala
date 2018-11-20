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
	[GtkTemplate (ui="/org/gnome/CraftUniverse/res/SettingsWindow.ui")]
	class SettingsWindow : Dialog {
        [GtkChild]ComboBox jRAM_ComboBox;
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

		public SettingsWindow(Gtk.Application app) throws Error {
            set_application(app);
			set_icon(new Gdk.Pixbuf.from_resource("/org/gnome/CraftUniverse/res/icon.png"));
            save_Button.clicked.connect(save_Button_click);
			cancell_Button.clicked.connect(cancell_Button_click);
		}


		void show_settings(){
			//jRAM_ComboBox.set_text(Launcher.settings.jRAM);
			jArg_Entry.set_text(Launcher.settings.jArg);
			jPath_Entry.set_text(Launcher.settings.jPath);
			jShowConsole_CheckButton.set_active(Launcher.settings.jShowClonsole);

			mMainClass_Entry.set_text(Launcher.settings.mMainClass);
			mForge_CheckButton.set_active(Launcher.settings.mForge);

			lBuildSync_CheckButton.set_active(Launcher.settings.lBuildSync);
			lAutoClose_CheckButton.set_active(Launcher.settings.lAutoClose);
			lAutoLogin_CheckButton.set_active(Launcher.settings.lAutoLogin);
		}

		public void save_Button_click(){
			// Сохранение настроек
			//Launcher.settings.jRAM = jRAM_Entry.get_text();
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
	}
}
