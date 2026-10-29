import { AnimatePresence, motion, useInView, useReducedMotion } from 'motion/react'
import { useEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'

type Line = { text: string; tone?: 'dim' | 'warn' | 'head' }
type Scene = { command: string; output: Line[] }

// Real output of these commands, with made-up branch names.
const SCENES: Scene[] = [
  {
    command: 'omn enable git cargo docker kubectl',
    output: [
      { text: 'oh-my-nu: 3 plugins in ~/.config/nushell/autoload/oh-my-nu.nu' },
      { text: '  skipped kubectl: kubectl not found', tone: 'warn' },
      { text: '  start a new shell (or run `omn reload`) to use them', tone: 'dim' },
    ],
  },
  {
    command: 'gbt | where upstream == "" | select branch date',
    output: [
      { text: '╭───┬───────────────┬─────────────╮', tone: 'dim' },
      { text: '│ # │    branch     │    date     │', tone: 'head' },
      { text: '├───┼───────────────┼─────────────┤', tone: 'dim' },
      { text: '│ 0 │ feature/www   │ 2 hours ago │' },
      { text: '│ 1 │ fix/ssh-agent │ 3 days ago  │' },
      { text: '╰───┴───────────────┴─────────────╯', tone: 'dim' },
    ],
  },
  {
    command: 'omn aliases git | where does =~ push | first 3',
    output: [
      { text: '╭───┬────────┬──────┬────────────────────────────────╮', tone: 'dim' },
      { text: '│ # │ plugin │ name │              does              │', tone: 'head' },
      { text: '├───┼────────┼──────┼────────────────────────────────┤', tone: 'dim' },
      { text: '│ 0 │ git    │ gp   │ git push                       │' },
      { text: '│ 1 │ git    │ gpd  │ git push --dry-run             │' },
      { text: '│ 2 │ git    │ gpf! │ git push --force               │' },
      { text: '╰───┴────────┴──────┴────────────────────────────────╯', tone: 'dim' },
    ],
  },
  {
    command: 'omn list --failed | select name status',
    output: [
      { text: '╭───┬─────────┬────────────────────────╮', tone: 'dim' },
      { text: '│ # │  name   │         status         │', tone: 'head' },
      { text: '├───┼─────────┼────────────────────────┤', tone: 'dim' },
      { text: '│ 0 │ kubectl │ skipped: needs kubectl │' },
      { text: '╰───┴─────────┴────────────────────────╯', tone: 'dim' },
    ],
  },
]

const TYPE_MS = 38
const OUTPUT_DELAY_MS = 350
const HOLD_MS = 2600

/**
 * A fake terminal typing a few commands in a loop. The first scene is rendered
 * complete on the server, so the page reads fine without JavaScript.
 */
export function Terminal() {
  const { t } = useTranslation()
  const reduced = useReducedMotion()
  const ref = useRef<HTMLDivElement>(null)
  const inView = useInView(ref, { amount: 0.4 })
  const [scene, setScene] = useState(0)
  const [typed, setTyped] = useState(SCENES[0].command.length)
  const [showOutput, setShowOutput] = useState(true)

  const current = SCENES[scene]
  const done = typed >= current.command.length

  useEffect(() => {
    if (reduced || !inView) return
    let timer: ReturnType<typeof setTimeout>
    if (!done) {
      timer = setTimeout(() => setTyped((n) => n + 1), TYPE_MS + Math.random() * 40)
    } else if (!showOutput) {
      timer = setTimeout(() => setShowOutput(true), OUTPUT_DELAY_MS)
    } else {
      timer = setTimeout(() => {
        setScene((s) => (s + 1) % SCENES.length)
        setTyped(0)
        setShowOutput(false)
      }, HOLD_MS)
    }
    return () => clearTimeout(timer)
  }, [reduced, inView, done, showOutput])

  return (
    <div className="terminal" ref={ref} role="img" aria-label={t('demo.label')}>
      <div className="terminal-bar" aria-hidden>
        <span className="dot red" />
        <span className="dot yellow" />
        <span className="dot green" />
        <span className="terminal-title">nu</span>
      </div>
      <pre className="terminal-body" aria-hidden>
        <span className="prompt-path">~/projects/oh-my-nu</span>
        {'\n'}
        <span className="prompt">❯ </span>
        <span className="command">{current.command.slice(0, typed)}</span>
        {!showOutput && <span className="caret" />}
        {'\n'}
        <AnimatePresence mode="wait">
          {showOutput && (
            <motion.span
              key={scene}
              className="output"
              initial={{ opacity: 0, y: 6 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.25 }}
            >
              {current.output.map((line, i) => (
                <span key={i} className={line.tone}>
                  {line.text}
                  {'\n'}
                </span>
              ))}
            </motion.span>
          )}
        </AnimatePresence>
      </pre>
    </div>
  )
}
