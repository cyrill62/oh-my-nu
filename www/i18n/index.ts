import { createInstance, type i18n } from 'i18next'
import { initReactI18next } from 'react-i18next'
import { en } from './en'
import { fr } from './fr'

export const locales = ['en', 'fr'] as const
export type Locale = (typeof locales)[number]
export const defaultLocale: Locale = 'en'

/** Path of a locale's home page, relative to the site root: '' or 'fr/'. */
export function localePath(locale: Locale): string {
  return locale === defaultLocale ? '' : `${locale}/`
}

const instances = new Map<Locale, i18n>()

/** One synchronously initialised i18next instance per locale (resources are bundled). */
export function getI18n(locale: Locale): i18n {
  let instance = instances.get(locale)
  if (!instance) {
    instance = createInstance()
    instance.use(initReactI18next).init({
      lng: locale,
      fallbackLng: defaultLocale,
      resources: { en: { translation: en }, fr: { translation: fr } },
      interpolation: { escapeValue: false },
      initAsync: false,
    })
    instances.set(locale, instance)
  }
  return instance
}
