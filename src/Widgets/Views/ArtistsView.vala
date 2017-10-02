/*-
 * Copyright (c) 2017-2017 Artem Anufrij <artem.anufrij@live.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * The Noise authors hereby grant permission for non-GPL compatible
 * GStreamer plugins to be used and distributed together with GStreamer
 * and Noise. This permission is above and beyond the permissions granted
 * by the GPL license by which Noise is covered. If you modify this code
 * you may extend this exception to your version of the code, but you are not
 * obligated to do so. If you do not wish to do so, delete this exception
 * statement from your version.
 *
 * Authored by: Artem Anufrij <artem.anufrij@live.de>
 */

namespace PlayMyMusic.Widgets.Views {
    public class ArtistsView : Gtk.Grid {
        PlayMyMusic.Services.LibraryManager library_manager;

        Gtk.FlowBox artists;
        Gtk.Box content;

        PlayMyMusic.Widgets.ArtistView artist_view;

        construct {
            library_manager = PlayMyMusic.Services.LibraryManager.instance;
            library_manager.added_new_artist.connect((artist) => {
                add_artist (artist);
            });

        }

        public signal void artist_selected ();

        public ArtistsView () {
            build_ui ();
        }

        private void build_ui () {
            artists = new Gtk.FlowBox ();
            artists.margin = 24;
            artists.row_spacing = 12;
            artists.max_children_per_line = 1;
            artists.set_sort_func (artists_sort_func);
            artists.child_activated.connect (show_artist_viewer);

            var artists_scroll = new Gtk.ScrolledWindow (null, null);
            artists_scroll.width_request = 200;
            artists_scroll.add (artists);

            artist_view = new PlayMyMusic.Widgets.ArtistView ();
            artist_view.expand = true;

            content = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            content.expand = true;
            content.pack_start (artists_scroll, false, false, 0);
            content.pack_end (artist_view, true, true, 0);

            this.add (content);
            this.show_all ();
        }

        public void add_artist (Objects.Artist artist) {
            var a = new Widgets.Artist (artist);
            a.show_all ();
            artists.add (a);
        }

        public void reset () {
            foreach (var child in artists.get_children ()) {
                artists.remove (child);
            }
            artist_view.reset ();
        }

        public void play_selected_artist () {
            if (artist_view.current_artist != null) {
                artist_view.play_artist ();
            }
        }

        private void show_artist_viewer (Gtk.FlowBoxChild item) {
            var artist = (item as PlayMyMusic.Widgets.Artist);
            artist_view.show_artist_viewer (artist.artist);
            if (library_manager.player.current_track != null) {
                artist_view.mark_playing_track (library_manager.player.current_track);
            }
            artist_selected ();
        }

        private int artists_sort_func (Gtk.FlowBoxChild child1, Gtk.FlowBoxChild child2) {
            var item1 = (PlayMyMusic.Widgets.Artist)child1;
            var item2 = (PlayMyMusic.Widgets.Artist)child2;
            if (item1 != null && item2 != null) {
                return item1.name.collate (item2.name);
            }
            return 0;
        }
    }
}