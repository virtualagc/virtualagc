# SDF Member JSON Specification Format

This document describes the JSON schema accepted by `demo_sdfpkg.py --json FILE`.

The JSON file describes a single SDF member: its blocks (program units), the
symbols (variables and type templates) declared in each block, and the
executable statements inside each block.  `demo_sdfpkg.py` reads the file,
calls the `SdfWriter` API to create the member, then reads it back and prints
a summary.

---

## Top-Level Keys

```json
{
  "member":  "NAVCOMP",
  "flags":   ["HAS_SRNS"],
  "blocks":  [ ... ]
}
```

| Key       | Type            | Default          | Description |
|-----------|-----------------|------------------|-------------|
| `member`  | string (≤ 8 ch) | `"MEMBER1"`      | SDF member name.  Overridden by the CLI member argument. |
| `flags`   | array of string | `["HAS_SRNS"]`   | Write flags.  See [Write Flags](#write-flags). |
| `blocks`  | array of object | `[]`             | Block (program unit) descriptors. |

### Write Flags

| Flag name   | Meaning |
|-------------|---------|
| `"HAS_SRNS"` | Member contains Statement Reference Numbers (SRNs); required if you supply `"statements"`. |
| `"NONMONO"` | SRNs are not monotonically ordered (rarely needed). |

---

## Block Descriptor

Each entry in `"blocks"` describes one HAL/S program unit.

```json
{
  "id":         "main",
  "blk_name":   "NAVCOMP",
  "csect_name": "NAVSECT",
  "blk_class":  "PROGRAM",
  "blk_id":     1,
  "symbols":    [ ... ],
  "statements": [ ... ]
}
```

| Key          | Type   | Default     | Description |
|--------------|--------|-------------|-------------|
| `id`         | string | *(blk_name)* | Local identifier used for cross-referencing within the JSON (e.g., `"copy_block"`).  Need not match the HAL/S name. |
| `blk_name`   | string | `""`        | HAL/S block name, up to 8 characters (first 8 are stored; long names are stored in the symbol's name-continuation field). |
| `csect_name` | string | `""`        | Object-code CSECT name, up to 8 characters. |
| `blk_class`  | string | `"PROGRAM"` | Block class.  See [Block Classes](#block-classes). |
| `blk_id`     | int    | `1`         | Block stack identifier (compiler bookkeeping). |
| `blk_type`   | int    | `0`         | Block sub-type (compiler bookkeeping; usually 0). |
| `blk_flags`  | int    | `0`         | Additional block flags (raw value; usually 0). |
| `symbols`    | array  | `[]`        | Symbol descriptors.  See [Symbol Descriptor](#symbol-descriptor). |
| `statements` | array  | `[]`        | Statement descriptors.  See [Statement Descriptor](#statement-descriptor). |

### Block Classes

| `blk_class` string | HAL/S construct | Notes |
|--------------------|-----------------|-------|
| `"PROGRAM"`        | `PROGRAM` block | Main entry point |
| `"FUNCTION"`       | `FUNCTION` block | Returns a value |
| `"PROCEDURE"`      | `PROCEDURE` block (or STRUCTURE template) | Use for STRUCTURE templates |
| `"TASK"`           | `TASK` block | Parallel task |
| `"COMPOOL"`        | `COMPOOL` block | Shared data pool |
| `"CLOSE"`          | Close block | Compiler-internal close scope |

**STRUCTURE templates** always use `"blk_class": "PROCEDURE"`.  The template
header symbol inside the block (class `"TEMPLATE"`, type `"STRUCTURE"`) marks
the block as a STRUCTURE template to the compiler.

---

## Symbol Descriptor

Each entry in `"symbols"` describes one HAL/S symbol declared in the block.

```json
{
  "name":         "ALTITUDE",
  "class":        "VARIABLE",
  "type":         "SCALAR",
  "rows":         0,
  "columns":      0,
  "array":        null,
  "copy_block":   null,
  "flag1":        0,
  "flag2":        0,
  "flag3":        0,
  "flag4":        0,
  "rel_addr":     0,
  "lock_num":     0,
  "byte_size":    0
}
```

| Key          | Type           | Default      | Description |
|--------------|----------------|--------------|-------------|
| `name`       | string (≤ 32 ch)| `""`       | Symbol name.  Characters 1–8 are the short key; 9–32 are stored in the name-continuation field of the SDC. |
| `class`      | string         | `"VARIABLE"` | Symbol class.  See [Symbol Classes](#symbol-classes). |
| `type`       | string         | `"SCALAR"`   | Symbol type.  See [Symbol Types](#symbol-types). |
| `rows`       | int            | `0`          | Row count (VECTOR length; MATRIX rows; BIT width). |
| `columns`    | int            | `0`          | Column count (MATRIX columns; CHARACTER max length). |
| `array`      | array or null  | `null`       | Array dimensions.  See [ARRAY Variables](#array-variables). |
| `copy_block` | string or null | `null`       | For STRUCTURE COPY templates: the `id` of the block being copied. See [STRUCTURE Templates and COPY](#structure-templates-and-copy). |
| `flag1`–`flag4` | int       | `0`          | Raw compiler flag bytes (usually 0). |
| `rel_addr`   | int            | `0`          | Relative address (compiler bookkeeping). |
| `lock_num`   | int            | `0`          | Lock number (compiler bookkeeping). |
| `byte_size`  | int            | `0`          | Byte size of the symbol (compiler bookkeeping). |

### Symbol Classes

| `class` string  | Numeric | Meaning |
|-----------------|---------|---------|
| `"VARIABLE"`    | 1       | Ordinary variable (most common). |
| `"EQUATE_EXT"`  | 2       | External equate reference (compiler-internal COMPOOL cross-reference). |
| `"TEMPLATE"`    | 3       | STRUCTURE template header.  Must have `"type": "STRUCTURE"`. |
| `"LABEL"`       | 4       | HAL/S `NAME` variable: a pointer to another typed object.  `"type"` gives the type of the referent. |
| `"COMPOOL"`     | 6       | COMPOOL symbol reference. |

### Symbol Types

#### `"SCALAR"` — single floating-point number

```json
{ "name": "ALTITUDE", "type": "SCALAR" }
```

#### `"INTEGER"` — single integer

```json
{ "name": "COUNT", "type": "INTEGER" }
```

#### `"BOOLEAN"` — TRUE / FALSE

```json
{ "name": "ARMED", "type": "BOOLEAN" }
```

#### `"CHARACTER"` — variable-length character string

`"columns"` gives the maximum length (0 = unspecified).

```json
{ "name": "MESSAGE",  "type": "CHARACTER", "columns": 80 }
{ "name": "SHORT_ID", "type": "CHARACTER", "columns": 8  }
```

#### `"BIT"` — bit string

`"rows"` gives the bit-string width (0 = unspecified).

```json
{ "name": "MODE_BITS", "type": "BIT", "rows": 8  }
{ "name": "FLAGS",     "type": "BIT", "rows": 16 }
```

#### `"VECTOR"` — real-valued vector

`"rows"` gives the number of components (0 = unspecified).

```json
{ "name": "VELOCITY", "type": "VECTOR", "rows": 3 }
{ "name": "POSITION", "type": "VECTOR", "rows": 3 }
```

#### `"MATRIX"` — real-valued matrix

`"rows"` × `"columns"`.  Both 0 means unspecified.

```json
{ "name": "INERTIA",    "type": "MATRIX", "rows": 3, "columns": 3 }
{ "name": "TRANSFORM",  "type": "MATRIX", "rows": 4, "columns": 4 }
```

#### `"EVENT"` — HAL/S event semaphore

```json
{ "name": "LAUNCH_ENABLE", "type": "EVENT" }
```

#### `"TASK"` — task entry-point symbol

Used for the entry-point symbol of a `TASK` block.  The symbol name must
match the block name, and the block must have `"blk_class": "TASK"`.

```json
{
  "id":       "burn_task",
  "blk_name": "BURN_TASK",
  "blk_class":"TASK",
  "symbols": [
    { "name": "BURN_TASK",    "type": "TASK"    },
    { "name": "THRUST_LEVEL", "type": "SCALAR"  }
  ]
}
```

#### `"STRUCTURE"` — STRUCTURE instance variable

An instance of a STRUCTURE type.  The `"rows"` field should hold the symbol
number (`symb_no`) of the template header symbol.  Because symbol numbers are
assigned at commit time (after sorting), they are not known at JSON-write time;
use `"rows": 0` as a placeholder.  The full compiler (PASS3) fills this in.

```json
{ "name": "SENSOR", "type": "STRUCTURE", "rows": 0 }
```

#### `"EQUATE_EXT"` — external equate reference

Always paired with `"class": "EQUATE_EXT"`.

```json
{ "name": "EXT_CONST", "class": "EQUATE_EXT", "type": "EQUATE_EXT" }
```

If `"class"` is `"EQUATE_EXT"`, the `"type"` field defaults to
`"EQUATE_EXT"` and may be omitted.

---

### ARRAY Variables

Any symbol type may be an array.  Use the `"array"` key to specify dimensions
(1, 2, or 3 integers):

```json
{ "name": "READINGS", "type": "SCALAR",  "array": [10]    }
{ "name": "TABLE",    "type": "INTEGER", "array": [3, 4]  }
{ "name": "CUBE",     "type": "SCALAR",  "array": [2,3,4] }
```

Arrays of `VECTOR`, `MATRIX`, etc. work the same way:

```json
{ "name": "VEC_ARR", "type": "VECTOR", "rows": 3, "array": [5] }
```

Omit `"array"` (or set it to `null`) for non-array scalars.

---

### NAME Variables (LABEL class)

HAL/S `DECLARE X NAME;` creates a typed pointer.  Use `"class": "LABEL"` and
set `"type"` to the type of the object being pointed at:

```json
{ "name": "ALT_PTR",  "class": "LABEL", "type": "SCALAR"    }
{ "name": "VEC_NAME", "class": "LABEL", "type": "VECTOR"    }
{ "name": "CHAR_REF", "class": "LABEL", "type": "CHARACTER" }
```

---

## STRUCTURE Templates and COPY

A STRUCTURE template is a `PROCEDURE`-class block whose first symbol is a
`TEMPLATE`/`STRUCTURE` header symbol.  Subsequent symbols are the structure
members (fields).

### Base template (no COPY)

```json
{
  "id":       "sensor_tmpl",
  "blk_name": "SENSOR_DATA",
  "blk_class":"PROCEDURE",
  "blk_id":   2,
  "symbols": [
    { "name": "SENSOR_DATA", "class": "TEMPLATE", "type": "STRUCTURE" },
    { "name": "ALT_READING", "type": "SCALAR"  },
    { "name": "STATUS_CODE", "type": "INTEGER" },
    { "name": "VEL_READING", "type": "VECTOR", "rows": 3 }
  ]
}
```

The template header symbol (`"class": "TEMPLATE"`) must be the first symbol
in the block and must have the same name as the block.

### Derived template (COPY)

A template that inherits another template's members uses `"copy_block"` on its
header symbol, referencing the source template's `"id"`:

```json
{
  "id":       "ext_sensor_tmpl",
  "blk_name": "EXT_SENSOR",
  "blk_class":"PROCEDURE",
  "blk_id":   3,
  "symbols": [
    {
      "name":        "EXT_SENSOR",
      "class":       "TEMPLATE",
      "type":        "STRUCTURE",
      "copy_block":  "sensor_tmpl"
    },
    { "name": "RANGE_KM", "type": "SCALAR" }
  ]
}
```

`"copy_block"` must be the `"id"` of another block **defined earlier** in the
same `"blocks"` array (so its block number is already known when the symbol is
added).

The SDF stores this as a STRCDATA block appended to the template header's SDC;
the `copy_blk_no` field in the SDC's `struct_of` byte points to it.

---

## Statement Descriptor

Statements are associated with a specific block.  Add them under the block's
`"statements"` array.

```json
{
  "srn":    "S0001",
  "type":   "ASSIGN",
  "exec":   true,
  "lhs":    1,
  "labels": 0
}
```

| Key      | Type   | Default     | Description |
|----------|--------|-------------|-------------|
| `srn`    | string | `""`        | Statement Reference Number: up to 6 ASCII characters, stored space-padded to 6 bytes.  Required when the member flag `"HAS_SRNS"` is set. |
| `type`   | string | `"ASSIGN"`  | Statement type.  See [Statement Types](#statement-types). |
| `exec`   | bool   | `true`      | Whether this statement is executable.  Non-executable statements (`false`) are stored without a data cell (only a node cell). |
| `lhs`    | int    | `0`         | Number of left-hand-side references (for assignment statements). |
| `labels` | int    | `0`         | Number of labels on this statement. |

### Statement Types

| `type` string | HAL/S construct |
|---------------|-----------------|
| `"ASSIGN"`    | Assignment statement (`X = ...`) |
| `"IF"`        | `IF` statement |
| `"DO"`        | `DO` group |
| `"DO_WHILE"`  | `DO WHILE ...` |
| `"DO_UNTIL"`  | `DO UNTIL ...` |
| `"DO_FOR"`    | `DO FOR ...` |
| `"END"`       | `END` statement |
| `"RETURN"`    | `RETURN` statement |
| `"CALL"`      | `CALL` statement |
| `"GOTO"`      | `GO TO` statement |
| `"ON_ERROR"`  | `ON ERROR` statement |

---

## Cross-Reference Rules

- Block `"id"` values are scoped to a single JSON file.  They are used only
  in `"copy_block"` references and have no effect on the SDF file itself.
- A `"copy_block"` reference must point to a block **that appears earlier** in
  the `"blocks"` array, because block numbers are assigned in order.
- Blocks are sorted by name at commit time, so the order of `"blocks"` in the
  JSON affects block numbers but not the final sorted order in the SDF index.

---

## Complete Example

The following JSON reproduces the built-in NAVCOMP example that `demo_sdfpkg.py`
uses by default (minus the suffix feature):

```json
{
  "member": "NAVCOMP",
  "flags":  ["HAS_SRNS"],
  "blocks": [
    {
      "id":         "main",
      "blk_name":   "NAVCOMP",
      "csect_name": "NAVSECT",
      "blk_class":  "PROGRAM",
      "blk_id":     1,
      "symbols": [
        { "name": "ALTITUDE",       "type": "SCALAR"                           },
        { "name": "ALT_PTR",        "class": "LABEL",       "type": "SCALAR"   },
        { "name": "ARMED",          "type": "BOOLEAN"                          },
        { "name": "BITS",           "type": "BIT",          "rows": 16         },
        { "name": "COUNT",          "type": "INTEGER"                          },
        { "name": "EXT_CONST",      "class": "EQUATE_EXT"                      },
        { "name": "INERTIA",        "type": "MATRIX",       "rows": 3, "columns": 3 },
        { "name": "LAUNCH_ENABLE",  "type": "EVENT"                            },
        { "name": "LONGSYMBOLNAME", "type": "SCALAR"                           },
        { "name": "MESSAGE",        "type": "CHARACTER",    "columns": 20      },
        { "name": "READINGS",       "type": "SCALAR",       "array": [10]      },
        { "name": "SENSOR",         "type": "STRUCTURE",    "rows": 0          },
        { "name": "TABLE",          "type": "INTEGER",      "array": [3, 4]    },
        { "name": "VELOCITY",       "type": "VECTOR",       "rows": 3          }
      ],
      "statements": [
        { "srn": "S0001", "type": "ASSIGN", "exec": true,  "lhs": 1, "labels": 0 },
        { "srn": "S0002", "type": "ASSIGN", "exec": true,  "lhs": 1, "labels": 1 },
        { "srn": "S0003", "type": "IF",     "exec": true,  "lhs": 0, "labels": 0 },
        { "srn": "S0004", "type": "ASSIGN", "exec": false, "lhs": 0, "labels": 0 }
      ]
    },
    {
      "id":         "sensor_tmpl",
      "blk_name":   "SENSOR_DATA",
      "csect_name": "STRCSECT",
      "blk_class":  "PROCEDURE",
      "blk_id":     2,
      "symbols": [
        { "name": "SENSOR_DATA", "class": "TEMPLATE", "type": "STRUCTURE" },
        { "name": "ALT_READING", "type": "SCALAR"  },
        { "name": "STATUS_CODE", "type": "INTEGER" },
        { "name": "VEL_READING", "type": "VECTOR", "rows": 3 }
      ]
    },
    {
      "id":         "ext_sensor_tmpl",
      "blk_name":   "EXT_SENSOR",
      "csect_name": "STRCSECT",
      "blk_class":  "PROCEDURE",
      "blk_id":     3,
      "symbols": [
        {
          "name":       "EXT_SENSOR",
          "class":      "TEMPLATE",
          "type":       "STRUCTURE",
          "copy_block": "sensor_tmpl"
        },
        { "name": "RANGE_KM", "type": "SCALAR" }
      ]
    },
    {
      "id":         "burn_task",
      "blk_name":   "BURN_TASK",
      "csect_name": "NAVSECT",
      "blk_class":  "TASK",
      "blk_id":     4,
      "symbols": [
        { "name": "BURN_TASK",    "type": "TASK"   },
        { "name": "THRUST_LEVEL", "type": "SCALAR" }
      ]
    }
  ]
}
```

---

## Minimal Example

A single PROGRAM block with two variables and one statement:

```json
{
  "member": "SIMPLE",
  "blocks": [
    {
      "blk_name":   "SIMPLE",
      "csect_name": "SIMPCS",
      "blk_class":  "PROGRAM",
      "symbols": [
        { "name": "X", "type": "SCALAR"  },
        { "name": "N", "type": "INTEGER" }
      ],
      "statements": [
        { "srn": "S0001", "type": "ASSIGN", "exec": true, "lhs": 1 }
      ]
    }
  ]
}
```

Run it with:

```
./demo_sdfpkg.py --json simple.json --add-member output.sdf
```
