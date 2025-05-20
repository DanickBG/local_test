import json
import os
import sys
import unicodedata
import glob
#To do: Add a way to handle the "libraryPanels" as dictionary - there is a problem with the type of panels when they are libraryPanels

# --- mapping for grafonnet.panel.stat --- #
STAT_OPTION_MAP = {
    # options.*
    "colorMode":               ("options", "withColorMode"),
    "graphMode":               ("options", "withGraphMode"),
    "justifyMode":             ("options", "withJustifyMode"),
    "orientation":             ("options", "withOrientation"),
    # "percentChangeColorMode":  ("options", "withPercentChangeColorMode"),
    "showPercentChange":       ("options", "withShowPercentChange"),
    "textMode":                ("options", "withTextMode"),
    "wideLayout":              ("options", "withWideLayout"),

    # options.reduceOptions.*
    "calcs":      ("options.reduceOptions", "withCalcs"),
    "fields":     ("options.reduceOptions", "withFields"),
    "limit":      ("options.reduceOptions", "withLimit"),
    "values":     ("options.reduceOptions", "withValues"),

    # options.text.*
    "titleSize":  ("options.text", "withTitleSize"),
    "valueSize":  ("options.text", "withValueSize"),

    # panelOptions.*
    "description":    ("panelOptions", "withDescription"),
    "transparent":    ("panelOptions", "withTransparent"),
    "title":          ("panelOptions", "withTitle"),
    # gridPos is handled separately
}
# --- mapping for grafonnet.panel.text --- #
TEXT_OPTION_MAP = {
    # options.*
    "mode":     ("options", "withMode"),        # markdown / html / code
    "content":  ("options", "withContent"),
    "code":     ("options", "withCode"),        # handled separately
}

TEXT_CODE_OPTION_MAP = {
    "language":         ("options.code", "withLanguage"),
    "showLineNumbers":  ("options.code", "withShowLineNumbers"),
    "showMiniMap":      ("options.code", "withShowMiniMap"),
}

# --- mapping for grafonnet.panel.table --- #
TABLE_OPTION_MAP = {
    # options.*
    "cellHeight":     ("options", "withCellHeight"),
    "frameIndex":     ("options", "withFrameIndex"),
    "showHeader":     ("options", "withShowHeader"),
    "showTypeIcons":  ("options", "withShowTypeIcons"),
    "sortBy":         ("options", "withSortBy"),
    "footer":         ("options", "withFooter"),   # nested map below
}

TABLE_FOOTER_OPTION_MAP = {
    "show":             ("options.footer", "withShow"),
    "countRows":        ("options.footer", "withCountRows"),
    "enablePagination": ("options.footer", "withEnablePagination"),
    "fields":           ("options.footer", "withFields"),
    "reducer":          ("options.footer", "withReducer"),
}

# ----------------  MATCHER constructors  ----------------
# key: matcher.id      value: Grafonnet constructor path
MATCHER_PATH = {
    "byName":   "fieldOverride.byName",
    "byRegex":  "fieldOverride.byRegex",
    "byFields": "fieldOverride.byFields",
    "byQuery":  "fieldOverride.byQuery",
}

# ----------------  Property → withProperty names  --------
# Pass-through by default; extend here only if Grafonnet
# method names differ from JSON IDs.
PROPERTY_ALIAS = {
    # JSON id : Grafonnet method property name
    # (keep it empty if they’re identical)
    # e.g. "unit": "unit",  "decimals": "decimals"
}

# panel-root keys every panel can reuse
PANEL_COMMON_MAP = {
    "description": ("panelOptions", "withDescription"),
    "transparent": ("panelOptions", "withTransparent"),
    "title":       ("panelOptions", "withTitle"),
}

def emit_setter(panel_type, path, method, value, indent="  "):

    """
    Print one Grafonnet setter.
    `path` can be nested like 'options.reduceOptions'.
    """
    # Convert the JSON value to Jsonnet literal
    jv = to_jsonnet(value)
    print(f"{indent}+ g.panel.{panel_type}.{path}.{method}({jv})")
    

def escape_query(query):
    if isinstance(query, dict):
        query = json.dumps(query, ensure_ascii=False)
    query = (
        query.replace("`", "\"")
        .replace("\n", " ")
        .replace("\r", " ")
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
    )
    return unicodedata.normalize("NFKD", query)

def normalize_unicode(s):
    if isinstance(s, str):
        return unicodedata.normalize("NFKD", s)
    return s

def to_jsonnet(obj, indent=0):
    IND = "  "
    if isinstance(obj, dict):
        lines = ["{"]
        for k, v in obj.items():
            key = json.dumps(normalize_unicode(k))
            lines.append(f"{IND * (indent + 1)}{key}: {to_jsonnet(v, indent + 1)},")
        lines.append(f"{IND * indent}}}")
        return "\n".join(lines)

    elif isinstance(obj, list):
        lines = ["["]
        for item in obj:
            lines.append(f"{IND * (indent + 1)}{to_jsonnet(item, indent + 1)},")
        lines.append(f"{IND * indent}]")
        return "\n".join(lines)
    elif isinstance(obj, str):
        s = normalize_unicode(obj.strip())
        return json.dumps(s)
    elif isinstance(obj, bool):
        return "true" if obj else "false"
    elif obj is None:
        return "null"
    else:
        return str(obj)

def emit_overrides(panel_type: str, overrides: list[dict], indent="  "):
    """
    Print Grafonnet withOverrides([...]) for the given overrides list.
    """
    if not overrides:
        return

    print(f'{indent}+ g.panel.{panel_type}.standardOptions.withOverrides([')
    IND2 = indent + "    "

    for idx, ov in enumerate(overrides):
        matcher = ov.get("matcher", {})
        m_id    = matcher.get("id", "byName")
        m_opt   = matcher.get("options", "")

        path = MATCHER_PATH.get(m_id, "fieldOverride.byName")      # fallback

        # constructor line
        print(f'{IND2}g.panel.{panel_type}.{path}.new({to_jsonnet(m_opt)})')

        # properties
        for prop in ov.get("properties", []):
            pid  = prop.get("id")
            pval = prop.get("value")
            graf_prop = PROPERTY_ALIAS.get(pid, pid)
            print(
                f'{IND2}+ g.panel.{panel_type}.{path}'
                f'.withProperty("{graf_prop}", {to_jsonnet(pval)})'
            )

        # comma between overrides unless last one
        trail = "," if idx < len(overrides) - 1 else ""
        print(f'{IND2}{trail}')

    print(f'{indent}])')

def get_library_panel_type(uid, library_elements_folder):
    """
    Search for the JSON file with the given UID in the library elements folder
    and extract the type of the panel.
    """
    # Ensure the UID is treated as a string
    uid = str(uid).strip()
    search_pattern = os.path.join(library_elements_folder, f"*{uid}*.json")
    matching_files = glob.glob(search_pattern)

    if not matching_files:
        print(f"⚠️ Warning: No library element found for UID: {uid}")
        return "text"  # Default type if not found

    try:
        with open(matching_files[0], "r") as file:
            library_element = json.load(file)
            return library_element.get("type", "text")  # Default to "text" if type is missing
    except (json.JSONDecodeError, FileNotFoundError) as e:
        print(f"⚠️ Error reading library element for UID: {uid}. Error: {e}. Defaulting to 'text' panel type.")
        return "text"

def convert_grafana_json_to_grafonnet(json_file, output_file):
    with open(output_file, 'w') as f:
        sys.stdout = f  # Redirect print output to file

        with open(json_file, "r") as file:
            raw = json.load(file)
        dashboard = raw.get("dashboard", raw)   # ⬅️ fallback to raw if no wrapper

        print("local g = import 'g.libsonnet';")
        print("local var = g.dashboard.variable;")
        print("local grafana = import 'bigquery.libsonnet';")
        print("local bigquery = grafana.bigqueryPanel;")
        print("\n")

        Dashboard_var_holder = []

        def extract_variables(json_obj):
            variables = json_obj.get("templating", {}).get("list", [])
            for var in variables:
                var_name = var.get("name", "")
                var_type = var.get("type", "")
                var_query = var.get("query", "") # Assuming query is a string - we do not escape it
                var_datasource = var.get("datasource", {})
                var_datasource_type = var_datasource.get("type", "")
                var_datasource_uid = var_datasource.get("uid", "")
                var_hide = var.get("hide","")
                print(f'local {var_name} = ')
                Dashboard_var_holder.append(var_name)

                if var_type == "custom":
                    options = var.get("options", [])
                    values = [opt["value"] for opt in options]  # still required
                    query_str = ", ".join(
                        f'{opt["text"]} : {opt["value"]}'
                        for opt in options
                    )
                    if var_name == "Zeitraum" or var_name == "zeitraum":
                        with open("zeitraum.txt", "r") as file:
                            zeitraum_sql_string = file.read().strip()  # Read and strip any extra whitespace
                        print(f'var.custom.new("{var_name}", {zeitraum_sql_string})')
                        print(f'+   var.custom.withQuery({zeitraum_sql_string})')
                    else:
                        print(f'var.custom.new("{var_name}", {to_jsonnet(values, indent=2)})')
                        print(f'+   var.custom.withQuery({json.dumps(query_str)})')

                    # print(f'var.custom.new("{var_name}", {to_jsonnet(values, indent=2)})')
                    # print(f'+   var.custom.withQuery({json.dumps(query_str)})')
                else:
                    print(f'var.query.new("{var_name}")')
                    if var_datasource:
                        print(f'+   var.query.withDatasource("{var_datasource_type}", "{var_datasource_uid}")')
                    print("+   ", json.dumps({"query": var_query}, indent=4))
                
                if var_hide: 
                    if var_hide == 2:
                        print(f'  +var.{var_type}.generalOptions.showOnDashboard.withNothing()')
                    elif var_hide == 1:
                        print(f'  +var.{var_type}generalOptions.showOnDashboard.withValueOnly()')
                    elif var_hide == "false":
                        print(f'  +var.{var_type}generalOptions.showOnDashboard.withLabelAndValue()')
                
                current_var = var.get("current", {})
                if current_var:
                    print('   +{ "current": ')
                    print(json.dumps(current_var, indent=6))
                    print('}')
                    
                print(";")

        def extract_panels(json_obj):
            dashboard_title = json_obj.get("title", "Unknown Dashboard")
            print(f'g.dashboard.new("{dashboard_title}")')
            formatted_variables = ', '.join(Dashboard_var_holder)
            print(f'+ g.dashboard.withVariables([{formatted_variables}])')
            print(f'+ g.dashboard.withPanels([')

            panels = json_obj.get("panels", [])
            for panel in panels:
                panel_type = panel.get("type", "") or "unknown" # Default to "unknown" if type is not found

                if panel_type == "table-old":
                    # Skip the "table-old" panel type
                    continue

                if panel_type == "marcusolsson-dynamictext-panel":
                    print(f'g.panel.table.new("{panel_title}") // {panel_type} Panel')
                    # print("   +")
                    print("     +",json.dumps(panel, indent=6))
                    print(",")
                    continue

                library_panel = panel.get("libraryPanel")
                if library_panel:
                    library_panel_uid = library_panel.get("uid", "")
                    library_panel_type = get_library_panel_type(
                        library_panel_uid,
                        "backup/library-elements"
                    ) # Adjust the path as needed
                    library_panel_title = library_panel.get("title", "")
                    grid_pos = panel.get("gridPos", {})
                    h, w, x, y = grid_pos.get("h", "null"), grid_pos.get("w", "null"), grid_pos.get("x", "null"), grid_pos.get("y", "null")
                    print(f'g.panel.{library_panel_type}.new("{library_panel_title}") // {library_panel_type} Panel')
                    print(f'  + g.panel.{library_panel_type}.panelOptions.withGridPos(h={h}, w={w}, x={x}, y={y})')
                    print(
                        f'  + {{ libraryPanel: {to_jsonnet(library_panel, indent=2)} }}'
                    )
                    print(',')
                    continue

                panel_title = panel.get("title", "")
                grid_pos = panel.get("gridPos", {})
                h, w, x, y = grid_pos.get("h", "null"), grid_pos.get("w", "null"), grid_pos.get("x", "null"), grid_pos.get("y", "null")

                datasource = panel.get("datasource", {})
                datasource_type = datasource.get("type", "")
                datasource_uid = datasource.get("uid", "")

                print(f'g.panel.{panel_type}.new("{panel_title}") // {panel_type} Panel')
                print(f'  + g.panel.{panel_type}.panelOptions.withGridPos(h={h}, w={w}, x={x}, y={y})')
                


                fieldConfig = panel.get("fieldConfig", {}) # Added to handle fieldConfig
                if fieldConfig:
                    fieldConfig_defaults = fieldConfig.get("defaults", {})
                    if fieldConfig_defaults:
                        color = fieldConfig_defaults.get("color", {})
                        if color:
                            color_mode = color.get("mode", "")
                            fixed_color = color.get("fixedColor", "")
                            if fixed_color:
                                print(f'  + g.panel.{panel_type}.standardOptions.color.withFixedColor("{fixed_color}")')
                            if color_mode:
                                print(f'  + g.panel.{panel_type}.standardOptions.color.withMode("{color_mode}")')
                        thresholds = fieldConfig_defaults.get("thresholds", [])
                        if thresholds:
                            print('+{"thresholds":',json.dumps(thresholds, indent=4),'}')
                    overrides = fieldConfig.get("overrides", [])
                    emit_overrides(panel_type, overrides)

                if datasource:
                    print(f'  + g.panel.{panel_type}.queryOptions.withDatasource("{datasource_type}", "{datasource_uid}")')

                options = panel.get("options", {})
                # ─────────────────────────────────────────────────────────────
                #  STAT  panel
                # ─────────────────────────────────────────────────────────────
                if panel_type == "stat":
                    # first-level options
                    for k, v in options.items():
                        if k in STAT_OPTION_MAP:
                            path, method = STAT_OPTION_MAP[k]
                            emit_setter(panel_type, path, method, v)

                    # nested reduceOptions.*
                    if isinstance(options.get("reduceOptions"), dict):
                        for rk, rv in options["reduceOptions"].items():
                            if rk in STAT_OPTION_MAP:
                                path, method = STAT_OPTION_MAP[rk]
                                emit_setter(panel_type, path, method, rv)

                    # nested text.*
                    if isinstance(options.get("text"), dict):
                        for tk, tv in options["text"].items():
                            if tk in STAT_OPTION_MAP:
                                path, method = STAT_OPTION_MAP[tk]
                                emit_setter(panel_type, path, method, tv)

                # ─────────────────────────────────────────────────────────────
                #  TEXT  panel
                # ─────────────────────────────────────────────────────────────
                elif panel_type == "text":
                    # first-level options
                    for k, v in options.items():
                        if k in TEXT_OPTION_MAP:
                            path, method = TEXT_OPTION_MAP[k]
                            emit_setter(panel_type, path, method, v)

                    # nested code.*
                    if isinstance(options.get("code"), dict):
                        for ck, cv in options["code"].items():
                            if ck in TEXT_CODE_OPTION_MAP:
                                path, method = TEXT_CODE_OPTION_MAP[ck]
                                emit_setter(panel_type, path, method, cv)

                # ─────────────────────────────────────────────────────────────
                #  TABLE  panel
                # ─────────────────────────────────────────────────────────────
                elif panel_type == "table":
                    # first-level options
                    for k, v in options.items():
                        if k in TABLE_OPTION_MAP:
                            path, method = TABLE_OPTION_MAP[k]
                            emit_setter(panel_type, path, method, v)

                    # nested footer.*
                    if isinstance(options.get("footer"), dict):
                        for fk, fv in options["footer"].items():
                            if fk in TABLE_FOOTER_OPTION_MAP:
                                path, method = TABLE_FOOTER_OPTION_MAP[fk]
                                emit_setter(panel_type, path, method, fv)

                # ─────────────────────────────────────────────────────────────
                #  COMMON panel-root keys (title, description, transparent)
                # ─────────────────────────────────────────────────────────────
                for pk in PANEL_COMMON_MAP:
                    if pk in panel:
                        path, method = PANEL_COMMON_MAP[pk]
                        emit_setter(panel_type, path, method, panel[pk])

                targets = panel.get("targets", [])
                if targets:
                    print(f'  + g.panel.{panel_type}.queryOptions.withTargets({to_jsonnet(targets, indent=2)})')

                transformations = panel.get("transformations", [])
                if transformations:
                    for transformation in transformations:
                        print(f'  + g.panel.{panel_type}.queryOptions.withTransformations({to_jsonnet(transformation, indent=2)})')

                print(",")

            print("])")

        extract_variables(dashboard)
        extract_panels(dashboard)
        sys.stdout = sys.__stdout__  # Reset stdout

    print(f"✅ Conversion completed. Output saved to {output_file}")

    with open(output_file, "r") as file:
        content = file.read()

    print(f"✅ Cleaned up booleans/nulls in {output_file}")



convert_grafana_json_to_grafonnet("real_example_dashboard.json", "main.libsonnet")

