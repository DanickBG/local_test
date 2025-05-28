local g = import 'g.libsonnet';
local var = g.dashboard.variable;
local grafana = import 'bigquery.libsonnet';
local bigquery = grafana.bigqueryPanel;


local LRA = 
var.query.new("LRA")
+   var.query.withDatasource("grafana-bigquery-datasource", "qUaUqEk4k")
+    {
    "query": {
        "editorMode": "code",
        "format": 1,
        "location": "europe-west3",
        "project": "ndr-code-bi-dashboard",
        "rawQuery": true,
        "rawSql": "Select a.LRA  FROM\n(\nSELECT DISTINCT LRA FROM `ndr-code-bi-dashboard.Quintly.profiles` \n) as a \nORDER BY(\nCASE WHEN a.LRA like  LEFT(\"${__user.login}\",3)\nTHEN 1\nELSE 0\nEND\n) DESC",
        "sql": {
            "columns": [
                {
                    "parameters": [],
                    "type": "function"
                }
            ],
            "groupBy": [
                {
                    "property": {
                        "type": "string"
                    },
                    "type": "groupBy"
                }
            ],
            "limit": 50
        }
    }
}
  +var.query.generalOptions.showOnDashboard.withNothing()
   +{ "current": 
{
      "text": "NDR",
      "value": "NDR"
}
}
;
local Profil = 
var.query.new("Profil")
+   var.query.withDatasource("grafana-bigquery-datasource", "qUaUqEk4k")
+    {
    "query": {
        "dataset": "QuintlyTest",
        "editorMode": "code",
        "format": 1,
        "location": "europe-west3",
        "project": "ndr-code-bi-dashboard",
        "rawQuery": true,
        "rawSql": "SELECT a.profile \nFROM \n(SELECT profile FROM `ndr-code-bi-dashboard.Quintly.profiles` WHERE LRA = '$LRA' AND instagramId != 0) as a,\n(SELECT  Profil_IG FROM `ndr-code-bi-dashboard.Quintly.default-settings` WHERE LRA = '$LRA') as b\nORDER BY( \nCASE WHEN a.profile = b.Profil_IG THEN 1\nELSE 2\nEND\n), a.profile ASC",
        "sql": {
            "columns": [
                {
                    "parameters": [
                        {
                            "name": "profile",
                            "type": "functionParameter"
                        }
                    ],
                    "type": "function"
                }
            ],
            "groupBy": [
                {
                    "property": {
                        "type": "string"
                    },
                    "type": "groupBy"
                }
            ],
            "limit": 50
        },
        "table": "profileTest"
    }
}
  +var.query.generalOptions.showOnDashboard.withNothing()
   +{ "current": 
{
      "text": "NDR Info",
      "value": "NDR Info"
}
}
;
local Zeitraum = 
var.custom.new("Zeitraum", "Gestern : EXTRACT(DATE from time) = DATE_SUB(CURRENT_DATE()\\, INTERVAL  1 DAY), Letzte 7 Tage : EXTRACT(DATE from time) >=  DATE_SUB(CURRENT_DATE()\\, INTERVAL  7 DAY) AND EXTRACT(DATE from time) < CURRENT_DATE(), Letztes Wochenende :  DATE(time) >= (  SELECT    saturday  FROM (    SELECT      DATE(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP()\\, WEEK(MONDAY)) - INTERVAL 1 DAY) AS sunday\\,      DATE(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP()\\, WEEK(MONDAY)) - INTERVAL 2 DAY) AS saturday ) )  AND DATE(time) <= (  SELECT    sunday  FROM (    SELECT      DATE(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP()\\, WEEK(MONDAY)) - INTERVAL 1 DAY) AS sunday\\,      DATE(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP()\\, WEEK(MONDAY)) - INTERVAL 2 DAY) AS saturday ) ), Letzte 30 Tage : EXTRACT(DATE from time) >=  DATE_SUB(CURRENT_DATE()\\, INTERVAL  30 DAY) AND EXTRACT(DATE from time) < CURRENT_DATE()")
+   var.custom.withQuery("Gestern : EXTRACT(DATE from time) = DATE_SUB(CURRENT_DATE()\\, INTERVAL  1 DAY), Letzte 7 Tage : EXTRACT(DATE from time) >=  DATE_SUB(CURRENT_DATE()\\, INTERVAL  7 DAY) AND EXTRACT(DATE from time) < CURRENT_DATE(), Letztes Wochenende :  DATE(time) >= (  SELECT    saturday  FROM (    SELECT      DATE(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP()\\, WEEK(MONDAY)) - INTERVAL 1 DAY) AS sunday\\,      DATE(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP()\\, WEEK(MONDAY)) - INTERVAL 2 DAY) AS saturday ) )  AND DATE(time) <= (  SELECT    sunday  FROM (    SELECT      DATE(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP()\\, WEEK(MONDAY)) - INTERVAL 1 DAY) AS sunday\\,      DATE(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP()\\, WEEK(MONDAY)) - INTERVAL 2 DAY) AS saturday ) ), Letzte 30 Tage : EXTRACT(DATE from time) >=  DATE_SUB(CURRENT_DATE()\\, INTERVAL  30 DAY) AND EXTRACT(DATE from time) < CURRENT_DATE()")
  +var.custom.generalOptions.showOnDashboard.withNothing()
   +{ "current": 
{
      "text": "EXTRACT(DATE from time) >=  DATE_SUB(CURRENT_DATE(), INTERVAL  7 DAY) AND EXTRACT(DATE from time) < CURRENT_DATE()",
      "value": "EXTRACT(DATE from time) >=  DATE_SUB(CURRENT_DATE(), INTERVAL  7 DAY) AND EXTRACT(DATE from time) < CURRENT_DATE()"
}
}
;
local lastUpdate = 
var.query.new("lastUpdate")
+   var.query.withDatasource("grafana-bigquery-datasource", "qUaUqEk4k")
+    {
    "query": {
        "editorMode": "code",
        "format": 1,
        "location": "europe-west3",
        "project": "ndr-code-bi-dashboard",
        "rawQuery": true,
        "rawSql": "SELECT \r\nCASE MAX(last_update)\r\n  WHEN NULL THEN \"N/A\"\r\n  ELSE FORMAT_DATETIME(\"%d.%m.%Y | %H:%M Uhr\", DATETIME(MAX(last_update),\"Europe/Berlin\"))\r\n  END\r\nFROM `ndr-code-bi-dashboard.Quintly.instagram`\r\nWHERE profileId = $profileID  ",
        "sql": {
            "columns": [
                {
                    "parameters": [],
                    "type": "function"
                }
            ],
            "groupBy": [
                {
                    "property": {
                        "type": "string"
                    },
                    "type": "groupBy"
                }
            ],
            "limit": 50
        }
    }
}
  +var.query.generalOptions.showOnDashboard.withNothing()
   +{ "current": 
{
      "text": "12.05.2025 | 13:06 Uhr",
      "value": "12.05.2025 | 13:06 Uhr"
}
}
;
local filled_size = 
var.custom.new("filled_size", [
      "8",
    ])
+   var.custom.withQuery("8 : 8")
  +var.custom.generalOptions.showOnDashboard.withNothing()
   +{ "current": 
{
      "text": "8",
      "value": "8"
}
}
;
local filled_size_big = 
var.custom.new("filled_size_big", [
      "10",
    ])
+   var.custom.withQuery("10 : 10")
  +var.custom.generalOptions.showOnDashboard.withNothing()
   +{ "current": 
{
      "text": "10",
      "value": "10"
}
}
;
local profileID = 
var.query.new("profileID")
+   var.query.withDatasource("grafana-bigquery-datasource", "qUaUqEk4k")
+    {
    "query": {
        "dataset": "QuintlyTest",
        "editorMode": "code",
        "format": 1,
        "location": "europe-west3",
        "project": "ndr-code-bi-dashboard",
        "rawQuery": true,
        "rawSql": "SELECT CAST(instagramID AS STRING) FROM `ndr-code-bi-dashboard.Quintly.profiles` WHERE profile = '''$Profil''' ",
        "refId": "tempvar",
        "sql": {
            "columns": [
                {
                    "parameters": [
                        {
                            "name": "facebookID",
                            "type": "functionParameter"
                        }
                    ],
                    "type": "function"
                },
                {
                    "parameters": [
                        {
                            "name": "instagramID",
                            "type": "functionParameter"
                        }
                    ],
                    "type": "function"
                },
                {
                    "parameters": [
                        {
                            "name": "youtubeID",
                            "type": "functionParameter"
                        }
                    ],
                    "type": "function"
                }
            ],
            "groupBy": [
                {
                    "property": {
                        "type": "string"
                    },
                    "type": "groupBy"
                }
            ],
            "limit": 50
        },
        "table": "profileTest"
    }
}
  +var.query.generalOptions.showOnDashboard.withNothing()
   +{ "current": 
{
      "text": "404008",
      "value": "404008"
}
}
;
local filled_size_small = 
var.custom.new("filled_size_small", [
      "7",
    ])
+   var.custom.withQuery("7 : 7")
  +var.custom.generalOptions.showOnDashboard.withNothing()
   +{ "current": 
{
      "text": "7",
      "value": "7"
}
}
;
local filled_size_headline = 
var.custom.new("filled_size_headline", [
      "48",
    ])
+   var.custom.withQuery("48 : 48")
  +var.custom.generalOptions.showOnDashboard.withNothing()
   +{ "current": 
{
      "text": "48",
      "value": "48"
}
}
;
local filled_size_headline_small = 
var.custom.new("filled_size_headline_small", [
      "40",
    ])
+   var.custom.withQuery("40 : 40")
  +var.custom.generalOptions.showOnDashboard.withNothing()
   +{ "current": 
{
      "text": "40",
      "value": "40"
}
}
;
g.dashboard.new("NDR Info | TV Instagram | Top Fotos und Karusselle Demo")
+ g.dashboard.withVariables([LRA, Profil, Zeitraum, lastUpdate, filled_size, filled_size_big, profileID, filled_size_small, filled_size_headline, filled_size_headline_small])
+ g.dashboard.withPanels([
g.panel.text.new("") // text Panel
  + g.panel.text.panelOptions.withGridPos(h=4, w=2, x=0, y=0)
  + g.panel.text.options.withCode({
  "language": "plaintext",
  "showLineNumbers": false,
  "showMiniMap": false,
}),
g.panel.text.new("") // text Panel
  + g.panel.text.panelOptions.withGridPos(h=3, w=10, x=2, y=0)
  + g.panel.text.options.withCode({
  "language": "plaintext",
  "showLineNumbers": false,
  "showMiniMap": false,
})
  + g.panel.text.options.withContent("<font size=\"8\" style=\"color:rgb(214,41,118);\">Instagram</font><font size=\"8\">  ${Profil} </font>")
  + g.panel.text.options.withMode("markdown")
  + g.panel.text.options.code.withLanguage("plaintext")
  + g.panel.text.options.code.withShowLineNumbers(false)
  + g.panel.text.options.code.withShowMiniMap(false)
  + g.panel.text.panelOptions.withDescription("")
  + g.panel.text.panelOptions.withTransparent(true)
  + g.panel.text.panelOptions.withTitle("")
,
g.panel.stat.new("KPI Visits") // stat Panel
  + g.panel.stat.panelOptions.withGridPos(h=4, w=4, x=13, y=0)
  + g.panel.stat.standardOptions.color.withFixedColor("#d62976")
  + g.panel.stat.standardOptions.color.withMode("fixed")
+{"thresholds": {
    "mode": "absolute",
    "steps": [
        {
            "color": "green",
            "value": null
        }
    ]
} }
  + g.panel.stat.standardOptions.withOverrides([
      g.panel.stat.fieldOverride.byName.new("totalInteractions")
      + g.panel.stat.fieldOverride.byName.withProperty("displayName", "Interaktionen")
      
  ])
  + g.panel.stat.queryOptions.withDatasource("grafana-bigquery-datasource", "qUaUqEk4k")
  + g.panel.stat.options.withColorMode("background")
  + g.panel.stat.options.withGraphMode("none")
  + g.panel.stat.options.withJustifyMode("center")
  + g.panel.stat.options.withOrientation("auto")
  + g.panel.stat.options.withShowPercentChange(false)
  + g.panel.stat.options.withTextMode("value_and_name")
  + g.panel.stat.options.withWideLayout(true)
  + g.panel.stat.options.reduceOptions.withCalcs([
  "last",
])
  + g.panel.stat.options.reduceOptions.withFields("/.*/")
  + g.panel.stat.options.reduceOptions.withValues(false)
  + g.panel.stat.panelOptions.withDescription("")
  + g.panel.stat.panelOptions.withTransparent(true)
  + g.panel.stat.queryOptions.withTargets([
      {
        "dataset": "Quintly",
        "datasource": {
          "type": "grafana-bigquery-datasource",
          "uid": "qUaUqEk4k",
        },
        "editorMode": "code",
        "format": 1,
        "location": "europe-west3",
        "project": "ndr-code-bi-dashboard",
        "rawQuery": true,
        "rawSql": "SELECT  CONCAT(REPEAT(\" \", $filled_size_big - CHAR_LENGTH(CAST(totalInteractions as STRING))), REPLACE(CAST(FORMAT(\"%'.0f\", CAST(ROUND(totalInteractions) as NUMERIC)) AS STRING), \",\", \".\")) totalInteractions FROM\n(\nSELECT \n  SUM(CASE WHEN type = 'Reel' THEN IFNULL(totalInteractions,0) ELSE IFNULL(engagement,0) END) AS totalInteractions\nFROM `ndr-code-bi-dashboard.Quintly.instagramInsightsOwnPosts`\nWHERE profileId = $profileID \nAND $Zeitraum \n)",
        "refId": "A",
        "sql": {
          "columns": [
            {
              "parameters": [
                {
                  "name": "page_engaged_users",
                  "type": "functionParameter",
                },
              ],
              "type": "function",
            },
          ],
          "groupBy": [
            {
              "property": {
                "type": "string",
              },
              "type": "groupBy",
            },
          ],
          "limit": 50,
          "whereJsonTree": {
            "children1": {
              "baa899a9-cdef-4012-b456-718364767b70": {
                "properties": {
                  "field": "profileId",
                  "operator": "equal",
                  "value": [
                    null,
                  ],
                  "valueSrc": [
                    "value",
                  ],
                  "valueType": [
                    "number",
                  ],
                },
                "type": "rule",
              },
            },
            "id": "b8aaaa8b-0123-4456-b89a-b18364767b70",
            "type": "group",
          },
        },
        "table": "facebookInsights",
      },
    ])
  + g.panel.stat.queryOptions.withTransformations({
      "id": "organize",
      "options": {
        "excludeByName": {
        },
        "indexByName": {
        },
        "renameByName": {
          "f0_": "Summe",
          "page_impressions_unique": "Potentielle Reichweite",
        },
      },
    })
,
g.panel.stat.new("") // stat Panel
  + g.panel.stat.panelOptions.withGridPos(h=4, w=4, x=17, y=0)
  + g.panel.stat.standardOptions.color.withFixedColor("#d62976")
  + g.panel.stat.standardOptions.color.withMode("fixed")
+{"thresholds": {
    "mode": "absolute",
    "steps": [
        {
            "color": "green",
            "value": null
        }
    ]
} }
  + g.panel.stat.standardOptions.withOverrides([
      g.panel.stat.fieldOverride.byName.new("Reach")
      + g.panel.stat.fieldOverride.byName.withProperty("displayName", "\u2300 Pot. Reichweite pro Post")
      
  ])
  + g.panel.stat.queryOptions.withDatasource("grafana-bigquery-datasource", "qUaUqEk4k")
  + g.panel.stat.options.withColorMode("background")
  + g.panel.stat.options.withGraphMode("none")
  + g.panel.stat.options.withJustifyMode("center")
  + g.panel.stat.options.withOrientation("auto")
  + g.panel.stat.options.withShowPercentChange(false)
  + g.panel.stat.options.withTextMode("value_and_name")
  + g.panel.stat.options.withWideLayout(true)
  + g.panel.stat.options.reduceOptions.withCalcs([
  "last",
])
  + g.panel.stat.options.reduceOptions.withFields("/.*/")
  + g.panel.stat.options.reduceOptions.withValues(false)
  + g.panel.stat.panelOptions.withDescription("")
  + g.panel.stat.panelOptions.withTransparent(true)
  + g.panel.stat.panelOptions.withTitle("")
  + g.panel.stat.queryOptions.withTargets([
      {
        "dataset": "Quintly",
        "datasource": {
          "type": "grafana-bigquery-datasource",
          "uid": "qUaUqEk4k",
        },
        "editorMode": "code",
        "format": 1,
        "location": "europe-west3",
        "project": "ndr-code-bi-dashboard",
        "rawQuery": true,
        "rawSql": "SELECT  CONCAT(REPEAT(\" \", $filled_size - CHAR_LENGTH(CAST(Reach as STRING))), REPLACE(CAST(FORMAT(\"%'.0f\", CAST(ROUND(Reach) as NUMERIC)) AS STRING), \",\", \".\"))as  Reach FROM\n(\nSELECT \n  ROUND(AVG(reach)) AS Reach \nFROM `ndr-code-bi-dashboard.Quintly.instagramInsightsOwnPosts`\nWHERE profileId = $profileID \nAND $Zeitraum \n)",
        "refId": "A",
        "sql": {
          "columns": [
            {
              "parameters": [
                {
                  "name": "page_engaged_users",
                  "type": "functionParameter",
                },
              ],
              "type": "function",
            },
          ],
          "groupBy": [
            {
              "property": {
                "type": "string",
              },
              "type": "groupBy",
            },
          ],
          "limit": 50,
          "whereJsonTree": {
            "children1": {
              "baa899a9-cdef-4012-b456-718364767b70": {
                "properties": {
                  "field": "profileId",
                  "operator": "equal",
                  "value": [
                    null,
                  ],
                  "valueSrc": [
                    "value",
                  ],
                  "valueType": [
                    "number",
                  ],
                },
                "type": "rule",
              },
            },
            "id": "b8aaaa8b-0123-4456-b89a-b18364767b70",
            "type": "group",
          },
        },
        "table": "facebookInsights",
      },
    ])
,
g.panel.text.new("") // text Panel
  + g.panel.text.panelOptions.withGridPos(h=2, w=3, x=21, y=0)
  + g.panel.text.options.withCode({
  "language": "plaintext",
  "showLineNumbers": false,
  "showMiniMap": false,
})
  + g.panel.text.options.withContent("Letztes Update: <br> \r\n${lastUpdate}")
  + g.panel.text.options.withMode("markdown")
  + g.panel.text.options.code.withLanguage("plaintext")
  + g.panel.text.options.code.withShowLineNumbers(false)
  + g.panel.text.options.code.withShowMiniMap(false)
  + g.panel.text.panelOptions.withTransparent(true)
  + g.panel.text.panelOptions.withTitle("")
,
g.panel.text.new("") // text Panel
  + g.panel.text.panelOptions.withGridPos(h=2, w=12, x=0, y=4)
  + g.panel.text.options.withCode({
  "language": "plaintext",
  "showLineNumbers": false,
  "showMiniMap": false,
})
  + g.panel.text.options.withContent("<span style=\"font-family:Arial; font-size:2.3em;\">Top Fotos und Karusselle | ${Zeitraum:text}</span>")
  + g.panel.text.options.withMode("markdown")
  + g.panel.text.options.code.withLanguage("plaintext")
  + g.panel.text.options.code.withShowLineNumbers(false)
  + g.panel.text.options.code.withShowMiniMap(false)
  + g.panel.text.panelOptions.withDescription("")
  + g.panel.text.panelOptions.withTransparent(true)
  + g.panel.text.panelOptions.withTitle("")
,
g.panel.text.new("") // text Panel
  + g.panel.text.panelOptions.withGridPos(h=2, w=12, x=12, y=4)
  + g.panel.text.options.withCode({
  "language": "plaintext",
  "showLineNumbers": false,
  "showMiniMap": false,
})
  + g.panel.text.options.withContent("<p style=\"text-align: right\"><font size=\"2\">Legende: &nbsp;\ud83d\uddbc\ufe0f = Foto &nbsp;&nbsp; \ud83c\udfa0 = Karussell &nbsp;&nbsp;</font><font size=\"6\"> </font>")
  + g.panel.text.options.withMode("markdown")
  + g.panel.text.options.code.withLanguage("plaintext")
  + g.panel.text.options.code.withShowLineNumbers(false)
  + g.panel.text.options.code.withShowMiniMap(false)
  + g.panel.text.panelOptions.withDescription("")
  + g.panel.text.panelOptions.withTransparent(true)
  + g.panel.text.panelOptions.withTitle("")
,
g.panel.table.new("") // marcusolsson-dynamictext-panel Panel
     + {
      "datasource": {
            "type": "grafana-bigquery-datasource",
            "uid": "qUaUqEk4k"
      },
      "description": "",
      "fieldConfig": {
            "defaults": {
                  "thresholds": {
                        "mode": "absolute",
                        "steps": [
                              {
                                    "color": "green",
                                    "value": null
                              },
                              {
                                    "color": "red",
                                    "value": 80
                              }
                        ]
                  }
            },
            "overrides": [
                  {
                        "matcher": {
                              "id": "byName",
                              "options": "time"
                        },
                        "properties": [
                              {
                                    "id": "unit",
                                    "value": "time: DD.MM | HH:mm \\U\\h\\r"
                              }
                        ]
                  },
                  {
                        "matcher": {
                              "id": "byType",
                              "options": "number"
                        },
                        "properties": [
                              {
                                    "id": "unit",
                                    "value": "locale"
                              }
                        ]
                  }
            ]
      },
      "gridPos": {
            "h": 22,
            "w": 24,
            "x": 0,
            "y": 6
      },
      "id": 162,
      "options": {
            "afterRender": "",
            "content": "<table>\n  <thead>\n    <tr>\n      <th id=\"timestamp\">Datum</th>\n      <th id=\"post\">Post</th>\n      <th id=\"engagement\">\u25bc Interaktionen</th>\n      <th id=\"reach\">pot. Reichweite</th>\n      <th id=\"type\">Typ</th>\n    </tr>\n  </thead>\n  \n  <tbody>\n    {{#each data}}\n    <tr>\n      <td class=\"time\" data-time=\"{{this.time}}\">{{this.time}}</td>\n      <td id=\"post\">{{this.Post}}</td>\n      <td class=\"number\">{{this.engagement}}</td>\n      <td class=\"number\">{{this.PotReichweite}}</td>\n      <td>\n        {{#if (eq this.Typ \"Image\")}}\n          \ud83d\uddbc\ufe0f\n        {{else if (eq this.Typ \"Carousel\")}}\n           \ud83c\udfa0\n        {{else}}\n          {{this.Typ}}\n        {{/if}}\n      </td>\n    </tr>\n    {{/each}}\n  </tbody>\n</table>",
            "contentPartials": [],
            "defaultContent": "The query didn't return any results.",
            "editor": {
                  "format": "auto",
                  "language": "markdown"
            },
            "editors": [
                  "styles"
            ],
            "externalStyles": [],
            "helpers": "",
            "renderMode": "allRows",
            "styles": "<style>\n  table {\n    font-size: 25px;\n    max-width: 1900px;\n    border-collapse: collapse;\n  }\n\n  th {\n    font-size: 20px;\n    font-weight: bold;\n    text-align: left;\n  }\n\n  td {\n    font-size: 25px;\n    padding: 8px;\n    height: 90px;\n  }\n\n  td.time {\n    font-weight: bold;\n    font-size: 20px;\n    min-width: 200px;\n  }\n\n  th#engagement {\n    width: 175px;\n  }\n\n  #reach {\n    width: 165.8px;\n  }\n\n  td.videoViews {\n    width: 124px;\n  }\n  td.number{\n    text-align: center;\n  }\n  td.type {\n    width: 100px;\n  }\n\n  td#post {\n    width: auto;\n    word-wrap: break-word;\n    white-space: normal;\n}\n</style>\n\n\n",
            "wrap": true
      },
      "pluginVersion": "5.6.0",
      "targets": [
            {
                  "datasource": {
                        "type": "grafana-bigquery-datasource",
                        "uid": "qUaUqEk4k"
                  },
                  "editorMode": "code",
                  "format": 1,
                  "location": "europe-west3",
                  "project": "ndr-code-bi-dashboard",
                  "rawQuery": true,
                  "rawSql": "SELECT\r\n  time, \r\n  CASE \r\n    WHEN LENGTH(REPLACE(SPLIT(message, '\\n')[SAFE_OFFSET(0)], '\ufffd', '')) > 95 \r\n    THEN CONCAT(LEFT(REPLACE(SPLIT(message, '\\n')[SAFE_OFFSET(0)], '\ufffd', ''), 95), '...')\r\n    ELSE REPLACE(SPLIT(message, '\\n')[SAFE_OFFSET(0)], '\ufffd', '')\r\nEND AS Post,\r\n  -- REPLACE(message, '\ufffd', '') AS Post, \r\n  CASE\r\n    WHEN type = 'Reel' THEN totalInteractions\r\n    ELSE engagement\r\n  END AS engagement,  reach AS PotReichweite,\r\n  type AS Typ\r\nFROM `ndr-code-bi-dashboard.Quintly.instagramInsightsOwnPosts`\r\nWHERE profileId = $profileID\r\nAND (type = 'Image' OR type = 'Carousel')\r\nAND $Zeitraum\r\nORDER BY engagement DESC LIMIT 7",
                  "refId": "A",
                  "sql": {
                        "columns": [
                              {
                                    "parameters": [],
                                    "type": "function"
                              }
                        ],
                        "groupBy": [
                              {
                                    "property": {
                                          "type": "string"
                                    },
                                    "type": "groupBy"
                              }
                        ],
                        "limit": 50
                  }
            }
      ],
      "title": "",
      "transformations": [
            {
                  "id": "organize",
                  "options": {
                        "excludeByName": {},
                        "includeByName": {},
                        "indexByName": {},
                        "renameByName": {
                              "PotReichweite": "",
                              "engagement": "",
                              "reach": "Pot. Reichweite",
                              "time": "",
                              "type": "Typ"
                        }
                  }
            }
      ],
      "transparent": true,
      "type": "marcusolsson-dynamictext-panel"
}
])
