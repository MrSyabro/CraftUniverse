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

		public StarterWindow (Gtk.Application app) {
			set_application(app);
			set_icon(new Gdk.Pixbuf.from_resource("/org/gnome/CraftUniverse/res/icon.png"));
		}

		public void start_game(Build _build) {
			show_all();

			MainLoop update_build_ml = new MainLoop();
			update_files.begin(_build, (obj, res) => {
				update_files.end(res);
				update_build_ml.quit();
				info("End of update");
				close();
			});
			update_build_ml.run();
		}

		async void update_files(Build build) {
			try{
				// Загрузка библиотек
				info("Downlaod libraries list");
				File server_lib_file;
				File local_lib_file;
				Json.Parser parser = new Json.Parser();
				progress_bar.set_text("Загрузка библиотек");
				File libraries_json_list = File.new_for_uri(@"$(Launcher.settings.site)libraries/$(build.gameVer)$(sizeof(void*)==8 ? "64" : "32").json");
				DataInputStream ljl_stream = new DataInputStream(yield libraries_json_list.read_async());
				parser.load_from_data(yield ljl_stream.read_upto_async ("\0", 1, Priority.DEFAULT, null, null));
				Json.Reader reader = new Json.Reader(parser.get_root());
				double step = 1F / reader.count_members();
				foreach(string lib in reader.list_members()) {
					reader.read_member(lib); string lib_hash = reader.get_string_value(); reader.end_member();
					local_lib_file = File.new_for_path(Launcher.settings.Dir + Launcher.settings.lDir + "libraries/" + lib);
					if (!local_lib_file.query_exists() || (lib_hash != yield hash_sum(local_lib_file))){
						if (local_lib_file.query_exists()) warning("Bad hash, downloading: " + lib);
						progress_bar.set_text(lib);
						server_lib_file = File.new_for_uri(Launcher.settings.site + "libraries/" + lib);
						yield server_lib_file.copy_async(local_lib_file, FileCopyFlags.OVERWRITE, Priority.DEFAULT, null, (current_num_bytes, total_num_bytes) => {
							progress_bar.set_fraction(progress_bar.get_fraction() + step / ((double)current_num_bytes / (double)total_num_bytes));
						});
					} else progress_bar.set_fraction(progress_bar.get_fraction() + step);
				}
				progress_bar.set_fraction(0);

				// Загрузка ресурсов игры
				info("Downloading assets list");
				Soup.Session update_session = new Soup.Session();
				Soup.Request lib_request;
				File local_asset_file;
				InputStream lib_is;
				File asset_dir;
				progress_bar.set_text("Загрузка ресурсов");
				update_session.use_thread_context = true;
				parser = new Json.Parser();
				File assets_json_list = File.new_for_uri(@"$(Launcher.settings.site)assets/indexes/$(build.assets).json");
				DataInputStream ajl_stream = new DataInputStream(yield assets_json_list.read_async());
				parser.load_from_data(yield ajl_stream.read_upto_async("\0", 1, Priority.DEFAULT, null, null));
				reader = new Json.Reader(parser.get_root());
				reader.read_member("objects");
				step = 1F / reader.count_members();
				foreach(string asset in reader.list_members()) {
					reader.read_member(asset);
					reader.read_member("hash"); string asset_hash = reader.get_string_value(); reader.end_member();
					reader.end_member();
					local_asset_file = File.new_for_path(@"$(Launcher.settings.Dir)$(Launcher.settings.lDir)assets/objects/$(asset_hash.substring(0, 2))/$asset_hash");
					asset_dir = File.new_for_path(@"$(Launcher.settings.Dir)$(Launcher.settings.lDir)assets/objects/$(asset_hash.substring(0, 2))/");
					if (!asset_dir.query_exists()) { asset_dir.make_directory_with_parents(); }
					if (!local_asset_file.query_exists() || (asset_hash != yield hash_sum(local_asset_file))){
						lib_request = update_session.request(@"$(Launcher.settings.site)assets/objects/$(asset_hash.substring(0, 2))/$asset_hash.asset");
						lib_is = yield lib_request.send_async(null);
						if (local_asset_file.query_exists()) { yield local_asset_file.delete_async(); warning(@"Bad hash, downloading: $asset"); }
						yield (yield local_asset_file.create_async(FileCreateFlags.REPLACE_DESTINATION)).splice_async(lib_is, OutputStreamSpliceFlags.CLOSE_SOURCE);
					}
					progress_bar.set_fraction(progress_bar.get_fraction() + step);
				}
				progress_bar.set_fraction(0);

				// Загрузка исполняемых файлов игры
				File game_dir = File.new_for_path(@"$(Launcher.settings.Dir)$(Launcher.settings.lDir)versions/$(build.gameVer)");
				if (!game_dir.query_exists()) {
					info("Download client");
					progress_bar.set_text("Загрузка клиента");
					game_dir.make_directory_with_parents();
					//File game_zip = File.new_for_uri(@"$(Launcher.settings.site)versions/$(build.gameVer).zip");
					//InputStream game_zip_is = yield game_zip.read_async();
					Soup.Request game_zip_request = update_session.request(@"$(Launcher.settings.site)versions/$(build.gameVer).zip");
					InputStream game_zip_is = yield game_zip_request.send_async(null);
					ZlibDecompressor zlib_dec = new ZlibDecompressor (ZlibCompressorFormat.GZIP);
					ConverterOutputStream gz_conv_is = new ConverterOutputStream (yield game_dir.replace_async(null, false, 0), zlib_dec);
					message("%g", yield gz_conv_is.splice_async(game_zip_is, OutputStreamSpliceFlags.NONE));
				}
			} catch (Error e) { error(@"$(e.code): $(e.message)"); }
		}

		private async string hash_sum(File file){
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
