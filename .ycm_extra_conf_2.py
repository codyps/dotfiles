import os
import os.path
import logging
import ycm_core

BASE_FLAGS = [
    '-Wall',
    '-Wextra',
    '-Wno-long-long',
    '-Wno-variadic-macros',
]

SOURCE_EXTENSIONS = [
    '.cpp',
    '.cxx',
    '.cc',
    '.c',
    '.m',
    '.mm',
    '.C'
]

HEADER_EXTENSIONS = [
    '.h',
    '.hxx',
    '.hpp',
    '.hh',
    '.H'
]

"""
Potential "top-level" markers:
    - `Jenkinsfile`, `bors.toml`, `meson_options.txt`
    - `README.md`: somewhat risky, folks might place readmes in subdirs
    - `docs/`: again, might not always work out
    - `subprojects/`: (meson)
    - `CATKIN_IGNORE` (questionable)
    - `debian/`: often placed in `contrib` folders, not top-level
"""

def GlobNearest(path, target):
    """
    Iterate upward in `path`, trying to match that dir concatenated with
    `target` using glob.
    """
    def next_nearest(path, target):
        parent = os.path.dirname(os.path.abspath(path))
        if parent == path:
            raise RuntimeError("Could not find " + target)
        return GlobNearest(parent, target)

    candidate = os.path.join(path, *target)
    result = glob.glob(candidate)
    if result:
        result = [x for x in result if os.path.isdir(x)]
        if len(result) == 0:
            logging.warning("All potential dirs were not dirs")
            return next_nearest(path, target)

        if len(result) > 1:
            logging.warning("Found multiple build dirs: {}".format(result))
            raise RuntimeError("Found Multiple")
        logging.info("Found nearest " + target + " at " + candidate)
        return candidate;
    else:
        return next_nearest(path, target)


def FindNearest(path, target):
    candidate = os.path.join(path, target)
    if(os.path.isfile(candidate) or os.path.isdir(candidate)):
        logging.info("Found nearest " + target + " at " + candidate)
        return candidate;
    else:
        parent = os.path.dirname(os.path.abspath(path));
        if(parent == path):
            raise RuntimeError("Could not find " + target);
        return FindNearest(parent, target)


def GuessBuildDirectory(filename):
    """
    Given a filename, look upwards until we find something that appears to be a
    build directory
    """

    path = os.path.dirname(filename)
    result = None
    try:
        result = FindNearest(path, ["_b"])
    except:
        pass

    if result:
        return os.path.split(result[0])

    result = os.path.join(DirectoryOfThisScript(), "_b")

    if os.path.exists(result):
        return result

    result = glob.glob(os.path.join(DirectoryOfThisScript(),
                                    "_b*", ".ninja_log"))

    if not result:
        return ""

    if 1 != len(result):
        return ""

    return os.path.split(result[0])[0]

def IsHeaderFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in HEADER_EXTENSIONS

def GetCompilationInfoForFile(database, filename):
    if IsHeaderFile(filename):
        basename = os.path.splitext(filename)[0]
        for extension in SOURCE_EXTENSIONS:
            replacement_file = basename + extension
            if os.path.exists(replacement_file):
                compilation_info = database.GetCompilationInfoForFile(replacement_file)
                if compilation_info.compiler_flags_:
                    return compilation_info
        return None
    return database.GetCompilationInfoForFile(filename)

def MakeRelativePathsInFlagsAbsolute(flags, working_directory):
    if not working_directory:
        return list(flags)
    new_flags = []
    make_next_absolute = False
    path_flags = [ '-isystem', '-I', '-iquote', '--sysroot=' ]
    for flag in flags:
        new_flag = flag

        if make_next_absolute:
            make_next_absolute = False
            if not flag.startswith('/'):
                new_flag = os.path.join(working_directory, flag)

        for path_flag in path_flags:
            if flag == path_flag:
                make_next_absolute = True
                break

            if flag.startswith(path_flag):
                path = flag[ len(path_flag): ]
                new_flag = path_flag + os.path.join(working_directory, path)
                break

        if new_flag:
            new_flags.append(new_flag)
    return new_flags


def FlagsForClangComplete(root):
    try:
        clang_complete_path = FindNearest(root, '.clang_complete')
        clang_complete_flags = open(clang_complete_path, 'r').read().splitlines()
        return clang_complete_flags
    except:
        return None

def FlagsForInclude(root):
    try:
        include_path = FindNearest(root, 'include')
        flags = []
        for dirroot, dirnames, filenames in os.walk(include_path):
            for dir_path in dirnames:
                real_path = os.path.join(dirroot, dir_path)
                flags = flags + ["-I" + real_path]
        return flags
    except:
        return None

def FlagsForCompilationDatabase(root, filename):
    try:
        compilation_db_path = FindNearest(root, 'compile_commands.json')
        compilation_db_dir = os.path.dirname(compilation_db_path)
        logging.info("Set compilation database directory to " + compilation_db_dir)
        compilation_db =  ycm_core.CompilationDatabase(compilation_db_dir)
        if not compilation_db:
            logging.info("Compilation database file found but unable to load")
            return None
        compilation_info = GetCompilationInfoForFile(compilation_db, filename)
        if not compilation_info:
            logging.info("No compilation info for " + filename + " in compilation database")
            return None
        return MakeRelativePathsInFlagsAbsolute(
            compilation_info.compiler_flags_,
            compilation_info.compiler_working_dir_)
    except:
        return None

def FlagsForFile(filename):
    root = os.path.realpath(filename);
    compilation_db_flags = FlagsForCompilationDatabase(root, filename)
    if compilation_db_flags:
        final_flags = compilation_db_flags
    else:
        final_flags = BASE_FLAGS
        clang_flags = FlagsForClangComplete(root)
        if clang_flags:
            final_flags = final_flags + clang_flags
        include_flags = FlagsForInclude(root)
        if include_flags:
            final_flags = final_flags + include_flags
    return {
        'flags': final_flags,
        'do_cache': True
    }
