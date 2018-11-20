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
	[GtkTemplate (ui="/org/gnome/CraftUniverse/res/StarterWindow.ui")]
	class StarterWindow : ApplicationWindow {
		[GtkChild]ProgressBar progress_bar;

		public StarterWindow (Gtk.Application app) throws Error {
			set_application(app);
			set_icon(new Gdk.Pixbuf.from_resource("/org/gnome/CraftUniverse/res/icon.png"));
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

            string[] args = {"java", "-Xmx" + Launcher.settings.jRAM, // Дополнительные аргументы и RAM
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

		async string update_files(Build build) {
		    StringBuilder libraries = new StringBuilder();
			try{
				// Загрузка библиотек
				info("Checking libraries list");
				Json.Parser parser = new Json.Parser();
				progress_bar.set_text("Проверка библиотек");
				File libraries_json_list = File.new_for_uri(@"$(Settings.site)libraries/$(build.gameVer)$(sizeof(void*)==8 ? "64" : "32").json");
				DataInputStream ljl_stream = new DataInputStream(yield libraries_json_list.read_async());
				parser.load_from_data(yield ljl_stream.read_upto_async ("\0", 1, Priority.DEFAULT, null, null));
				Json.Reader reader = new Json.Reader(parser.get_root());
				int ss = reader.count_members();
				double step = 1F / ss;
				double cp = 0F;
				int cs = 0;
				foreach(string lib in reader.list_members()) {
					reader.read_member(lib); string lib_hash = reader.get_string_value(); reader.end_member();
					File local_lib_file = File.new_for_path(Launcher.settings.Dir + Settings.lDir + "libraries/" + lib);
					if (!local_lib_file.query_exists() || (lib_hash != yield hash_sum(local_lib_file))){
						if (local_lib_file.query_exists()) warning("Bad hash, downloading: " + lib);
						progress_bar.set_text(lib);
						File server_lib_file = File.new_for_uri(Settings.site + "libraries/" + lib);
						yield server_lib_file.copy_async(local_lib_file, FileCopyFlags.OVERWRITE, Priority.DEFAULT, null, (current_num_bytes, total_num_bytes) => {
							progress_bar.set_fraction(cp + step * (double)current_num_bytes / (double)total_num_bytes);
						});
					}
					libraries.append(@"$(Launcher.settings.Dir)$(Settings.lDir)libraries/$lib:");
					cp = cp + step;
					progress_bar.set_fraction(cp);
					progress_bar.set_text(@"Проверка библиотек $(cs++)/$ss");
				}
				progress_bar.set_fraction(0);
			} catch (Error e) { error(@"$(e.code): $(e.message)"); }

			try{
				// Загрузка ресурсов игры
				info("Checking assets list");
				Soup.Session update_session = new Soup.Session();
				Soup.Request asset_request;
				progress_bar.set_text("Проверка ресурсов");
				Json.Parser parser = new Json.Parser();
				File assets_json_list = File.new_for_uri(@"$(Settings.site)assets/indexes/$(build.assets).json");
				var ind_dir = File.new_for_path(@"$(Launcher.settings.Dir)$(Settings.lDir)assets/indexes/");
				if (!ind_dir.query_exists()) ind_dir.make_directory_with_parents();
				yield assets_json_list.copy_async(File.new_for_path(@"$(Launcher.settings.Dir)$(Settings.lDir)assets/indexes/$(build.assets).json"), FileCopyFlags.OVERWRITE, Priority.DEFAULT, null, null);
				DataInputStream ajl_stream = new DataInputStream(yield assets_json_list.read_async());
				parser.load_from_data(yield ajl_stream.read_upto_async("\0", 1, Priority.DEFAULT, null, null));
				Json.Reader reader = new Json.Reader(parser.get_root());
				reader.read_member("objects");
				int ss = reader.count_members();
				double step = 1F / ss;
				double cp = 0F;
				int cs = 0;
				foreach(string asset in reader.list_members()) {
					reader.read_member(asset);
					reader.read_member("hash"); string asset_hash = reader.get_string_value(); reader.end_member();
					reader.end_member();
					File local_asset_file = File.new_for_path(@"$(Launcher.settings.Dir)$(Settings.lDir)assets/objects/$(asset_hash.substring(0, 2))/$asset_hash");
					File asset_dir = File.new_for_path(@"$(Launcher.settings.Dir)$(Settings.lDir)assets/objects/$(asset_hash.substring(0, 2))/");
					if (!asset_dir.query_exists()) { asset_dir.make_directory_with_parents(); }
					if (!local_asset_file.query_exists() || (asset_hash != yield hash_sum(local_asset_file))){
						asset_request = update_session.request(@"$(Settings.site)assets/objects/$(asset_hash.substring(0, 2))/$asset_hash.asset");
						InputStream asset_is = yield asset_request.send_async(null);
						if (local_asset_file.query_exists()) { yield local_asset_file.delete_async(); warning(@"Bad hash, downloading: $asset"); }
						yield (yield local_asset_file.create_async(FileCreateFlags.REPLACE_DESTINATION)).splice_async(asset_is, OutputStreamSpliceFlags.CLOSE_SOURCE);
					}
					cp = cp + step;
					progress_bar.set_fraction(cp);
					progress_bar.set_text(@"Проверка ресурсов $(cs++)/$ss");
				}
				progress_bar.set_fraction(0);
			} catch (Error e) { error(@"$(e.code): $(e.message)"); }

			try {
				// Загрузка исполняемых файлов игры
				info("Checking client");
				Soup.Session update_session = new Soup.Session();
				File server_client_file;
				File local_client_file;
				File local_client_dir;
				Json.Parser parser = new Json.Parser();
				progress_bar.set_text("Проверка клиента");
				Soup.Message message = new Soup.Message ("POST", Settings.site + "versions/");
				message.set_request("application/json", Soup.MemoryUse.COPY, build.gameVer.data);
				DataInputStream client_files_is = new DataInputStream(yield update_session.send_async (message));
				parser.load_from_data(yield client_files_is.read_upto_async ("\0", 1, Priority.DEFAULT, null, null));
				Json.Reader reader = new Json.Reader(parser.get_root());
				string cf_hash;
				int ss = reader.count_members();
				double step = 1F / ss;
				double cp = 0F;
				int cs = 0;
				foreach(string cf in reader.list_members()) {
					reader.read_member(cf); cf_hash = reader.get_string_value(); reader.end_member();
					local_client_file = File.new_for_path(@"$(Launcher.settings.Dir)$(Settings.lDir)versions/$cf");
					if (!local_client_file.query_exists() || (cf_hash != yield hash_sum(local_client_file))){
						info(cf);
						if (local_client_file.query_exists()) warning("Bad hash, downloading: " + cf);
						server_client_file = File.new_for_uri(@"$(Settings.site)versions/$cf");
						local_client_dir = local_client_file.get_parent();
						if (!local_client_dir.query_exists()) local_client_dir.make_directory_with_parents();
						yield server_client_file.copy_async(local_client_file, FileCopyFlags.OVERWRITE, Priority.DEFAULT, null, (current_num_bytes, total_num_bytes) => {
							progress_bar.set_fraction(cp + (step * (double)current_num_bytes) / (double)total_num_bytes);
						});
					}
					cp = cp + step;
					progress_bar.set_fraction(cp);
					progress_bar.set_text(@"Загрузка клиента $(cs++)/$ss");
				}
				progress_bar.set_fraction(0);
			} catch (Error e) { error(@"$(e.code): $(e.message)"); }

			try {
				// Загрузка модов
				info("Checking mods list");
				Gee.HashMap<string, string> mods_files_list = new Gee.HashMap<string, string>();
				Json.Parser parser = new Json.Parser();
				progress_bar.set_text("Проверка модов");
				File build_mods_json_list = File.new_for_uri(@"$(Settings.site)builds/$(build.dir)/mods.json");
				DataInputStream bmjl_stream = new DataInputStream(yield build_mods_json_list.read_async());
				parser.load_from_data(yield bmjl_stream.read_upto_async ("\0", 1, Priority.DEFAULT, null, null));
				Json.Array build_mods_array = parser.get_root().get_array();
				yield bmjl_stream.close_async();
				File mods_json_list = File.new_for_uri(@"$(Settings.site)mods/");
				DataInputStream mjl_stream = new DataInputStream(yield mods_json_list.read_async());
				parser.load_from_data(yield mjl_stream.read_upto_async ("\0", 1, Priority.DEFAULT, null, null));
				Json.Reader build_mods_reader = new Json.Reader(parser.get_root());
				foreach(Json.Node mod_name_node in build_mods_array.get_elements()) {
					build_mods_reader.read_member(mod_name_node.get_string()); // Mod
					build_mods_reader.read_member(build.gameVer); // GameVer
					build_mods_reader.read_member("name"); // FileName
					string mod_file_name = build_mods_reader.get_string_value();
					build_mods_reader.end_member(); // FileName end
					build_mods_reader.read_member("hash"); // FileHash
					string mod_hash = build_mods_reader.get_string_value();
					build_mods_reader.end_member(); // FileHash end
					build_mods_reader.end_member(); // GameVer end
					build_mods_reader.end_member(); // Mod end

					mods_files_list.@set(mod_file_name, mod_hash);
				}
				File mods_dir = File.new_for_path(@"$(Launcher.settings.Dir)$(Settings.lDir)builds/$(build.dir)/mods/");
				if (!mods_dir.query_exists()) mods_dir.make_directory_with_parents();
				FileEnumerator mods_files_en = yield mods_dir.enumerate_children_async("standart::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, Priority.DEFAULT, null);
				FileInfo mod_file_info;
				while ((mod_file_info = mods_files_en.next_file (null)) != null) {
					File mod_file = File.new_for_path(@"$(Launcher.settings.Dir)$(Settings.lDir)builds/$(build.dir)/mods/$(mod_file_info.get_name())");
					if (mod_file_info.get_file_type () != FileType.DIRECTORY)
						if(!mods_files_list.has_key(mod_file_info.get_name()) || mods_files_list.@get(mod_file_info.get_name()) != yield hash_sum(mod_file)) {
							yield mod_file.delete_async();
						} else mods_files_list.unset(mod_file_info.get_name());
				}
				int ss = mods_files_list.size;
				double step = 1F / ss;
				double cp = 0F;
				int cs = 0;
				foreach(string key in mods_files_list.keys) {
					File local_mod_file = File.new_for_path(@"$(Launcher.settings.Dir)$(Settings.lDir)builds/$(build.dir)/mods/$key");
					File server_mod_file = File.new_for_uri(@"$(Settings.site)mods/$key");
					yield server_mod_file.copy_async(local_mod_file, FileCopyFlags.OVERWRITE, Priority.DEFAULT, null, (current_num_bytes, total_num_bytes) => {
							progress_bar.set_fraction(cp + (step * (double)current_num_bytes) / (double)total_num_bytes);
						});
					cp = cp + step;
					progress_bar.set_fraction(cp);
					progress_bar.set_text(@"Проверка модов $(cs++)/$ss");
				}


			} catch (Error e) { error(@"$(e.code): $(e.message)"); }
			return libraries.str;
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
