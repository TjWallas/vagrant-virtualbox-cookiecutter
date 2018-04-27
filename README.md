# vagrant-virtualbox-cookiecutter
A cookiecutter template for generating tweaked Vagrant files for virtualbox.

*NOTE*: This template creates a Vagrant file in the current directory `.`. Cookiecutter fails to create a directory if it already exists on the filesystem by default. As `.` is used as the cookiecutter directory name, cookiecutter needs to be invoked with the `-f` option to force-overwrite files in an existing directory `.`.
