import { motion, useReducedMotion, useScroll, useTransform } from 'motion/react'
import { useTranslation } from 'react-i18next'
import { useData } from 'vike-react/useData'
import { localePath, locales, type Locale } from '../i18n'
import type { Data } from '../pages/+data'
import { CopyCode, Counter, Icon, Reveal } from './bits'
import { PluginExplorer } from './PluginExplorer'
import { Terminal } from './Terminal'

const BASE = import.meta.env.BASE_URL
const REPO = 'https://github.com/cyrill62/oh-my-nu'
const INSTALLER = 'https://cyrill62.github.io/oh-my-nu/install.nu'
const STEPS = [`nu -c (http get ${INSTALLER})`, 'omn enable git cargo', 'omn list --enabled']

export function Home() {
  const { t, i18n } = useTranslation()
  const { version, plugins, omzTotal, testGroups } = useData<Data>()
  const commandCount = plugins.reduce((n, p) => n + p.commands.length, 0)
  const generated = plugins.filter((p) => p.generated).length

  return (
    <>
      <Nav current={i18n.language as Locale} />
      <main>
        <Hero version={version} count={plugins.length} />

        <section className="stats" aria-label="oh-my-nu in numbers">
          {[
            [plugins.length, t('stats.plugins')],
            [commandCount, t('stats.commands')],
            [omzTotal, t('stats.omz')],
            [testGroups, t('stats.tests')],
          ].map(([value, label], i) => (
            <Reveal key={label} delay={i * 0.08} className="stat">
              <strong>
                <Counter value={value as number} />
              </strong>
              <span>{label}</span>
            </Reveal>
          ))}
        </section>

        <section id="features" className="section">
          <Reveal>
            <h2>{t('features.title')}</h2>
            <p className="section-lead">{t('features.subtitle')}</p>
          </Reveal>
          <div className="feature-grid">
            {(t('features.items', { returnObjects: true }) as { icon: string; title: string; text: string }[]).map(
              (f, i) => (
                <Reveal key={f.title} delay={(i % 3) * 0.08} className="feature">
                  <div className="feature-icon">
                    <Icon name={f.icon} />
                  </div>
                  <h3>{f.title}</h3>
                  <p>{f.text}</p>
                </Reveal>
              ),
            )}
          </div>
        </section>

        <section id="plugins" className="section">
          <Reveal>
            <h2>{t('plugins.title')}</h2>
            <p className="section-lead">
              {t('plugins.subtitle', { individual: plugins.length - generated, generated })}
            </p>
          </Reveal>
          <PluginExplorer plugins={plugins} />
        </section>

        <section id="commands" className="section">
          <Reveal>
            <h2>{t('commands.title')}</h2>
            <p className="section-lead">{t('commands.subtitle')}</p>
          </Reveal>
          <Reveal className="command-list">
            {(t('commands.items', { returnObjects: true }) as { cmd: string; text: string }[]).map((c) => (
              <div key={c.cmd} className="command-row">
                <code>{c.cmd}</code>
                <span>{c.text}</span>
              </div>
            ))}
          </Reveal>
        </section>

        <section id="start" className="section">
          <Reveal>
            <h2>{t('start.title')}</h2>
            <p className="section-lead">{t('start.subtitle')}</p>
          </Reveal>
          <div className="steps">
            {(t('start.steps', { returnObjects: true }) as { title: string; text: string }[]).map((s, i) => (
              <Reveal key={s.title} delay={i * 0.1} className="step">
                <span className="step-number">{i + 1}</span>
                <div>
                  <h3>{s.title}</h3>
                  <p>{s.text}</p>
                  <CopyCode code={STEPS[i]} />
                </div>
              </Reveal>
            ))}
          </div>
        </section>

        <section className="section">
          <Reveal className="ai-note">
            <h2>{t('ai.title')}</h2>
            {(t('ai.text', { returnObjects: true }) as string[]).map((p) => (
              <p key={p}>{p}</p>
            ))}
            <a href={`${REPO}/blob/main/AGENTS.md`}>{t('ai.agents')}</a>
          </Reveal>
        </section>
      </main>

      <footer className="footer">
        <img src={`${BASE}logo.svg`} alt="" width="28" height="28" />
        <span>oh-my-nu {version}</span>
        <a href={REPO}>{t('footer.source')}</a>
        <a href={`${REPO}#readme`}>{t('footer.readme')}</a>
        <a href={`${REPO}/blob/main/COVERAGE.md`}>{t('footer.coverage')}</a>
        <small>{t('footer.disclaimer')}</small>
      </footer>
    </>
  )
}

function Nav({ current }: { current: Locale }) {
  const { t } = useTranslation()
  return (
    <header className="nav">
      <a className="brand" href={BASE + localePath(current)}>
        <img src={`${BASE}logo.svg`} alt="" width="32" height="32" />
        <span>oh-my-nu</span>
      </a>
      <nav aria-label="Sections">
        <a href="#features">{t('nav.features')}</a>
        <a href="#plugins">{t('nav.plugins')}</a>
        <a href="#commands">{t('nav.commands')}</a>
        <a href="#start">{t('nav.start')}</a>
      </nav>
      <div className="nav-end">
        <div className="lang" role="group" aria-label={t('nav.language')}>
          {locales.map((l) => (
            <a key={l} href={BASE + localePath(l)} hrefLang={l} aria-current={l === current ? 'page' : undefined}>
              {l.toUpperCase()}
            </a>
          ))}
        </div>
        <a className="github" href={REPO} aria-label={t('nav.github')}>
          <Icon name="github" filled />
        </a>
      </div>
    </header>
  )
}

function Hero({ version, count }: { version: string; count: number }) {
  const { t } = useTranslation()
  const reduced = useReducedMotion()
  const { scrollY } = useScroll()
  const glowY = useTransform(scrollY, [0, 600], [0, reduced ? 0 : 160])
  const enter = (delay: number) => ({
    initial: { opacity: 0, y: 18 },
    animate: { opacity: 1, y: 0 },
    transition: { duration: 0.6, delay, ease: [0.22, 1, 0.36, 1] as const },
  })

  return (
    <section className="hero">
      <motion.div className="hero-glow" style={{ y: glowY }} aria-hidden />
      <div className="hero-text">
        <motion.img
          className="hero-logo"
          src={`${BASE}logo.svg`}
          alt=""
          width="88"
          height="88"
          initial={{ opacity: 0, scale: 0.6, rotate: -12 }}
          animate={{ opacity: 1, scale: 1, rotate: 0 }}
          transition={{ type: 'spring', stiffness: 180, damping: 14 }}
        />
        <motion.span className="badge" {...enter(0.05)}>
          {t('hero.badge', { version })}
        </motion.span>
        <motion.h1 {...enter(0.1)}>oh-my-nu</motion.h1>
        <motion.p className="tagline" {...enter(0.18)}>
          {t('hero.tagline')}
        </motion.p>
        <motion.p className="lead" {...enter(0.26)}>
          {t('hero.lead', { count })}
        </motion.p>
        <motion.div className="hero-actions" {...enter(0.34)}>
          <a className="button primary" href="#start">
            {t('hero.start')}
          </a>
          <a className="button ghost" href="#plugins">
            {t('hero.browse')}
          </a>
        </motion.div>
      </div>
      <motion.div
        className="hero-demo"
        initial={{ opacity: 0, x: 30 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.7, delay: 0.3, ease: [0.22, 1, 0.36, 1] }}
      >
        <Terminal />
      </motion.div>
    </section>
  )
}
