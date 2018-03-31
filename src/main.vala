/* main.vala
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
	class Launcher : Gtk.Application {
		public Launcher () {
			Object(application_id: "craftuniverse.launcher",
				flags: ApplicationFlags.FLAGS_NONE);
		}

		public static Settings settings;
		public static MainWindow main_window;

		protected override void activate () {
			try {
			settings = Settings.load();
			if (!FileUtils.test(settings.Dir + Settings.lDir, FileTest.IS_DIR)) {
				File.new_for_path(settings.Dir + Settings.lDir).make_directory();
			}
			AuthWindow auth_window = new AuthWindow(this);
			main_window = new MainWindow(this);

			add_window(auth_window);
			auth_window.show_all();

			add_window(main_window);
			} catch (Error e) { error(@"$(e.code): $(e.message)"); }
		}
	}

	public static int main (string[] args) {
		Launcher launcher = new Launcher ();
		return launcher.run (args);
	}
}
