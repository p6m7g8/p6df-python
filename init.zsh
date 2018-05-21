p6df::modules::python::version() { echo "0.0.1" }
p6df::modules::python::deps()    { 
	ModuleDeps=()
}

p6df::modules::python::external::brew() {
}

p6df::modules::python::init() {

  p6df::modules::python::pyenv::init
}

p6df::modules::python::pyenv::init() {
    [ -n "$DISABLE_ENVS" ] && return

    export PYENV_ROOT=/Users/pgollucci/.local/share/pyenv/pyenv
    p6dfz::util::path_if $PYENV_ROOT/bin

    if [ -x $PYENV_ROOT/bin/pyenv ]; then
      export HAS_PYENV=1
      eval "$(pyenv init - zsh)"
      eval "$(pyenv virtualenv-init - zsh)"
    fi
}

p6df::prompt::python::line() {

  env_version "py"
}

p6df::modules::python::init
