import gi
gi.require_version('Gtk','4.0')
from gi.repository import Gtk

def activate(app):
    builder = Gtk.Builder()
    builder.add_from_file('launch.ui')
    window = builder.get_object('mainwindow')
    window.set_application(app)
    window.present()
if __name__ == '__main__':
    app = Gtk.Application(application_id="com.tideflow.Launcher")
    app.connect('activate', activate)
    app.run(None)
