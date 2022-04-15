import os
import sys

# Enable XDG support - cherry-picked from an open PR:
#  - https://github.com/python/cpython/issues/88405
#  - https://github.com/python/cpython/blob/dc505f9e9a7a1c4863f0193156bdde9bcfdf8c36/Lib/site.py#L434
def enablerlcompleter():
    """Enable default readline configuration on interactive prompts, by
    registering a sys.__interactivehook__.
    If the readline module can be imported, the hook will set the Tab key
    as completion key and register history file.
    This can be overridden in the sitecustomize or usercustomize module,
    or in a PYTHONSTARTUP file.
    """
    def register_readline():
        import atexit
        try:
            import readline
            import rlcompleter
        except ImportError:
            return

        # Reading the initialization (config) file may not be enough to set a
        # completion key, so we set one first and then read the file.
        readline_doc = getattr(readline, '__doc__', '')
        if readline_doc is not None and 'libedit' in readline_doc:
            readline.parse_and_bind('bind ^I rl_complete')
        else:
            readline.parse_and_bind('tab: complete')

        try:
            readline.read_init_file()
        except OSError:
            # An OSError here could have many causes, but the most likely one
            # is that there's no .inputrc file (or .editrc file in the case of
            # Mac OS X + libedit) in the expected location.  In that case, we
            # want to ignore the exception.
            pass

        if readline.get_current_history_length() == 0:
            # If no history was loaded, load history file from
            # platform defined directories.
            # The guard is necessary to avoid doubling history size at
            # each interpreter exit when readline was already configured
            # through a PYTHONSTARTUP hook, see:
            # http://bugs.python.org/issue5845#msg198636

            history = get_readline_history_path()
            history = os.path.abspath(history)
            try:
                _dir, _ = os.path.split(history)
                os.makedirs(_dir, exist_ok=True)
                readline.read_history_file(history)
            except OSError:
                pass

            def write_history():
                try:
                    readline.write_history_file(history)
                except OSError:
                    # bpo-19891, bpo-41193: Home directory does not exist
                    # or is not writable, or the filesystem is read-only.
                    pass

            atexit.register(write_history)

    def get_readline_history_path():
        def joinuser(*args):
            return os.path.expanduser(os.path.join(*args))

        # If the legacy path "~/.python_history" is readable, always use it.
        legacy = joinuser('~', '.python_history')
        if os.access(legacy, os.R_OK):
            return legacy

        # Otherwise, use platform defined data directory.
        if os.name == 'nt':
            base = os.environ.get('APPDATA') or '~'
            return joinuser(base, 'Python', 'history')

        if sys.platform == 'darwin':
            return joinuser('~', 'Library', 'Application Support', 'Python', 'history')

        if os.name == 'posix':
            base = os.environ.get('XDG_STATE_HOME') or joinuser('~', '.local', 'state')
            return joinuser(base, 'python', 'history')

        # Unknown platform, use the legacy path.
        return legacy

    sys.__interactivehook__ = register_readline

# Cherry-picked from
#  - https://github.com/python/cpython/blob/dc505f9e9a7a1c4863f0193156bdde9bcfdf8c36/Lib/site.py#L636
#  - https://github.com/python/cpython/blob/dc505f9e9a7a1c4863f0193156bdde9bcfdf8c36/Lib/site.py#L644
if not sys.flags.no_site and not sys.flags.isolated:
    enablerlcompleter()

