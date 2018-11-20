craftuniverse_sources = [
  'main.vala',
  'AuthWindow.vala',
  'MainWindow.vala',
  'SettingsWindow.vala',
  'StarterWindow.vala',
  'User.vala',
  'Settings.vala',
  'Build.vala'
]

craftuniverse_deps = [
  dependency('gio-2.0'),
  dependency('gtk+-3.0'),
  dependency('glib-2.0', version: '>= 2.54'),
  dependency('gee-0.8'),
  dependency('json-glib-1.0'),
  dependency('libsoup-2.4')
]

gnome = import('gnome')

craftuniverse_sources += gnome.compile_resources('craftuniverse-resources',
  'craftuniverse.gresource.xml',
  c_name: 'craftuniverse'
)

executable('craftuniverse', craftuniverse_sources,
  dependencies: craftuniverse_deps,
  install: true,
)
