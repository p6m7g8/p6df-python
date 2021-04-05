######################################################################
#<
#
# Function: p6df::modules::python::deps()
#
#>
######################################################################
p6df::modules::python::deps() {
  ModuleDeps=(
    p6m7g8/p6common
    pyenv/pyenv
    ohmyzsh/ohmyzsh:plugins/pipenv
  )
}

p6df::modules::python::vscodes() {

  # python
  brew install --cask kite
  code --install-extension ms-python.python
  code --install-extension FedericoVarela.pipenv-scripts
  code --install-extension ms-python.vscode-pylance
}

######################################################################
#<
#
# Function: p6df::modules::python::external::yum()
#
#>
######################################################################
p6df::modules::python::external::yum() {

  sudo yum install gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel
}

######################################################################
#<
#
# Function: p6df::modules::python::external::brew()
#
#>
######################################################################
p6df::modules::python::external::brew() {

  brew install --cask kite
  brew install watchman
}

######################################################################
#<
#
# Function: p6df::modules::python::home::symlink()
#
#  Environment:	 P6_DFZ_SRC_P6M7G8_DIR
#>
######################################################################
p6df::modules::python::home::symlink() {

  echo ln -fs $P6_DFZ_SRC_P6M7G8_DIR/p6df-python/share/.pip .pip
  ln -fs $P6_DFZ_SRC_P6M7G8_DIR/p6df-python/share/.pip .pip
}

######################################################################
#<
#
# Function: p6df::modules::python::langs()
#
#  Environment:	 P6_DFZ_SRC_DIR
#>
######################################################################
p6df::modules::python::langs() {

  (
    cd $P6_DFZ_SRC_DIR/pyenv/pyenv
    git pull
  )

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

  pip install -q tox

  pip install -q yamllint

  pip install -q nose
  pip install -q pylint
  pip install -q prospector
  pip install -q mypy
  pip install -q pylama
  pip install -q pydocstyle
  pip install -q flake9
  pip install -q bandit
  pip install -q pycodestyle

  pip install -q pep8
  pip install --upgrade autopep8
  pip install black
  pip install yapf
  pip install jedi

  pip install -q pyre-check
  pip install pipenv

  pyenv rehash
}

######################################################################
#<
#
# Function: p6df::modules::python::init()
#
#  Environment:	 P6_DFZ_SRC_DIR
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
#  Environment:	 DISABLE_ENVS
#>
######################################################################
p6df::modules::python::pipenv::init() {

  [ -n "$DISABLE_ENVS" ] && return

  eval "$(p6_run_code pipenv --completion)"
}

######################################################################
#<
#
# Function: p6df::modules::python::pyenv::init(dir)
#
#  Args:
#	dir -
#
#  Environment:	 DISABLE_ENVS HAS_PYENV PYENV_ROOT PYENV_VIRTUALENV_DISABLE_PROMPT
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
    eval "$(p6_run_code pyenv init - zsh)"
  fi
}

######################################################################
#<
#
# Function: p6df::modules::python::pyenv::prompt::line()
#
#  Depends:	 p6_echo
#  Environment:	 PYENV_ROOT
#>
######################################################################
p6df::modules::python::pyenv::prompt::line() {

  p6_echo "pyenv:\t  pyenv_root=$PYENV_ROOT"
}

######################################################################
#<
#
# Function: p6df::modules::python::pipenv::prompt::line()
#
#  Depends:	 p6_pipenv
#>
######################################################################
p6df::modules::python::pipenv::prompt::line() {

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
#  Depends:	 p6_string
#  Environment:	 PIPENV_ACTIVE
#>
######################################################################
p6_pipenv_prompt_info() {

  local env
  env=$(p6_run_code pipenv --venv 2>/dev/null)
  local str=

  if ! p6_string_blank "$env"; then
    env=$(p6_uri_name "$env")

    local astr
    if p6_string_eq "$PIPENV_ACTIVE" "1"; then
      astr="active"
    else
      astr="off"
    fi

    str="pipenv:   $env ($astr)"
    p6_return_str "$str"
  else
    p6_return_void
  fi
}

######################################################################
#<
#
# Function: p6df::modules::python::prompt::line()
#
#  Depends:	 p6_pipenv
#>
######################################################################
p6df::modules::python::prompt::line() {

  p6_python_prompt_info
  p6_pipenv_prompt_info
}

######################################################################
#<
#
# Function: p6_python_prompt_info()
#
#  Depends:	 p6_lang
#>
######################################################################
p6_python_prompt_info() {

  echo -n "py:\t  "
  p6_lang_version "py"
}
