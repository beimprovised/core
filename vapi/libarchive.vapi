/* libarchive.vapi - Bindings for libarchive(3) (version 3).
 *
 * Copyright (C) 2009 Julian Andres Klode <jak@jak-linux.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Julian Andres Klode <jak@jak-linux.org>
 *
 */


[CCode (cprefix="ARCHIVE_", lower_case_cprefix="archive_", cheader_filename = "archive.h")]
namespace Archive {
	public const int VERSION_NUMBER;
	public const string VERSION_STRING;
	public int version_number ();
	public unowned string version_string ();

	[CCode (instance_pos = 1.9, cname="archive_read_callback")]
	public delegate ssize_t ReadCallback (Archive archive,[CCode (array_length = false)] out unowned uint8[] buffer);
	[CCode (instance_pos = 1.9, cname="archive_skip_callback")]
	public delegate int64 SkipCallback (Archive archive, int64 request);
	[CCode (instance_pos = 1.9, cname="archive_write_callback")]
	public delegate ssize_t WriteCallback (Archive archive,[CCode (array_length_type = "size_t")] uint8[] buffer);
	[CCode (instance_pos = 1.9, cname="archive_open_callback")]
	public delegate int OpenCallback (Archive archive);

	[CCode (cname="archive_close_callback")]
	public delegate int CloseCallback (Archive archive);

	[CCode (cprefix="ARCHIVE_", cname="int", has_type_id = false)]
	public enum Result {
		EOF,
		OK,
		RETRY,
		WARN,
		FAILED
	}

	// see libarchive/archive.h, l. 218 ff.
	[CCode (cname="int", has_type_id = false)]
	public enum Filter {
		NONE,
		GZIP,
		BZIP2,
		COMPRESS,
		PROGRAM,
		LZMA,
		XZ,
		UU,
		RPM,
		LZIP,
		LRZIP,
		LZOP,
		GRZIP
	}

	[CCode (cname="int", has_type_id = false)]
	public enum Format {
		BASE_MASK,
		CPIO,
		CPIO_POSIX,
		CPIO_BIN_LE,
		CPIO_BIN_BE,
		CPIO_SVR4_NOCRC,
		CPIO_SVR4_CRC,
		SHAR,
		SHAR_BASE,
		SHAR_DUMP,
		TAR,
		TAR_USTAR,
		TAR_PAX_INTERCHANGE,
		TAR_PAX_RESTRICTED,
		TAR_GNUTAR,
		ISO9660,
		ISO9660_ROCKRIDGE,
		ZIP,
		EMPTY,
		AR,
		AR_GNU,
		AR_BSD,
		MTREE
	}

	[CCode (cprefix="ARCHIVE_EXTRACT_", cname="int", has_type_id = false)]
	public enum ExtractFlags {
		OWNER,
		PERM,
		TIME,
		NO_OVERWRITE,
		UNLINK,
		ACL,
		FFLAGS,
		XATTR,
		SECURE_SYMLINKS,
		SECURE_NODOTDOT,
		NO_AUTODIR,
		NO_OVERWRITE_NEWER,
		SPARSE
	}

	[Compact]
	[CCode (cname="struct archive", cprefix="archive_")]
	public class Archive {
		public int64 position_compressed ();
		public int64 position_uncompressed ();

		public Format format ();
		// Filter #0 is the one closest to the format, -1 is a synonym
		// for the last filter, which is always the pseudo-filter that
		// wraps the client callbacks. (libarchive/archive.h, l. 955)
		public Filter filter_code (int filter_no);

		public unowned string compression_name ();
		public unowned string format_name ();
		public unowned string filter_name (int filter_no = 0);

		public int filter_count ();
		public int file_count ();

		public int errno ();
		public unowned string error_string ();
		public void clear_error ();
		public void set_error (int err, string fmt, ...);
		public void copy_error (Archive src);
	}


	[Compact]
	[CCode (cname="struct archive", free_function="archive_read_free")]
	public class Read : Archive {
		public Read ();
		public Result support_filter_all ();
		public Result support_filter_bzip2 ();
		public Result support_filter_compress ();
		public Result support_filter_gzip ();
		public Result support_filter_grzip ();
		public Result support_filter_lrzip ();
		public Result support_filter_lzip ();
		public Result support_filter_lzma ();
		public Result support_filter_lzop ();
		public Result support_filter_none ();
		public Result support_filter_program (string command);
		// TODO support_filter_program_signature (string, const void *, size_t)
		public Result support_filter_rpm ();
		public Result support_filter_uu ();
		public Result support_filter_xz ();
		public Result support_format_7zip ();
		public Result support_format_all ();
		public Result support_format_ar ();
		public Result support_format_by_code (Format format_code);
		public Result support_format_cab ();
		public Result support_format_cpio ();
		public Result support_format_empty ();
		public Result support_format_gnutar ();
		public Result support_format_iso9660 ();
		public Result support_format_lha ();
		public Result support_format_mtree ();
		public Result support_format_rar ();
		public Result support_format_raw ();
		public Result support_format_tar ();
		public Result support_format_xar ();
		public Result support_format_zip ();
		public Result support_format_zip_streamable ();
		public Result support_format_zip_seekable ();

		public Result set_format (Format format_code);
		public Result append_filter (Filter filter_code);
		public Result append_filter_program (string cmd);
		// TODO append_filter_program_signature (string, const void *, size_t);

		public Result open (
			[CCode (delegate_target_pos = 0.9)] OpenCallback ocb,
			[CCode (delegate_target_pos = 0.9)] ReadCallback rcb,
			[CCode (delegate_target_pos = 0.9)] CloseCallback ccb
		);

		public Result open2 (
			[CCode (delegate_target_pos = 0.9)] OpenCallback ocb,
			[CCode (delegate_target_pos = 0.9)] ReadCallback rcb,
			[CCode (delegate_target_pos = 0.9)] SkipCallback scb,
			[CCode (delegate_target_pos = 0.9)] CloseCallback ccb
		);

		public Result open_filename (string filename, size_t block_size);
		public Result open_memory ([CCode (array_length_type = "size_t")] uint8[] buffer);
		public Result open_fd (int fd, size_t block_size);
		public Result open_FILE (GLib.FileStream file);
		public Result next_header (out unowned Entry entry);
		public int64 header_position ();

		[CCode (cname="archive_read_data")]
		public ssize_t read_data ([CCode (array_length_type = "size_t")] uint8[] buffer);
		[CCode (cname="archive_read_data_block")]
		public Result read_data_block ([CCode (array_length_type = "size_t")] out unowned uint8[] buffer, out int64 offset);
		[CCode (cname="archive_read_data_skip")]
		public Result read_data_skip ();
		[CCode (cname="archive_read_data_into_fd")]
		public Result read_data_into_fd (int fd);

		public Result extract (Entry entry, ExtractFlags? flags=0);
		public Result extract2 (Entry entry, Write dest);
		public void extract_set_skip_file (int64 dev, int64 ino);
		public Result close ();
	}

	[Compact]
	[CCode (cname = "struct archive", free_function="archive_read_free")]
	public class ReadDisk : Read {
		public ReadDisk ();
		public Result set_symlink_logical ();
		public Result set_symlink_physical ();
		public Result set_symlink_hybrid ();
		public unowned string gname (int64 gid);
		public unowned string uname (int64 uid);
		public Result set_standard_lookup ();

		// HACK, they have no name in C. May not work correctly.
		[CCode (instance_pos = 0, cname="void")]
		public delegate unowned string GNameLookup (int64 gid);
		[CCode (instance_pos = 0, cname="void")]
		public delegate unowned string UNameLookup (int64 uid);
		[CCode (instance_pos = 0, cname="void")]
		public delegate void Cleanup ();

		public Result set_gname_lookup (
			GNameLookup lookup,
			Cleanup? cleanup = null
		);

		public Result set_uname_lookup (
			UNameLookup lookup,
			Cleanup? cleanup = null
		);
	}

	[CCode (cname = "struct archive", free_function="archive_write_free")]
	public class Write : Archive {
		public Write ();
		public Result add_filter (Filter filter_code);
		public Result add_filter_by_name (string name);
		public Result add_filter_b64encode ();
		public Result add_filter_bzip2 ();
		public Result add_filter_compress ();
		public Result add_filter_grzip ();
		public Result add_filter_gzip ();
		public Result add_filter_lrzip ();
		public Result add_filter_lzip ();
		public Result add_filter_lzma ();
		public Result add_filter_lzop ();
		public Result add_filter_none ();
		public Result add_filter_program (string cmd);
		public Result add_filter_uuencode ();
		public Result add_filter_xz ();
		public Result set_format (Format format);
		public Result set_format_by_name (string name);
		public Result set_format_7zip ();
		public Result set_format_ar_bsd ();
		public Result set_format_ar_svr4 ();
		public Result set_format_cpio ();
		public Result set_format_cpio_newc ();
		public Result set_format_gnutar ();
		public Result set_format_iso9660 ();
		public Result set_format_mtree ();
		public Result set_format_mtree_classic ();
		public Result set_format_pax ();
		public Result set_format_pax_restricted ();
		public Result set_format_raw ();
		public Result set_format_shar ();
		public Result set_format_shar_dump ();
		public Result set_format_ustar ();
		public Result set_format_v7tar ();
		public Result set_format_xar ();
		public Result set_format_zip ();

		public Result set_bytes_per_block (int bytes_per_block);
		public int get_bytes_per_block ();
		public Result set_bytes_in_last_block (int bytes_in_last_block);
		public int get_bytes_in_last_block ();
		public Result set_skip_file (int64 dev, int64 ino);

		public Result open (
			[CCode (delegate_target_pos = 0.9)] OpenCallback ocb,
			[CCode (delegate_target_pos = 0.9)] WriteCallback rcb,
			[CCode (delegate_target_pos = 0.9)] CloseCallback ccb
		);
		public Result open_fd (int fd);
		public Result open_filename (string filename);
		public Result open_FILE (GLib.FileStream file);
		public Result open_memory ([CCode (array_length_type = "size_t")] uint8[] buffer, out size_t used);

		[CCode (cname="archive_write_header")]
		public Result write_header (Entry entry);
		[CCode (cname="archive_write_data")]
		public ssize_t write_data ([CCode (array_length_type = "size_t")] uint8[] data);
		[CCode (cname="archive_write_data_block")]
		public ssize_t write_data_block ([CCode (array_length_type = "size_t")] uint8[] data, int64 offset);

		public Result finish_entry ();
		public Result close ();
	}

	[Compact]
	[CCode (cname = "struct archive", free_function="archive_write_free")]
	public class WriteDisk : Write {
		public WriteDisk ();

		public Result set_skip_file (int64 dev, int64 ino);
		public Result set_options (ExtractFlags flags);
		public Result set_standard_lookup ();
	}

	[CCode (cheader_filename = "archive_entry.h", cprefix = "AE_", cname = "__LA_MODE_T", has_type_id = false)]
	public enum FileType {
		IFMT,
		IFREG,
		IFLNK,
		IFSOCK,
		IFCHR,
		IFBLK,
		IFDIR,
		IFIFO
	}

	[Compact]
	[CCode (cname = "struct archive_entry", cheader_filename = "archive_entry.h")]
	public class Entry {
		[CCode (cname="archive_entry_new2")]
		public Entry (Archive? archive = null);
		public time_t atime ();
		public long atime_nsec ();
		public bool atime_is_set ();
		public time_t birthtime ();
		public long birthtime_nsec ();
		public bool birthtime_is_set ();
		public time_t ctime ();
		public long ctime_nsec ();
		public bool ctime_is_set ();
		public int64 dev ();
		public int64 devmajor ();
		public int64 devminor ();
		public FileType filetype ();
		public unowned string fflags_text ();
		public int64 gid ();
		public unowned string gname ();
		public unowned string hardlink ();
		public int64 ino ();
		public FileType mode ();
		public time_t mtime ();
		public long mtime_nsec ();
		public bool mtime_is_set ();
		public uint nlink ();
		public unowned string pathname ();
		public int64 rdev ();
		public int64 rdevmajor ();
		public int64 rdevminor ();
		public unowned string sourcepath ();
		public int64 size ();
		public bool size_is_set ();
		public unowned string strmode ();
		public unowned string symlink ();
		public int64 uid ();
		public unowned string uname ();
		public void set_atime (time_t atime, long blah);
		public void unset_atime ();
		public void set_birthtime (time_t birthtime, long blah);
		public void unset_birthtime ();
		public void set_ctime (time_t atime, long blah);
		public void unset_ctime ();
		public void set_dev (int64 dev);
		public void set_devmajor (int64 major);
		public void set_devminor (int64 major);
		public void set_filetype (uint filetype);
		public void set_fflags (ulong set, ulong clear);
		public unowned string copy_fflags_text (string text);
		public void set_gid (int64 gid);
		public void set_gname (string gname);
		public Result update_gname_utf8 (string gname);
		public void set_hardlink (string link);
		public void set_ino (ulong ino);
		public void set_link (string link);
		public Result update_link_utf8 (string link);
		public void set_mode (FileType mode);
		public void set_mtime (time_t mtime, long blah);
		public void unset_mtime ();
		public void set_nlink (uint nlink);
		public void set_pathname (string pathname);
		public Result  update_pathname_utf8 (string pathname);
		public void set_perm (FileType mode);
		public void set_rdev (int64 dev);
		public void set_rdevmajor (int64 devmajor);
		public void set_rdevminor (int64 devminor);
		public void set_size (int64 size);
		public void unset_size ();
		public void copy_sourcepath (string sourcepath);
		public void set_symlink (string symlink);
		public void set_uid (int64 uid);
		public void set_uname (string uname);
		public Result update_uname_utf8 (string uname);

		public unowned Entry clear ();
		public Entry clone ();

		public void xattr_clear();
		public void xattr_add_entry(string name, void* value, size_t size);
		public int xattr_count();
		public Result xattr_reset();
		public Result xattr_next(out unowned string name, out void* value, out size_t size);

		[Compact]
		public class LinkResolver {
			public LinkResolver ();
			public void set_strategy (Format format_code);
			public void linkify (Entry a, Entry b);
		}
	}
}
