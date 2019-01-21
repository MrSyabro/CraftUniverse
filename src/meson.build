craftuniverse_sources = [
  'main.vala',
  'ui/AuthWindow.vala',
  'ui/MainWindow.vala',
  'ui/SettingsWindow.vala',
  #'ui/StarterWindow.vala',
  'core/User.vala',
  'core/Settings.vala',
  'core/Build.vala',
  'core/TaskData.vala',
  'core/Utils.vala'
]

craftuniverse_deps = [
  dependency('gio-2.0'),
  dependency('gtk+-3.0'),
  dependency('glib-2.0', version: '>= 2.54'),
  dependency('gee-0.8'),
  dependency('json-glib-1.0'),
  dependency('libsoup-2.4'),
]

executable('craftuniverse', craftuniverse_sources + resources,
  dependencies: craftuniverse_deps,
  install: true,
)