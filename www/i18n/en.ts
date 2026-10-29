export const en = {
  meta: {
    title: 'oh-my-nu: Oh My Zsh-style plugins for Nushell',
    description:
      'Aliases and commands for git, cargo, docker, apt, pacman, portage and more, as Nushell modules that return tables.',
  },
  nav: {
    features: 'Features',
    plugins: 'Plugins',
    commands: 'Commands',
    start: 'Get started',
    github: 'GitHub',
    language: 'Language',
  },
  hero: {
    badge: 'v{{version}} · for Nushell',
    tagline: 'Oh My Zsh-style plugins for Nushell.',
    lead: '{{count}} plugins of aliases and commands for git, cargo, docker, apt, pacman, portage and more. Where it helps, they return tables you can filter, not text you have to grep.',
    start: 'Get started',
    browse: 'Browse the plugins',
    copy: 'Copy',
    copied: 'Copied',
  },
  demo: {
    label: 'An animated terminal session',
    replay: 'Replay',
  },
  stats: {
    plugins: 'plugins',
    commands: 'aliases and commands',
    omz: 'Oh My Zsh plugins reviewed',
    tests: 'test groups',
  },
  features: {
    title: 'Your Oh My Zsh muscle memory, in a structured shell',
    subtitle: 'gst, gco, dps, cb… the names you know, as plain Nushell modules.',
    items: [
      {
        icon: 'table',
        title: 'Tables, not text',
        text: 'Helpers like gbt, dpst or cdeps return Nushell tables: sort, filter and select columns instead of parsing output.',
      },
      {
        icon: 'shield',
        title: 'A shell that always starts',
        text: 'A plugin whose tool is missing is skipped. One that fails to parse is left out. Your shell never breaks on startup.',
      },
      {
        icon: 'package',
        title: 'Every package manager',
        text: 'apt, dpkg, dnf, yum, rpm, zypper, pacman, yay, Portage and OpenRC, with root only where it is needed.',
      },
      {
        icon: 'manager',
        title: 'A small manager: omn',
        text: 'Enable, disable, list, inspect and spot clashes. Nothing to add to config.nu: plugins load from the autoload directory.',
      },
      {
        icon: 'plug',
        title: 'Your own plugins',
        text: 'Drop a .nu file in ~/.config/oh-my-nu/custom to add a plugin, or to override a built-in one with the same name.',
      },
      {
        icon: 'check',
        title: 'Tested in a sandbox',
        text: 'Every plugin is parsed, and package managers are run against fake binaries that check the exact command lines.',
      },
    ],
  },
  plugins: {
    title: 'Plugins',
    subtitle: '{{individual}} written one by one, {{generated}} generated from Oh My Zsh’s alias plugins.',
    search: 'Search plugins, tools or commands',
    all: 'All',
    individual: 'Written individually',
    generated: 'Generated',
    generatedTag: 'generated',
    requires: 'needs {{tools}}',
    commands_one: '{{count}} command',
    commands_other: '{{count}} commands',
    shown: '{{shown}} of {{total}}',
    empty: 'No plugin matches “{{query}}”.',
    more: 'Show all {{count}}',
    less: 'Show fewer',
  },
  commands: {
    title: 'Managing plugins',
    subtitle: 'Everything goes through omn. `omn help` explains every option.',
    items: [
      { cmd: 'omn list', text: 'every plugin, whether it is enabled, and its status' },
      { cmd: 'omn list --failed', text: 'enabled plugins that are not loaded, and why' },
      { cmd: 'omn enable docker kubectl', text: 'enable plugins for the next shell' },
      { cmd: 'omn disable eza', text: 'disable a plugin' },
      { cmd: 'omn aliases | where does =~ push', text: 'find a shortcut' },
      { cmd: 'omn info git', text: 'a plugin’s description, file and commands' },
      { cmd: 'omn clashes', text: 'names defined by several enabled plugins' },
      { cmd: 'omn sync', text: 'reload the list after installing a tool' },
    ],
  },
  start: {
    title: 'Get started',
    subtitle: 'Needs Nushell 0.116 or newer. Nothing is written to config.nu.',
    steps: [
      {
        title: 'Install',
        text: 'Downloads the latest release into ~/.local/share/oh-my-nu and enables a sensible default set. Run it again to update.',
      },
      { title: 'Pick your plugins', text: 'Enable more, or disable some with omn disable.' },
      { title: 'Open a new shell', text: 'Then explore with omn list and omn help.' },
    ],
  },
  ai: {
    title: 'Made with AI tools',
    text: [
      'oh-my-nu was not written alone by its author. The plugins, the omn manager, the generators, the tests and this website were mostly written by an AI coding agent, Claude Code, working from the author’s requests, who directed the project and tested it on their own machine.',
      'Much of the work comes from Oh My Zsh’s plugins. The test suite covers a lot, but not everything: read a plugin before you enable it, especially one that runs commands as root. Bug reports and fixes are welcome.',
    ],
    agents: 'Conventions for contributors and agents: AGENTS.md',
  },
  footer: {
    source: 'Source on GitHub',
    readme: 'README',
    coverage: 'Oh My Zsh coverage',
    disclaimer: 'Not affiliated with Oh My Zsh or the Nushell project.',
  },
}

export type Resources = typeof en
