project('craftuniverse',
	['c', 'vala'],
	version: '0.1.0',
	license: 'GPL3+',
	meson_version: '>= 0.49.0',
)
i18n = import('i18n')
gnome = import('gnome')


subdir('data')
subdir('src')
subdir('po')
meson.add_install_script('build-aux/meson/postinstall.py')