```json
{
  "title": "[Tab] == right(cmd+opt+shift) | tab if alone",
  "rules": [
    {
      "description": "[Tab] == right(cmd+opt+shift) | tab if alone",
      "manipulators": [
        {
          "from": {
            "key_code": "tab",
			  "modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {
              "key_code": "right_command",
              "modifiers": [
                "right_command",
                "right_option",
                "right_shift"
              ],
              "lazy": true
            }
          ],
          "to_if_alone": [
            {
              "key_code": "tab"
            }
          ],
          "type": "basic"
        }
      ]
    }
  ]
}
```
