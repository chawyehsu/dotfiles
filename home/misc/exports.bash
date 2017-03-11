case "${OSTYPE}" in
  linux*)
    export PYENV_ROOT="${HOME}/.pyenv"
    export PATH="${PYENV_ROOT}/bin:${PATH}"
    ;;
esac
