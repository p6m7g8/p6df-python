######################################################################
#<
#
# Function: p6df::modules::python::version()
#
#>
######################################################################
p6df::modules::python::version() { echo "0.0.1" }
######################################################################
#<
#
# Function: p6df::modules::python::deps()
#
#>
######################################################################
p6df::modules::python::deps()    { ModuleDeps=(pyenv/pyenv) }

######################################################################
#<
#
# Function: p6df::modules::python::external::brew()
#
#>
######################################################################
p6df::modules::python::external::brew() {

}

######################################################################
#<
#
# Function: p6df::modules::python::home::symlink()
#
#>
######################################################################
p6df::modules::python::home::symlink() {

  ln -fs $P6_DFZ_SRC_P6M7G8_DIR/p6df-python/share/.pip .pip
}

######################################################################
#<
#
# Function: p6df::modules::python::langs()
#
#>
######################################################################
p6df::modules::python::langs() {

  (cd $P6_DFZ_SRC_DIR/pyenv/pyenv ; git pull)
    
  # nuke the old one
  local previous=$(pyenv install -l | grep '^ *3' | grep -v "[a-z]" | tail -2 | head -1 | sed -e 's, *,,g')
  pyenv uninstall -f $previous

  # get the shiny one
  local latest=$(pyenv install -l | grep '^ *3' | grep -v "[a-z]" | tail -1 | sed -e 's, *,,g')
  pyenv install -s $latest
  pyenv global $latest
  pyenv rehash

  pip install --upgrade pip wheel
  pyenv rehash

  pip install pipenv
  pip install tox
  pip install yamllint
  pyenv rehash
}

######################################################################
#<
#
# Function: p6df::modules::python::init()
#
#>
######################################################################
p6df::modules::python::init() {

  p6df::modules::python::pyenv::init "$P6_DFZ_SRC_DIR"
  p6df::modules::python::pipenv::init
}

######################################################################
#<
#
# Function: p6df::modules::python::pipenv::init()
#
#>
######################################################################
p6df::modules::python::pipenv::init() {
  
  [ -n "$DISABLE_ENVS" ] && return

#  eval "$(pipenv --completion)"
}

######################################################################
#<
#
# Function: p6df::modules::python::pyenv::init(dir)
#
#  Args:
#	dir - 
#
#>
######################################################################
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

######################################################################
#<
#
# Function: p6df::prompt::pipenv::line()
#
#>
######################################################################
p6df::prompt::pipenv::line() {

  p6_pipenv_prompt_info
}

######################################################################
#<
#
# Function: str str = p6_pipenv_prompt_info()
#
#  Returns:
#	str - str
#
#>
######################################################################
p6_pipenv_prompt_info() {

  local env=$(pipenv --venv 2>/dev/null)
  local str=
  if ! p6_string_blank "$env"; then
    env=$(basename $env)
    str="pipenv: $env"
    p6_return_str "$str"
  else
    p6_return_void
  fi

}

######################################################################
#<
#
# Function: p6df::prompt::python::line()
#
#>
######################################################################
p6df::prompt::python::line() {

  p6_python_prompt_info
}

######################################################################
#<
#
# Function: p6_python_prompt_info()
#
#>
######################################################################
p6_python_prompt_info() {

  p6_lang_version "py"
}