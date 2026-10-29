import { animate, motion, useInView, useReducedMotion } from 'motion/react'
import { useEffect, useRef, useState, type ReactNode } from 'react'
import { useTranslation } from 'react-i18next'

/** Fades and lifts its children in the first time they scroll into view. */
export function Reveal({ children, delay = 0, className }: { children: ReactNode; delay?: number; className?: string }) {
  return (
    <motion.div
      className={className}
      initial={{ opacity: 0, y: 24 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, amount: 0.2 }}
      transition={{ duration: 0.55, delay, ease: [0.22, 1, 0.36, 1] }}
    >
      {children}
    </motion.div>
  )
}

/** Counts up to `value` when it comes into view. Renders the final value on the server. */
export function Counter({ value }: { value: number }) {
  const ref = useRef<HTMLSpanElement>(null)
  const inView = useInView(ref, { once: true })
  const reduced = useReducedMotion()
  const started = useRef(false)

  useEffect(() => {
    const node = ref.current
    if (!node || !inView || reduced || started.current) return
    started.current = true
    const controls = animate(0, value, {
      duration: 1.4,
      ease: 'easeOut',
      onUpdate: (v) => (node.textContent = Math.round(v).toLocaleString('en')),
    })
    return () => controls.stop()
  }, [inView, reduced, value])

  return <span ref={ref}>{value.toLocaleString('en')}</span>
}

/** A one-line shell command with a copy button. */
export function CopyCode({ code }: { code: string }) {
  const { t } = useTranslation()
  const [copied, setCopied] = useState(false)
  const copy = async () => {
    try {
      await navigator.clipboard.writeText(code)
      setCopied(true)
      setTimeout(() => setCopied(false), 1600)
    } catch {
      // Clipboard unavailable (insecure context): the text can still be selected.
    }
  }
  return (
    <div className="copy-code">
      <code>
        <span className="prompt">❯ </span>
        {code}
      </code>
      <button type="button" onClick={copy} aria-live="polite">
        {copied ? t('hero.copied') : t('hero.copy')}
      </button>
    </div>
  )
}

const ICONS: Record<string, ReactNode> = {
  table: (
    <>
      <rect x="3" y="4" width="18" height="16" rx="2" />
      <path d="M3 9h18M3 14.5h18M9 9v11" />
    </>
  ),
  shield: (
    <>
      <path d="M12 3 4.5 6v5.5c0 4.6 3.2 8.3 7.5 9.5 4.3-1.2 7.5-4.9 7.5-9.5V6L12 3Z" />
      <path d="m8.5 12 2.5 2.5 4.5-5" />
    </>
  ),
  package: (
    <>
      <path d="m12 3 8.5 4.5v9L12 21l-8.5-4.5v-9L12 3Z" />
      <path d="m3.5 7.5 8.5 4.5 8.5-4.5M12 12v9" />
    </>
  ),
  manager: (
    <>
      <path d="M4 6h10M4 12h16M4 18h7" />
      <circle cx="17" cy="6" r="2" />
      <circle cx="14" cy="18" r="2" />
    </>
  ),
  plug: (
    <>
      <path d="M9 3v4M15 3v4M7 7h10v4a5 5 0 0 1-10 0V7ZM12 16v5" />
    </>
  ),
  check: (
    <>
      <circle cx="12" cy="12" r="9" />
      <path d="m8 12 3 3 5-6" />
    </>
  ),
  github: (
    <path d="M12 2a10 10 0 0 0-3.2 19.5c.5.1.7-.2.7-.5v-1.7c-2.8.6-3.4-1.3-3.4-1.3-.5-1.2-1.1-1.5-1.1-1.5-.9-.6.1-.6.1-.6 1 .1 1.5 1 1.5 1 .9 1.5 2.4 1.1 2.9.8.1-.6.4-1.1.6-1.3-2.2-.3-4.6-1.1-4.6-5 0-1.1.4-2 1-2.7-.1-.3-.4-1.3.1-2.7 0 0 .8-.3 2.8 1a9.6 9.6 0 0 1 5 0c1.9-1.3 2.8-1 2.8-1 .5 1.4.2 2.4.1 2.7.6.7 1 1.6 1 2.7 0 3.9-2.3 4.7-4.6 4.9.4.3.7.9.7 1.9V21c0 .3.2.6.7.5A10 10 0 0 0 12 2Z" />
  ),
}

export function Icon({ name, filled = false }: { name: string; filled?: boolean }) {
  return (
    <svg
      className="icon"
      viewBox="0 0 24 24"
      width="24"
      height="24"
      fill={filled ? 'currentColor' : 'none'}
      stroke={filled ? 'none' : 'currentColor'}
      strokeWidth="1.8"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden
    >
      {ICONS[name]}
    </svg>
  )
}
