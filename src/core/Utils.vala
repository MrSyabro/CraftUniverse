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

namespace CraftUniverse {
    class Utils {
        public static async string hash_sum(File file) throws Error {
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
