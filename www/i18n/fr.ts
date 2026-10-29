import type { Resources } from './en'

export const fr: Resources = {
  meta: {
    title: 'oh-my-nu : des plugins à la Oh My Zsh pour Nushell',
    description:
      'Des alias et des commandes pour git, cargo, docker, apt, pacman, portage et bien d’autres, sous forme de modules Nushell qui renvoient des tableaux.',
  },
  nav: {
    features: 'Fonctionnalités',
    plugins: 'Plugins',
    commands: 'Commandes',
    start: 'Démarrer',
    github: 'GitHub',
    language: 'Langue',
  },
  hero: {
    badge: 'v{{version}} · pour Nushell',
    tagline: 'Des plugins à la Oh My Zsh pour Nushell.',
    lead: '{{count}} plugins d’alias et de commandes pour git, cargo, docker, apt, pacman, portage et bien d’autres. Quand c’est utile, ils renvoient des tableaux à filtrer, pas du texte à passer dans grep.',
    start: 'Démarrer',
    browse: 'Voir les plugins',
    copy: 'Copier',
    copied: 'Copié',
  },
  demo: {
    label: 'Une session de terminal animée',
    replay: 'Rejouer',
  },
  stats: {
    plugins: 'plugins',
    commands: 'alias et commandes',
    omz: 'plugins Oh My Zsh passés en revue',
    tests: 'groupes de tests',
  },
  features: {
    title: 'Vos réflexes Oh My Zsh, dans un shell structuré',
    subtitle: 'gst, gco, dps, cb… les noms que vous connaissez, en simples modules Nushell.',
    items: [
      {
        icon: 'table',
        title: 'Des tableaux, pas du texte',
        text: 'gbt, dpst ou cdeps renvoient des tableaux Nushell : triez, filtrez et choisissez les colonnes au lieu d’analyser du texte.',
      },
      {
        icon: 'shield',
        title: 'Un shell qui démarre toujours',
        text: 'Un plugin dont l’outil manque est ignoré, un plugin qui ne se lit pas est écarté : votre shell ne casse jamais au démarrage.',
      },
      {
        icon: 'package',
        title: 'Tous les gestionnaires de paquets',
        text: 'apt, dpkg, dnf, yum, rpm, zypper, pacman, yay, Portage et OpenRC, avec les droits root seulement quand il le faut.',
      },
      {
        icon: 'manager',
        title: 'Un petit gestionnaire : omn',
        text: 'Activer, désactiver, lister, inspecter, repérer les conflits. Rien à ajouter à config.nu : les plugins se chargent depuis le dossier autoload.',
      },
      {
        icon: 'plug',
        title: 'Vos propres plugins',
        text: 'Déposez un fichier .nu dans ~/.config/oh-my-nu/custom pour ajouter un plugin, ou remplacer un plugin fourni du même nom.',
      },
      {
        icon: 'check',
        title: 'Testé dans un bac à sable',
        text: 'Chaque plugin est vérifié, et les gestionnaires de paquets sont lancés contre de faux binaires qui contrôlent les commandes exactes.',
      },
    ],
  },
  plugins: {
    title: 'Plugins',
    subtitle: '{{individual}} écrits un par un, {{generated}} générés à partir des plugins d’alias de Oh My Zsh.',
    search: 'Chercher un plugin, un outil ou une commande',
    all: 'Tous',
    individual: 'Écrits un par un',
    generated: 'Générés',
    generatedTag: 'généré',
    requires: 'nécessite {{tools}}',
    commands_one: '{{count}} commande',
    commands_other: '{{count}} commandes',
    shown: '{{shown}} sur {{total}}',
    empty: 'Aucun plugin ne correspond à « {{query}} ».',
    more: 'Afficher les {{count}}',
    less: 'Afficher moins',
  },
  commands: {
    title: 'Gérer les plugins',
    subtitle: 'Tout passe par omn. `omn help` explique chaque option.',
    items: [
      { cmd: 'omn list', text: 'tous les plugins, activés ou non, et leur état' },
      { cmd: 'omn list --failed', text: 'les plugins activés mais non chargés, et pourquoi' },
      { cmd: 'omn enable docker kubectl', text: 'activer des plugins pour le prochain shell' },
      { cmd: 'omn disable eza', text: 'désactiver un plugin' },
      { cmd: 'omn aliases | where does =~ push', text: 'retrouver un raccourci' },
      { cmd: 'omn info git', text: 'la description, le fichier et les commandes d’un plugin' },
      { cmd: 'omn clashes', text: 'les noms définis par plusieurs plugins activés' },
      { cmd: 'omn sync', text: 'mettre à jour après avoir installé un outil' },
    ],
  },
  start: {
    title: 'Démarrer',
    subtitle: 'Nécessite Nushell 0.116 ou plus récent. Rien n’est écrit dans config.nu.',
    steps: [
      { title: 'Cloner', text: 'Placez oh-my-nu où vous voulez.' },
      {
        title: 'Installer',
        text: 'Active une sélection par défaut. Donnez des noms de plugins pour choisir les vôtres.',
      },
      { title: 'Ouvrir un nouveau shell', text: 'Puis explorez avec omn list et omn help.' },
    ],
  },
  ai: {
    title: 'Fait avec des outils d’IA',
    text: [
      'oh-my-nu n’a pas été écrit seul par son auteur. Les plugins, le gestionnaire omn, les générateurs, les tests et ce site ont été écrits en grande partie par un agent de programmation IA, Claude Code, à partir des demandes de l’auteur, qui a dirigé le projet et l’a testé sur sa propre machine.',
      'Une bonne part du travail vient des plugins de Oh My Zsh. Les tests couvrent beaucoup de choses, mais pas tout : lisez un plugin avant de l’activer, surtout s’il lance des commandes en root. Les rapports de bugs et les correctifs sont les bienvenus.',
    ],
    agents: 'Conventions pour les contributeurs et les agents : AGENTS.md',
  },
  footer: {
    source: 'Code source sur GitHub',
    readme: 'README',
    coverage: 'Couverture de Oh My Zsh',
    disclaimer: 'Sans lien avec Oh My Zsh ni avec le projet Nushell.',
  },
}
