# Source from .zshrc to open Grove in the current Herdr workspace.
function /grove() {
  if [[ ${HERDR_ENV:-} != 1 ]]; then
    print -u2 -- 'Open Grove from a shell pane inside Herdr.'
    return 1
  fi
  if (( $# )); then
    print -u2 -- 'Usage: /grove, with no arguments.'
    return 2
  fi
  command herdr plugin action invoke open --plugin local.herdr-grove
}
