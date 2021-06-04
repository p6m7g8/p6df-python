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

  p6_return_void
}

######################################################################
#<
#
# Function: p6df::modules::python::vscodes()
#
#>
######################################################################
p6df::modules::python::vscodes() {

  brew install --cask kite
  code --install-extension ms-python.python
  code --install-extension FedericoVarela.pipenv-scripts
  code --install-extension ms-python.vscode-pylance

  p6_return_void
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

  p6_return_void
}

######################################################################
#<
#
# Function: p6df::modules::python::external::brew()
#
#>
######################################################################
p6df::modules::python::external::brew() {

  brew install watchman

  p6_return_void
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

  p6_return_void
}

######################################################################
#<
#
# Function: p6df::modules::python::langs()
#
#>
######################################################################
p6df::modules::python::langs() {

  p6df::modules::python::langs::pull
  p6df::modules::python::langs::nuke
  p6df::modules::python::langs::install
  p6df::modules::python::langs::pip

  p6_return_void
}

######################################################################
#<
#
# Function: p6df::modules::python::langs::install()
#
#>
######################################################################
p6df::modules::python::langs::install() {

  # get the shiny one
  local latest
  latest=$(pyenv install -l | grep '^ *3' | grep -v "[a-z]" | tail -1 | sed -e 's, *,,g')
  pyenv install -s $latest
  pyenv global $latest
  pyenv rehash

  p6_return_void
}

######################################################################
#<
#
# Function: p6df::modules::python::langs::nuke()
#
#>
######################################################################
p6df::modules::python::langs::nuke() {

  # nuke the old one
  local previous
  previous=$(pyenv install -l | grep '^ *3' | grep -v "[a-z]" | tail -2 | head -1 | sed -e 's, *,,g')
  pyenv uninstall -f $previous

  p6_return_void
}

######################################################################
#<
#
# Function: p6df::modules::python::langs::pull()
#
#  Depends:	 p6_git
#  Environment:	 P6_DFZ_SRC_DIR
#>
######################################################################
p6df::modules::python::langs::pull() {

  (
    cd $P6_DFZ_SRC_DIR/pyenv/pyenv
    p6_git_p6_pull
  )

  p6_return_void
}

######################################################################
#<
#
# Function: p6df::modules::python::langs::eggs()
#
#>
######################################################################
p6df::modules::python::langs::eggs() {

  Eggs=(
    "pip"
    "wheel"
    "autopep8"
    "bandit"
    "black"
    "flake9"
    "jedi"
    "mpyp"
    "nose"
    "pep8"
    "prospector"
    "pycodestyle"
    "pydocstyle"
    "pylama"
    "pylint"
    "pyre-check"
    "tox"
    "yamllint"
    "yapf"
  )

  p6_return_void
}

######################################################################
#<
#
# Function: p6df::modules::python::langs::pipenv()
#
#>
######################################################################
p6df::modules::python::langs::pipenv() {

  pip install pipenv

  p6df::modules::python::langs::eggs

  local egg
  for egg in $Eggs[@]; do
    pipenv install $egg
  done

  p6_return_void
}

######################################################################
#<
#
# Function: p6df::modules::python::langs::pip()
#
#>
######################################################################
p6df::modules::python::langs::pip() {

  p6df::modules::python::langs::eggs

  pip install pip --upgrade

  local egg
  for egg in $Eggs[@]; do
    pip install $egg
  done
  pyenv rehash

  p6_return_void
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

  p6_return_void
}

######################################################################
#<
#
# Function: p6df::modules::python::pipenv::init()
#
#  Depends:	 p6_string
#  Environment:	 DISABLE_ENVS
#>
######################################################################
p6df::modules::python::pipenv::init() {

  if p6_string_blank "$DISABLE_ENVS"; then
    eval "$(p6_run_code pipenv --completion)"
  fi
}

######################################################################
#<
#
# Function: p6df::modules::python::pyenv::init(dir)
#
#  Args:
#	dir -
#
#  Depends:	 p6_echo p6_env p6_string
#  Environment:	 DISABLE_ENVS HAS_PYENV PYENV_ROOT PYENV_VIRTUALENV_DISABLE_PROMPT
#>
######################################################################
p6df::modules::python::pyenv::init() {
  local dir="$1"

  if p6_string_blank "$DISABLE_ENVS"; then
    PYENV_ROOT=$dir/pyenv/pyenv
    if [ -x $PYENV_ROOT/bin/pyenv ]; then
      p6_env_export "PYENV_ROOT" "$PYENV_ROOT"
      p6_env_export "HAS_PYENV" "1"
      p6_env_export "PYENV_VIRTUALENV_DISABLE_PROMPT" "1"

      p6df::util::path_if $PYENV_ROOT/bin
      p6df::util::path_if $PYENV_ROOT/shims
      eval "$(pyenv init -)"
    fi
  fi

  p6_return_void
}

######################################################################
#<
#
# Function: str str = p6df::modules::python::pyenv::prompt::line()
#
#  Returns:
#	str - str
#
#  Depends:	 p6_pipenv
#  Environment:	 PYENV_ROOT
#>
######################################################################
p6df::modules::python::pyenv::prompt::line() {

  local str="pyenv:\t  pyenv_root=$PYENV_ROOT"

  p6_return_str "$str"
}

######################################################################
#<
#
# Function: p6df::modules::python::pipenv::prompt::line()
#
#  Depends:	 p6_pipenv p6_string
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
#  Depends:	 p6_pipenv p6_string
#  Environment:	 PIPENV_ACTIVE
#>
######################################################################
p6_pipenv_prompt_info() {

  local env
  env=$(p6_run_code pipenv --venv 2>/dev/null)

  local str
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
#  Depends:	 p6_lang p6_pipenv
#>
######################################################################
p6df::modules::python::prompt::line() {

  p6_python_prompt_info
  p6_pipenv_prompt_info
}

######################################################################
#<
#
# Function: str str = p6_python_prompt_info()
#
#  Returns:
#	str - str
#
#>
######################################################################
p6_python_prompt_info() {

  local str
  local ver
  ver=$(p6_lang_version "py")

  str="py:\t  $ver"

  p6_return_str "$str"
}
