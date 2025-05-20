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
})
  + g.panel.text.options.withContent("<img width=\"85\" height=\"85\" src=\"data:image/png;base64,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Qb6CfAX5CvIV5CvIV5CvIF9BvoJ8BfkK8hXkK8hXkK8gX0G+gnwF+QryFeQryFeQryBfQb6CfAX5CvIV5CvIV5CvIF9BvoJ8BfkK8hXkK8hXkK8gX0G+gnwF+QryFeQryFeQryBfQb6CfAX5CvIV5CvIV5CvIF9BvoJ8BfkK8hXkK8hXkK8gX0G+gnwF+QryFeQryFeQryBfQb6CfAX5CvIV5CvIV5CvIF9BvoJ8BfkK8hXkK8hXkK8gX0G+gnwF+QryFeQryFeQryBfQb6CfAX5CvIV5CvIV5CvIF9BvoJ8BfkK8hXkK8hXkK8gX0G+gnwF+QryFeQryFeQryBfQb6CfAX5CvIV5CvIV5CvIF9BvoJ8BfkK8hXkK8hXkK8gX0G+gnwF+QryFeQryFeQryBfQb6CfAX5CvIV5CvIV5CvIF9BvoJ8BfkK8hXkK8hXkK8gX0G+gnwF+QryFeQryFeQryBfQb6CfAX5CvIV5CvIV5CvIF9BvoJ8BfkK8hXkK8hXkK8gX0G+gnwF+QryFeQryFeQryBfQb6CfAX5CvIV5CvIV5CvIF9BvoJ8BfkK8hXkK8hXkK8gX0G+gnwF+QryFeQryFeQryBfQb6CfAX5CvIV5CvIV5CvIF9BvoJ8BfkK8hXkK8hXkK8gX0W+inwV+SryVeSryFeRryJfRb6KfBX5KvJV5KvIV5GvIl9Fvop8Ffkq8lXkq8hXka8iX0W+inwV+SryVeSryFeRryJfRb6KfBX5KvJV5KvIV5GvIl9Fvop8Ffkq8lXkq8hXka8iX0W+inwV+SryVeSryFeRryJfRb6KfBX5KvJV5KvIV5GvIl9Fvop8Ffkq8lXkq8hXka8iX0W+inwV+SryVeSryFeRryJfRb6KfBX5KvJV5KvIV5GvIl9Fvop8Ffkq8lXkq8hXka8iX0W+inwV+SryVeSryFeRryJfRb6KfBX5KvJV5KvIV5GvIl9Fvop8Ffkq8lXkq8hXka8iX0W+inwV+SryVeSryFeRryJfRb6KfBX5KvJV5KvIV5GvIl9Fvop8Ffkq8lXkq8hXka8iX0W+inwV+SryVeSryFeRryJfRb6KfBX5KvJV5KvIV5GvIl9Fvop8Ffkq8lXkq8hXka8iX0W+inwV+SryVeSryFeRryJfRb6KfBX5KvJV5KvIV5GvIl9Fvop8Ffkq8lXkq8hXka8i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\" />")
  + g.panel.text.options.withMode("markdown")
  + g.panel.text.options.code.withLanguage("plaintext")
  + g.panel.text.options.code.withShowLineNumbers(false)
  + g.panel.text.options.code.withShowMiniMap(false)
  + g.panel.text.panelOptions.withDescription("")
  + g.panel.text.panelOptions.withTransparent(true)
  + g.panel.text.panelOptions.withTitle("")
,
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
g.panel.stat.new("") // stat Panel
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
