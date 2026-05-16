// @ts-nocheck
/** @jsxImportSource @opentui/solid */
import type { TuiPlugin, TuiThemeCurrent } from "@opencode-ai/plugin/tui"
import { useTerminalDimensions } from "@opentui/solid"
import { createMemo } from "solid-js"

const id = "gentle-logo"

const guayabaArt = [
  " █████   ███   █████ █████  █████ █████ █████ ██████████ ██████   █████",
  "▒▒███   ▒███  ▒▒███ ▒▒███  ▒▒███ ▒▒███ ▒▒███ ▒▒███▒▒▒▒▒█▒▒██████ ▒▒███ ",
  " ▒███   ▒███   ▒███  ▒███   ▒███  ▒▒███ ███   ▒███  █ ▒  ▒███▒███ ▒███ ",
  " ▒███   ▒███   ▒███  ▒███   ▒███   ▒▒█████    ▒██████    ▒███▒▒███▒███ ",
  " ▒▒███  █████  ███   ▒███   ▒███    ███▒███   ▒███▒▒█    ▒███ ▒▒██████ ",
  "  ▒▒▒█████▒█████▒    ▒███   ▒███   ███ ▒▒███  ▒███ ▒   █ ▒███  ▒▒█████ ",
  "    ▒▒███ ▒▒███      ▒▒████████   █████ █████ ██████████ █████  ▒▒█████",
  "     ▒▒▒   ▒▒▒        ▒▒▒▒▒▒▒▒   ▒▒▒▒▒ ▒▒▒▒▒ ▒▒▒▒▒▒▒▒▒▒ ▒▒▒▒▒    ▒▒▒▒▒",
]

// same art but with tighter spacing
const guayabaNarrow = guayabaArt.map((l) =>
  l.replace(/^ +/, "").replace(/  +/g, " ")
)

const compactArt = ["✦ G U A Y A B A ✦"]

const MAIN = "#e32064"
const SHADOW = "#5b0d28"

type Seg = { text: string; isShadow: boolean }

function splitLine(line: string): Seg[] {
  const segs: Seg[] = []
  let cur = ""
  let isShadow = line.length > 0 && line[0] === "▒"
  for (const ch of line) {
    const shade = ch === "▒"
    if (shade === isShadow) {
      cur += ch
    } else {
      if (cur) segs.push({ text: cur, isShadow })
      cur = ch
      isShadow = shade
    }
  }
  if (cur) segs.push({ text: cur, isShadow })
  return segs
}

const Logo = (props: { theme: TuiThemeCurrent }) => {
  const dim = useTerminalDimensions()
  const lines = createMemo(() => {
    const term = dim()
    if (term.height >= guayabaArt.length + 6 && term.width >= 100) return guayabaArt
    if (term.height >= guayabaNarrow.length + 6 && term.width >= 70) return guayabaNarrow
    return compactArt
  })

  return (
    <box flexDirection="column" alignItems="center">
      {lines().map((line) => (
        <box flexDirection="row">
          {splitLine(line).map((seg) => (
            <text fg={seg.isShadow ? SHADOW : MAIN}>{seg.text}</text>
          ))}
        </box>
      ))}
    </box>
  )
}

const tui: TuiPlugin = async (api) => {
  api.slots.register({
    id,
    order: 100,
    slots: {
      home_logo(ctx) {
        return <Logo theme={ctx.theme.current} />
      },
    },
  })
}

const plugin = { id: "gentle-logo", tui }
export default plugin
