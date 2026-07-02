"""
Shared YAML frontmatter parser for chain scripts.
Import from validate-chain.sh and generate-rtm.sh via PYTHONPATH.

Can also run standalone: python3 _yaml_parser.py <filepath>
"""
import re
import sys

# ── Public API ──

def sanitize_yaml(text):
    """Quote values containing YAML-breaking inline code patterns (TS, JSON, pipes).
    Degrade gracefully — best-effort, never raise."""
    try:
        return _sanitize_yaml(text)
    except Exception:
        return text


def parse_frontmatter(filepath):
    """Extract YAML frontmatter from markdown file. Returns dict or None."""
    try:
        with open(filepath) as f:
            content = f.read()
    except (FileNotFoundError, OSError):
        return None

    m = re.match(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
    if not m:
        return None

    import yaml
    text = m.group(1)

    # Path 1: direct parse
    try:
        result = yaml.safe_load(text) or {}
        if isinstance(result, dict):
            return result
    except Exception:
        pass

    # Path 2: sanitize YAML-breaking inline code and retry
    try:
        result = yaml.safe_load(sanitize_yaml(text)) or {}
        if isinstance(result, dict):
            return result
    except Exception:
        pass

    # Path 3: last resort — regex-extract minimal fields
    result = {}
    m = re.search(r'agent:\s*(\d+)', text)
    if m:
        result['agent'] = int(m.group(1))
    m = re.search(r'status:\s*(\w+)', text)
    if m:
        result['status'] = m.group(1)
    return result


def split_refs(value):
    """Split comma-separated reference string into individual refs.
    Handles: 'BR-004, BR-016' → ['BR-004', 'BR-016']"""
    if not value:
        return []
    return [r.strip() for r in str(value).split(',') if r.strip()]


def expand_range(source, prefix):
    """Expand range notation like 'US-001..US-011' into individual IDs.
    Returns (source, [expanded_ids]) tuple."""
    pattern = re.compile(rf'{re.escape(prefix)}(\d+)\.\.{re.escape(prefix)}(\d+)')
    m = pattern.search(source)
    if m:
        start, end = int(m.group(1)), int(m.group(2))
        width = len(m.group(1))
        return [f'{prefix}{i:0{width}d}' for i in range(start, end + 1)]
    return []


# ── Internal ──

def _sanitize_yaml(text):
    """Quote values containing YAML-breaking inline code patterns."""
    lines = text.split('\n')
    out = []
    for line in lines:
        stripped = line.lstrip()
        if not stripped or stripped.startswith('#'):
            out.append(line)
            continue
        m = re.match(r'^(\s*)([\w_-]+):\s*(.*)', line)
        if not m:
            # Try list item: "- text" (but NOT "- key: value" which is valid YAML)
            lm = re.match(r'^(\s+)-\s+(.*)', line)
            if lm:
                indent, value = lm.group(1), lm.group(2)
                if re.match(r'^[\w_-]+:', value):
                    out.append(line)
                elif (not value or value.startswith('"') or value.startswith("'") or
                      value in ('null', 'true', 'false')):
                    out.append(line)
                elif _needs_quote(value):
                    out.append(f'{indent}- "{_safe(value)}"')
                else:
                    out.append(line)
            else:
                out.append(line)
            continue
        indent, key, value = m.group(1), m.group(2), m.group(3)
        if not value or value.startswith('"') or value.startswith("'"):
            out.append(line)
            continue
        if value in ('>', '|', 'null', '[]', '{}', 'true', 'false'):
            out.append(line)
            continue
        if _needs_quote(value):
            out.append(f'{indent}{key}: "{_safe(value)}"')
        else:
            out.append(line)
    return '\n'.join(out)


def _needs_quote(value):
    """True if value contains YAML-breaking characters."""
    if re.search(r'[\{\}\[\]]', value):
        return True
    if '|' in value:
        return True
    if ': ' in value and not value.startswith('http'):
        return True
    return False


def _safe(value):
    """Escape backslashes and quotes for YAML double-quoted strings."""
    return value.replace('\\', '\\\\').replace('"', '\\"')


def atomic_update_json(filepath, updater, conflict_fn=None):
    """Atomically read-update-write a JSON file with CAS (Compare-And-Swap).
    - filepath: path to JSON file
    - updater(data) → data_update: function that modifies the data dict (returns modified dict)
    - conflict_fn(old_ts, current_ts): called if concurrent write detected (can re-apply updater)
    Returns the final data dict.

    Uses tmp-file + os.replace() for atomicity. Checks updatedAt to detect concurrent writes.
    If file doesn't exist, updater receives empty dict."""
    import json as _json
    import os as _os
    from datetime import datetime, timezone as _timezone

    data = {}
    original_ts = None

    if _os.path.exists(filepath):
        with open(filepath) as f:
            try:
                data = _json.load(f)
            except _json.JSONDecodeError:
                data = {}
        original_ts = data.get('updatedAt')

    # Apply update
    data = updater(data)

    # Re-read to check for concurrent modification
    if _os.path.exists(filepath):
        with open(filepath) as f:
            try:
                current = _json.load(f)
            except _json.JSONDecodeError:
                current = {}
        current_ts = current.get('updatedAt')
        if original_ts and current_ts and original_ts != current_ts:
            # Conflict detected — merge, then re-apply
            if conflict_fn:
                conflict_fn(original_ts, current_ts)
            data = updater(current)

    # Write atomically
    data['updatedAt'] = datetime.now(_timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    tmp = filepath + '.tmp'
    with open(tmp, 'w') as f:
        _json.dump(data, f, indent=2)
    _os.replace(tmp, filepath)
    return data


# ── CLI ──

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f"Usage: python3 {sys.argv[0]} <filepath>", file=sys.stderr)
        sys.exit(1)

    import yaml
    fm = parse_frontmatter(sys.argv[1])
    if fm is None:
        print("FAILED to parse")
        sys.exit(1)

    print(f"agent={fm.get('agent', '?')} status={fm.get('status', '?')}")
    keys = [k for k in fm if not k.startswith('_')]
    for k in sorted(keys):
        v = fm[k]
        if isinstance(v, list):
            print(f"  {k}: list[{len(v)}]")
        elif isinstance(v, str) and len(v) > 80:
            print(f"  {k}: str[{len(v)}]")
        else:
            print(f"  {k}: {v}")
