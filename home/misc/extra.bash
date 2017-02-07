# bash-completion:
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  source $(brew --prefix)/etc/bash_completion
fi

# nvm (node):
export NVM_DIR="${HOME}/.nvm"
source "$(brew --prefix nvm)/nvm.sh"


# pyenv, pyenv-virtualenv (python):
if which pyenv >/dev/null; then
  eval "$(pyenv init -)";
  # cf. https://github.com/yyuu/pyenv/issues/106#issuecomment-94921352
  if which pyenv >/dev/null; then
    alias brew="env PATH=${PATH//$(pyenv root)\/shims:/} brew"
  fi
fi
if which pyenv-virtualenv-init >/dev/null; then
  eval "$(pyenv virtualenv-init -)";
fi

# Restricting pip to virtual environments:
# cf. https://hackercodex.com/guide/python-development-environment-on-mac-osx/
export PIP_REQUIRE_VIRTUALENV=true
gpip() {
  PIP_REQUIRE_VIRTUALENV="" pip "$@"
}
