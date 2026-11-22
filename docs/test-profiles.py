#!/usr/bin/env python3
"""Render all profiles without applying; validate target selection and shell syntax."""
import io
import json
from pathlib import Path
import subprocess
import tarfile

SOURCE = Path(__file__).resolve().parents[1]
manifest = json.loads((SOURCE / 'docs/profile-manifest.json').read_text())
for profile, os_name in [('mac', 'darwin'), ('ubuntu26', 'linux'), ('x220', 'linux')]:
    override = json.dumps({'profile': profile, 'chezmoi': {'os': os_name, 'homeDir': '/tmp/profile-home'}})
    payload = subprocess.check_output(['chezmoi', '--source', str(SOURCE), '--override-data', override,
                                       'archive', '--format', 'tar'])
    with tarfile.open(fileobj=io.BytesIO(payload)) as archive:
        files = {m.name.removeprefix('./'): (m, archive.extractfile(m).read())
                 for m in archive.getmembers() if m.isfile()}
    expected = {p for p, profiles in manifest['files'].items() if profile in profiles}
    assert files.keys() == expected, (profile, files.keys() - expected, expected - files.keys())
    for name, (member, content) in files.items():
        text = content.decode()
        assert '/home/n/' not in text and '/home/nsc/' not in text and '/Users/nsc/' not in text, name
        assert '.dotfiles/' not in text, (profile, name)
        if name.startswith('.local/bin/'):
            assert member.mode & 0o111, name
        if name in ('.zshenv', '.zprofile', '.config/zsh/.zprofile', '.config/zsh/.zshrc', '.config/shell/profile'):
            subprocess.run(['zsh', '-n'], input=content, check=True)
        if profile != 'mac' and name == '.config/ghostty/config':
            assert 'macos-' not in text and 'cmd+' not in text
        if profile != 'mac' and name == '.config/yazi/yazi.toml':
            assert 'open -a' not in text
    print(f'{profile}: {len(files)} files; selection, home paths, permissions and shell syntax OK')
