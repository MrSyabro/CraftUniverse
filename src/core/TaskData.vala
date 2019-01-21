/* AuthWindow.vala
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

namespace CraftUniverse{
    class TaskData : Object{
        public string text;
        public ProgressBar pb;

        public TaskData(string t){ text = t; }

        public static Widget add_task_widget(Object obj_data) {
		    TaskData data = (TaskData)obj_data;
            var progress_bar = new ProgressBar();
            progress_bar.set_show_text(true);
            progress_bar.set_text(data.text);
            data.pb = progress_bar;
            return progress_bar;
		}
    }

}
