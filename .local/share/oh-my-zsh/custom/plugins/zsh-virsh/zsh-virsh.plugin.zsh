if (( ! $+commands[virsh] )); then
  return
fi

virsh-rm-pool() {
  virsh pool-autostart "${1}" --disable
  virsh pool-destroy "${1}"
  virsh pool-undefine "${1}"
}
