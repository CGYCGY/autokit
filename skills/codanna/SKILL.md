---
name: codanna
description: Semantic code search, symbol lookup, call graphs, and impact analysis via codanna CLI. Use before grep for finding functions, tracing callers, or checking refactoring impact.
user-invocable: false
allowed-tools: Bash
---

# Codanna CLI

If `codanna` is not installed, see `${CLAUDE_SKILL_DIR}/install.md`.
Before running any command, check if `.codanna/` exists. If not, see `${CLAUDE_SKILL_DIR}/setup.md`.

Prefer codanna over grep/find for code search. All commands run via bash. Add `--json` for structured output.

## Commands

```
codanna mcp semantic_search_docs query:"<natural language>" limit:<N>
```
Find code by meaning. Returns symbol + file + doc.

```
codanna mcp semantic_search_with_context query:"<natural language>" limit:<N>
```
Same but includes surrounding source. Add `lang:<language>` to filter by language.

```
codanna mcp find_symbol <name>
```
Exact symbol lookup. Returns definition + symbol_id.

```
codanna mcp find_symbol symbol_id:<N>
```
Lookup by id from previous results (unambiguous).

```
codanna mcp search_symbols query:<pattern> kind:<kind> limit:<N>
```
Search by name pattern + kind filter.

```
codanna mcp find_callers symbol_id:<N>
```
Who calls this function? (reverse call graph)

```
codanna mcp get_calls symbol_id:<N>
```
What does this function call? (forward call graph)

```
codanna mcp analyze_impact <SymbolName>
```
Blast radius: deps, callers, coupling score.

```
codanna mcp search_documents query:"<text>" limit:<N>
```
Search indexed markdown/docs.

```
codanna mcp get_index_info
```
Index stats: files, symbols, staleness.

## Kind Values

function, method, class, struct, trait, enum, interface, type, const, module
