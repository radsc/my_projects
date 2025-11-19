import re
import db as db

SELECT_ONLY_RE = re.compile(r'^\s*SELECT\b', re.IGNORECASE)
FORBIDDEN_RE = re.compile(r'\b(INSERT|UPDATE|DELETE|DROP|ALTER|TRUNCATE|GRANT|REVOKE|CREATE|REPLACE)\b', re.IGNORECASE)

def is_safe_sql(sql: str, allowed_tables) -> bool:
    if not SELECT_ONLY_RE.match(sql):
        return False
    if FORBIDDEN_RE.search(sql):
        return False
    if sql.strip().count(';') > 1:
        return False
    if not uses_allowed_tables(sql, allowed_tables):
        return False
    return True

def uses_allowed_tables(sql: str, allowed_tables) -> bool:
    """Ensure only known tables appear in query."""
    pattern = re.compile(r'\bFROM\s+(\w+)|\bJOIN\s+(\w+)', re.IGNORECASE)
    matches = pattern.findall(sql)
    used_tables = {tbl.lower() for m in matches for tbl in m if tbl}
    return used_tables.issubset(allowed_tables)

# def enforce_limit(sql: str, default_limit=10):
#     """Add LIMIT if missing."""
#     if re.search(r'\bLIMIT\b', sql, re.IGNORECASE):
#         return sql
#     return f"{sql.rstrip(';')} LIMIT {default_limit};"
