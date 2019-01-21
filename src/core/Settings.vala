/* Settings.vala
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

namespace CraftUniverse {
	class Settings : Object {
		// Настройка JVM
		public int jRAM { get; set; }
		public string jArg { get; set; }
		public string jPath { get; set; }
		public bool jShowClonsole { get; set; }
		// Конфигурации запуска Minecraft
		public string mMainClass { get; set; }
		public bool mForge { get; set; }
		// Конфигурации лаунчера
		public bool lBuildSync { get; set; }
		public bool lAutoClose { get; set; }
		public bool lAutoLogin { get; set; }
		public bool lNET = true;

		public string Dir = Environment.get_home_dir ();
		public const string site = "https://nm101.tk/_syabro_/";
		public const string lDir = "/CraftUniverse/";

		public Settings() {
			// Настройка JVM
			jRAM = 1024;
			jArg = "-XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:-UseAdaptiveSizePolicy -Xmn128M";
			jPath = "";
			jShowClonsole = false;
			// Конфигурации лаунчера
			lBuildSync = true;
			lAutoClose = false;
			lAutoLogin = false;
		}

		public static Settings load() throws Error {
			Settings settings = new Settings();
			File settings_file = File.new_for_path(settings.Dir + Settings.lDir + "Settings.json");
			if (settings_file.query_exists()){
				DataInputStream sf_dis = new DataInputStream(settings_file.read ());
				return Json.gobject_from_data(typeof(Settings), sf_dis.read_upto("\0", 1, null)) as Settings;
			} else {
				return settings;
			}
		}

		public void save () throws Error {
			File settings_file = File.new_for_path(this.Dir + lDir + "Settings.json");
			if (settings_file.query_exists()){
				settings_file.delete();
			}
			FileOutputStream sf_ios = settings_file.create (FileCreateFlags.REPLACE_DESTINATION);
			sf_ios.write(Json.gobject_to_data (this, null).data);
		}
	}
}
