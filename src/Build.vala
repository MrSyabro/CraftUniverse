/* Build.vala
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

namespace CraftUniverse{
	class Build : Object {
		public int id { get; set; }
        public string name { get; set; }
        public string dir { get; set; }
        public string gameVer { get; set; }
        public string assets { get; set; }
        public bool img { get; set; }
        public bool local { get; set; }
        public bool zip { get; set; }
	}

	class BuildUtils : Object {
		public async static Gee.TreeMap<string, Build> load_builds () {
			// Загрузка списка сборок
			info("Builds list download...");
			Gee.TreeMap<string, Build> builds_list = new Gee.TreeMap<string, Build>();
			try {
				Soup.Session session = new Soup.Session();
				Soup.Message message = new Soup.Message ("POST", Launcher.settings.site + "builds.php");
				message.set_request("application/json", Soup.MemoryUse.COPY, """{"type":"list"}""".data);
				DataInputStream builds_is = new DataInputStream(yield session.send_async (message));

				Json.Parser parser = new Json.Parser();
				parser.load_from_data(yield builds_is.read_upto_async ("\0", 1, Priority.DEFAULT, null, null));
				Json.Reader reader = new Json.Reader(parser.get_root());
				Json.Object root_object = parser.get_root().get_object();
				foreach(string dir in reader.list_members()) {
					Build build = Json.gobject_deserialize(typeof(Build), root_object.get_member(dir)) as Build;
					builds_list.@set(dir, build);
				}
			} catch (Error e) { error(e.message); }

			return builds_list;
		}
	}
}
