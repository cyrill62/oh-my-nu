import { AnimatePresence, LayoutGroup, motion, useReducedMotion } from 'motion/react'
import { useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import type { Plugin } from '../pages/+data'

type Filter = 'all' | 'individual' | 'generated'

const COLLAPSED = 18
const FEATURED = ['git', 'cargo', 'docker', 'rmux', 'apt', 'pacman', 'gentoo', 'kubectl', 'extract', 'python', 'eza', 'jump']

function matches(plugin: Plugin, query: string) {
  if (!query) return true
  const q = query.toLowerCase()
  return (
    plugin.name.includes(q) ||
    plugin.description.toLowerCase().includes(q) ||
    plugin.requires.some((r) => r.toLowerCase().includes(q)) ||
    plugin.commands.some((c) => c.toLowerCase() === q)
  )
}

/** Featured plugins first, then the others alphabetically. */
function order(plugins: Plugin[]) {
  const rank = (p: Plugin) => {
    const i = FEATURED.indexOf(p.name)
    return i === -1 ? FEATURED.length : i
  }
  return [...plugins].sort((a, b) => rank(a) - rank(b) || a.name.localeCompare(b.name))
}

export function PluginExplorer({ plugins }: { plugins: Plugin[] }) {
  const { t } = useTranslation()
  const reduced = useReducedMotion()
  const [query, setQuery] = useState('')
  const [filter, setFilter] = useState<Filter>('all')
  const [expanded, setExpanded] = useState(false)

  const ordered = useMemo(() => order(plugins), [plugins])
  const found = ordered.filter(
    (p) =>
      (filter === 'all' || (filter === 'generated') === p.generated) && matches(p, query.trim()),
  )
  const visible = expanded || query ? found : found.slice(0, COLLAPSED)

  return (
    <div className="explorer">
      <div className="explorer-controls">
        <input
          type="search"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder={t('plugins.search')}
          aria-label={t('plugins.search')}
        />
        <div className="chips" role="radiogroup">
          {(['all', 'individual', 'generated'] as const).map((f) => (
            <button
              key={f}
              type="button"
              role="radio"
              aria-checked={filter === f}
              className={filter === f ? 'chip active' : 'chip'}
              onClick={() => setFilter(f)}
            >
              {t(`plugins.${f}`)}
            </button>
          ))}
        </div>
        <span className="explorer-count">{t('plugins.shown', { shown: visible.length, total: found.length })}</span>
      </div>

      <LayoutGroup>
        <motion.ul className="plugin-grid" layout={!reduced}>
          <AnimatePresence mode="popLayout" initial={false}>
            {visible.map((p) => (
              <motion.li
                key={p.name}
                className="plugin-card"
                layout={!reduced}
                initial={{ opacity: 0, scale: 0.96 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.96 }}
                transition={{ duration: 0.2 }}
              >
                <div className="plugin-head">
                  <h3>{p.name}</h3>
                  {p.generated && <span className="tag">{t('plugins.generatedTag')}</span>}
                </div>
                <p>{p.description}</p>
                <div className="plugin-meta">
                  <span>{t('plugins.commands', { count: p.commands.length })}</span>
                  {p.requires.length > 0 && (
                    <span className="requires">{t('plugins.requires', { tools: p.requires.join(' ') })}</span>
                  )}
                </div>
                <div className="plugin-commands" aria-label={p.name}>
                  {p.commands.slice(0, 6).map((c) => (
                    <code key={c}>{c}</code>
                  ))}
                  {p.commands.length > 6 && <code className="more">+{p.commands.length - 6}</code>}
                </div>
              </motion.li>
            ))}
          </AnimatePresence>
        </motion.ul>
      </LayoutGroup>

      {found.length === 0 && <p className="empty">{t('plugins.empty', { query })}</p>}
      {!query && found.length > COLLAPSED && (
        <button type="button" className="button ghost center" onClick={() => setExpanded((e) => !e)}>
          {expanded ? t('plugins.less') : t('plugins.more', { count: found.length })}
        </button>
      )}
    </div>
  )
}
