p6df::modules::python::version() { echo "0.0.1" }
p6df::modules::python::deps()    { ModuleDeps=(pyenv/pyenv) }

p6df::modules::python::external::brew() {

}

p6df::modules::python::home::symlink() {

  ln -fs $P6_DFZ_SRC_P6M7G8_DIR/p6df-python/share/.pip .pip
}

p6df::modules::python::langs() {

  pyenv install 3.7.3
  pyenv global 3.7.3
  pip install --upgrade pip
  pyenv rehash
  pip install pipenv
  pip install tox
}

p6df::modules::python::init() {

  p6df::modules::python::pyenv::init "$P6_DFZ_SRC_DIR"
  p6df::modules::python::pipenv::init
}

p6df::modules::python::pipenv::init() {
  
  [ -n "$DISABLE_ENVS" ] && return

  eval "$(pipenv --completion)"
}

p6df::modules::python::pyenv::init() {
  local dir="$1"

  [ -n "$DISABLE_ENVS" ] && return

  PYENV_ROOT=$dir/pyenv/pyenv

  if [ -x $PYENV_ROOT/bin/pyenv ]; then
    export PYENV_ROOT
    export HAS_PYENV=1
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1

    p6df::util::path_if $PYENV_ROOT/bin
    eval "$(pyenv init - zsh)"
  fi
}    

p6df::prompt::pipenv::line() {

  local env=$(pipenv --venv 2>/dev/null)

  if [ -n "$env" ]; then
    env=$(basename $env)
    echo "pipenv: $env"
  fi
}

p6df::prompt::python::line() {

  p6_lang_version "py"
}
