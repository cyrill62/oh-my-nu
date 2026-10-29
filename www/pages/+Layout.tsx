import { MotionConfig } from 'motion/react'
import type { ReactNode } from 'react'
import { I18nextProvider } from 'react-i18next'
import { usePageContext } from 'vike-react/usePageContext'
import { getI18n, locales, defaultLocale, type Locale } from '../i18n'
import './style.css'

export default function Layout({ children }: { children: ReactNode }) {
  const lang = usePageContext().config.lang
  const locale = typeof lang === 'string' && (locales as readonly string[]).includes(lang) ? (lang as Locale) : defaultLocale
  // reducedMotion="user": with the OS setting on, Motion skips movement and only fades.
  return (
    <MotionConfig reducedMotion="user">
      <I18nextProvider i18n={getI18n(locale)}>{children}</I18nextProvider>
    </MotionConfig>
  )
}
