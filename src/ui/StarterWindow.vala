/* StartWindow.vala
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
	[GtkTemplate (ui="/org/gnome/CraftUniverse/ui/StarterWindow.ui")]
	class StarterWindow : ApplicationWindow {
		[GtkChild]ProgressBar progress_bar;

		public StarterWindow (Gtk.Application app) throws Error {
			Object(application: app);
		}

		public void start_game(Build _build) {
			show_all();

            string libraries = "";
			MainLoop update_build_ml = new MainLoop();
			update_files.begin(_build, (obj, res) => {
				libraries = update_files.end(res);
				update_build_ml.quit();
				info("End of update");
				close();
			});
			update_build_ml.run();

			Pid child_pid;

            string[] args = {"java", @"-Xmx$(Launcher.settings.jRAM)M", // Дополнительные аргументы и RAM
                    "-Dfml.ignoreInvalidMinecraftCertificates=true", "-Dfml.ignorePatchDiscrepancies=true", // Обязытельные аргументы
                    @"-Djava.library.path=$(Launcher.settings.Dir)$(Settings.lDir)versions/$(_build.gameVer)/natives", // Путь к папке natives
                    "-cp", @"$libraries$(Launcher.settings.Dir)$(Settings.lDir)versions/$(_build.gameVer)/minecraft.jar", // Список файлов библиотек и исполняемый файл
                    "net.minecraft.launchwrapper.Launch", "--tweakClass", "cpw.mods.fml.common.launcher.FMLTweaker",
                    "--version", _build.gameVer, "--gameDir", @"$(Launcher.settings.Dir)$(Settings.lDir)builds/$(_build.dir)/", // Версия, путь к папке игры
                    "--assetsDir", @"$(Launcher.settings.Dir)$(Settings.lDir)assets/", "--assetIndex", _build.assets, // Ресурсы
                    "--accessToken", AuthWindow.user_data.accessToken, "--uuid", AuthWindow.user_data.uuid, "--userProperties", "[]", "--userType", "majang", // Ключи
                    "--username", AuthWindow.user_data.username // Имя игрока
            };

            Process.spawn_async(@"$(Launcher.settings.Dir)$(Settings.lDir)builds/$(_build.dir)/", args, Environ.get (), SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD, null, out child_pid);
            MainLoop game_loop = new MainLoop();
            ChildWatch.add (child_pid, (pid, status) => {
			    // Triggered when the child indicated by child_pid exits
			    Process.close_pid (pid);
			    game_loop.quit ();
		    });

		    game_loop.run ();
		}



		private async string hash_sum(File file) throws Error {
			Checksum checksum = new Checksum (ChecksumType.SHA1);
			var stream = yield file.read_async();

			uint8 fbuf[128];
			   size_t size;

			   while ((size = stream.read (fbuf)) > 0){
				  checksum.update (fbuf, size);
			}
			   return checksum.get_string ();
		}
	}
}
