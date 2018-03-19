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

using Soup;

namespace CraftUniverse {
	public class User {
		public async static UserData auth(UserData user_data){
			try {
				Session session = new Session();
				Message message = new Message ("POST", Launcher.settings.site + "auth.php");
				message.set_request("application/json", MemoryUse.COPY, user_data.to_string().data);
				DataInputStream userdata_is = new DataInputStream(yield session.send_async (message));

				user_data = Json.gobject_from_data (typeof(UserData), yield userdata_is.read_upto_async("\0", 1, Priority.DEFAULT, null, null)) as UserData;
				if (user_data.error != null){
					warning("Server response error %s: %s", user_data.error, user_data.error_message);
					return null;
				}

				File user_data_file = File.new_for_path(Launcher.settings.Dir + Launcher.settings.lDir + "UserData.json");
				FileOutputStream udf_ios;
				if (user_data_file.query_exists()) user_data_file.delete();
				udf_ios = yield user_data_file.create_async (FileCreateFlags.REPLACE_DESTINATION);

				yield udf_ios.write_async(user_data.to_string().data);
				info("Loged wich username %s.", user_data.username);
				return user_data;
			} catch (Error e) {
				error("%s", e.message);
				return null;
			}
		}
	}

	public class UserData : Object {
		public string username { get; set; }
		public string password { get; set; }
		public string accessToken { get; set; }
		public string clientToken { get; set; }
		public string uuid { get; set; }

		public string error { get; set; }
		public string error_message { get; set; }

		public string to_string(){
			return Json.gobject_to_data (this, null);
		}
	}
}
