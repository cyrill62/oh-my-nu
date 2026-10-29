#!/usr/bin/env python3
"""Generate oh-my-nu plugins from Oh My Zsh plugins' aliases.

Usage: tools/port-omz.py OMZ_PLUGINS_DIR PLUGIN... > report.tsv

Simple aliases become nushell aliases. Aliases using shell syntax (pipes,
&&, $VARS...) become `--wrapped` commands that run the original text with
bash (or zsh for zsh-only syntax), with the arguments appended like zsh does.
Aliases that need Oh My Zsh's own functions, global aliases and names that
would shadow a nushell command are skipped and listed in the file header.
Names may clash with other plugins, as in Oh My Zsh; `omn sync` warns when
two enabled plugins define the same name.
"""

import collections
import json
import os
import re
import shlex
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PLUGINS = os.path.join(HERE, "..", "plugins")

ALIAS_RE = re.compile(r"""^\s*alias\s+(-g\s+)?((?:'[^']+'|"[^"]+"|[^\s=]+))=(.*)$""")
SIMPLE_WORD = re.compile(r"^[A-Za-z0-9_./:=@%+,~^-]+$")
SHELL_SYNTAX = re.compile(r"[|&;<>()`$*?{}\[\]!]|\\")
ZSH_ONLY = re.compile(r"\bnoglob\b|\$\{\(|=\(|\(\(|\bsetopt\b|\$\+commands|\$commands\[")


def nu_builtins():
    out = subprocess.run(
        ["nu", "--no-config-file", "--commands", "scope commands | where type != custom | get name | to json"],
        capture_output=True, text=True, check=True, stdin=subprocess.DEVNULL,
    ).stdout
    return set(json.loads(out))


def zsh_value(raw):
    """The alias value as zsh would see it (outer quotes removed)."""
    raw = raw.strip()
    # drop a trailing comment after the closing quote
    try:
        words = shlex.split(raw, comments=True, posix=True)
    except ValueError:
        return None
    if len(words) != 1:
        return " ".join(words) if words else None
    return words[0]


def nu_quote(word):
    if SIMPLE_WORD.match(word) and not word.startswith("#"):
        return word
    if "'" not in word:
        return f"'{word}'"
    return '"' + word.replace("\\", "\\\\").replace('"', '\\"') + '"'


def nu_name(name):
    return name if re.match(r"^[A-Za-z_][A-Za-z0-9_-]*$", name) else f"'{name}'"


def first_paragraph(readme):
    if not os.path.exists(readme):
        return ""
    text = open(readme, errors="replace").read()
    for para in re.split(r"\n\s*\n", text):
        para = para.strip()
        if not para or para.startswith(("#", "!", "<", "|", "```", "-", "*", ">")):
            continue
        para = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", " ".join(para.split()))
        para = para.replace("`", "")
        sentence = re.split(r"(?<=[.!?])\s", para)[0].rstrip(".:")
        return sentence[:110]
    return ""


# Tool a plugin needs, where the most common command in its aliases is not it.
REQUIRES = {
    "lol": "", "pow": "", "rake": "rake", "perl": "perl", "microk8s": "microk8s",
    "rails": "rails", "ruby": "ruby", "emacs": "emacs", "vscode": "code",
    "sublime": "subl", "sublime-merge": "smerge", "bridgetown": "bridgetown",
    "pre-commit": "pre-commit", "git-hubflow": "git-hf", "chucknorris": "fortune",
    "github": "gh", "yii": "", "cakephp3": "", "postgres": "pg_ctl",
}


def port(omz_dir, plugin, builtins):
    src_dir = os.path.join(omz_dir, plugin)
    source = ""
    for f in sorted(os.listdir(src_dir)):
        if f.endswith(".plugin.zsh") or (f.endswith(".zsh") and not f.startswith("_")):
            source += open(os.path.join(src_dir, f), errors="replace").read() + "\n"
    functions = set(re.findall(r"(?m)^\s*(?:function\s+([\w:.-]+)|([\w:.-]+)\s*\(\)\s*\{?)", source))
    functions = {a or b for a, b in functions}
    # Plugin settings such as `zstyle ... || _omz_x_php=php` or `: ${VAR:=default}`.
    variables = {}
    for name, value in re.findall(r"\|\|\s*(\w+)=([\w./-]+)", source):
        variables[name] = value
    for name, value in re.findall(r"(?m)^\s*(?:typeset\s+(?:-g\s+)?|local\s+)?(_omz\w+|ZSH_\w+)=['\"]?([\w./-]+)['\"]?\s*$", source):
        variables.setdefault(name, value)
    for name, value in re.findall(r":\s*\$\{(\w+):=([\w./-]+)\}", source):
        variables.setdefault(name, value)
    # Variables the plugin sets for itself: meaningless outside zsh.
    assigned = set(re.findall(r"(?m)^\s*(?:export\s+|typeset\s+(?:-\w+\s+)*|local\s+(?:-\w+\s+)*)?([A-Za-z_]\w*)=", source))
    assigned -= set(variables)
    aliases = []
    for line in source.splitlines():
        m = ALIAS_RE.match(line)
        if m:
            name = m.group(2).strip("'\"")
            aliases.append((bool(m.group(1)), name, m.group(3)))
    names = {n for _, n, _ in aliases}

    seen, out, skipped = set(), [], []
    firsts = collections.Counter()
    for is_global, name, raw in aliases:
        if name in seen:
            continue  # first definition wins (later ones are platform variants)
        value = zsh_value(raw)
        if value is not None:
            for var, default in variables.items():
                value = re.sub(r"\$\{?%s\}?(?!\w)" % re.escape(var), default, value)
            # nushell does not glob quoted or plain words the way zsh does
            value = re.sub(r"^\s*noglob\s+", "", value)
        if is_global:
            skipped.append((name, "global alias"))
            continue
        if value is None or not value.strip():
            skipped.append((name, "unparsable"))
            continue
        if name in builtins:
            skipped.append((name, "would shadow a nushell command"))
            continue
        try:
            words = shlex.split(value)
        except ValueError:
            words = []
        refs = set(re.findall(r"[\w:.-]+", value))
        internal = (refs & functions) | {r for r in refs if r.startswith(("omz_", "_omz", "git_current_branch", "git_main_branch", "git_develop_branch"))}
        if words and words[0] in names and words[0] != name:
            internal.add(words[0])
        internal |= {"$" + v for v in re.findall(r"\$\{?([A-Za-z_]\w*)", value or "") if v in assigned}
        if internal:
            skipped.append((name, "uses " + ", ".join(sorted(internal))))
            continue
        seen.add(name)
        if words:
            head = words[1] if words[0] in ("sudo", "noglob", "command") and len(words) > 1 else words[0]
            firsts[head] += 1
        export_name = "main" if name == plugin else nu_name(name)
        if words and not SHELL_SYNTAX.search(value) and not ZSH_ONLY.search(value):
            quoted = [nu_quote(w) for w in words]
            # Oh My Zsh means the external program, not nushell's `ps`, `du`...
            if words[0] in builtins or export_name == "main":
                quoted[0] = "^" + quoted[0]
            if export_name == "main":
                # nushell can't export an alias named main: use a wrapper command
                out.append(f"export def --wrapped main [...rest] {{ {' '.join(quoted)} ...$rest }}")
            else:
                out.append(f"export alias {export_name} = {' '.join(quoted)}")
        else:
            shell = "zsh" if ZSH_ONLY.search(value) else "bash"
            doc = " ".join(value.split())
            if len(doc) > 100:
                doc = doc[:99] + "…"
            out.append(
                f"# {doc}\n"
                f"export def --wrapped {export_name} [...rest] {{ ^{shell} -c r#'{value} \"$@\"'# {nu_quote(name)} ...$rest }}"
            )
    if not out:
        return None, skipped, functions
    requires = firsts.most_common(1)[0][0] if firsts else ""
    if not re.match(r"^[A-Za-z0-9_.+-]+$", requires) or requires in ("bash", "sh", "cd", "echo", "env", "sudo"):
        requires = ""
    requires = REQUIRES.get(plugin, requires)
    desc = first_paragraph(os.path.join(src_dir, "README.md"))
    if not desc or re.match(r"(?i)^(this|the|a)\s+plugin|^(adds?|enables?|provides?|plugin)\b", desc):
        desc = f"Oh My Zsh's {plugin} aliases"
    else:
        desc = f"{desc} (Oh My Zsh's {plugin} aliases)"
    header = [
        f"# description: {desc}",
        f"# requires: {requires}",
        f"# generated by tools/port-omz.py from Oh My Zsh's plugins/{plugin}",
    ]
    if skipped:
        header.append("# not ported: " + "; ".join(f"{n} ({why})" for n, why in skipped))
    if functions:
        header.append("# Oh My Zsh functions not ported: " + ", ".join(sorted(functions)))
    return "\n".join(header) + "\n\n" + "\n".join(out) + "\n", skipped, functions


def main():
    omz_dir, plugins = sys.argv[1], sys.argv[2:]
    builtins = nu_builtins()
    for plugin in plugins:
        target = os.path.join(PLUGINS, plugin + ".nu")
        if os.path.exists(target) and "generated by tools/port-omz.py" not in open(target).read():
            print(f"{plugin}\tkept\tindividually written plugin exists")
            continue
        text, skipped, functions = port(omz_dir, plugin, builtins)
        if text is None:
            if os.path.exists(target):
                os.remove(target)  # a stale generated file
            print(f"{plugin}\tnone\t{len(skipped)} skipped, {len(functions)} functions")
            continue
        open(target, "w").write(text)
        n = text.count("\nexport ")
        print(f"{plugin}\tported\t{n} ported, {len(skipped)} skipped, {len(functions)} functions")


if __name__ == "__main__":
    main()
