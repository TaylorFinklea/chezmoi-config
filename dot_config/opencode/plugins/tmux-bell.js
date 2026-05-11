export const TmuxBellPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type !== "session.idle") return

      await $`sh -c 'printf "\a" > /dev/tty 2>/dev/null || true'`
    },
  }
}
