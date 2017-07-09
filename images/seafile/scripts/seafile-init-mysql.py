# import the setup script... yeah, ugly hack, thanks Seafile
import sys
import os
import imp
import warnings

SEAFILE_SETUP_SCRIPT = 'setup-seafile-mysql'
SEAFILE_SCRIPTS_PATH = '/usr/local/share/seafile/scripts'

class OverrideFileImporter(object):
    def find_module(self, fullname, path=None):
        if fullname == SEAFILE_SETUP_SCRIPT:
            return self
        return None

    def load_module(self, fullname):
        if fullname in sys.modules:
            return sys.modules[fullname]
        mod = imp.new_module(fullname)
        mod.__loader__ = self
        sys.modules[fullname] = mod
        mod.__file__ = os.path.join(os.environ["SEAFILE_HOME"], "seafile-server", "setup") + ".py"
        with open(os.path.join(SEAFILE_SCRIPTS_PATH, SEAFILE_SETUP_SCRIPT) + ".py", 'r') as f:
            code = f.read()
        exec code in mod.__dict__
        return mod

sys.meta_path = [OverrideFileImporter()]

setup = __import__('setup-seafile-mysql', globals())

# Fix EnvMgr paths
setup.env_mgr.bin_dir = "/usr/local/bin"

os.environ['PYTHON'] = sys.executable
def nop_func(*args, **kwargs):
    pass
setup.env_mgr.check_pre_condiction = nop_func

# hardcoded config values
setup.seafile_config.fileserver_port = 8082
setup.seafile_config.seafile_dir = os.environ["SEAFILE_DATA_DIR"]

try:
    if setup.need_pause:
        setup.Utils.welcome()
    warnings.filterwarnings('ignore', category=setup.MySQLdb.Warning)

    # Part 1: collect configuration
    setup.ccnet_config.ask_questions()
    setup.seafile_config.ask_questions()
    setup.seahub_config.ask_questions()

    if not setup.db_config:
        if setup.AbstractDBConfigurator.ask_use_existing_db():
            setup.db_config = setup.ExistingDBConfigurator()
        else:
            setup.db_config = setup.NewDBConfigurator()

        setup.db_config.ask_questions()

    setup.report_config()

    # Part 2: generate configuration
    setup.db_config.generate()
    setup.ccnet_config.generate()
    setup.seafile_config.generate()
    setup.seafdav_config.generate()
    setup.seahub_config.generate()

    try:
        setup.seahub_config.do_syncdb()
    except Exception as e:
        print(e)
        print "MySQL import failed, skipping..."
    # setup.seahub_config.prepare_avatar_dir()
    # setup.db_config.create_seahub_admin()
    setup.create_seafile_server_symlink()
    setup.set_file_perm()

    setup.report_success()

except KeyboardInterrupt:
    print
    print setup.Utils.highlight('The setup process is aborted')
    print

