import { locales, localePath } from '../i18n'

const SITE = 'https://cyrill62.github.io/oh-my-nu/'

export default function Head() {
  // vike-react adds title, description and their og: tags from the page config.
  return (
    <>
      <meta name="theme-color" content="#0a1412" />
      <meta property="og:type" content="website" />
      <meta property="og:image" content={`${SITE}logo.svg`} />
      {locales.map((locale) => (
        <link key={locale} rel="alternate" hrefLang={locale} href={SITE + localePath(locale)} />
      ))}
    </>
  )
}
