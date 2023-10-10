```json
{
  "title": "[Caps Lock] == right(cmd+ctl+opt) | Escape if alone",
  "rules": [
    {
      "description": "[Caps Lock] == right(cmd+ctl+opt) | Escape if alone",
      "manipulators": [
        {
          "from": {
            "key_code": "caps_lock",
			  "modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {
              "key_code": "right_option",
              "modifiers": [
                "right_option",
                "right_command",
                "right_control"

              ],
              "lazy": true
            }
          ],
          "to_if_alone": [
            {
              "key_code": "escape"
            }
          ],
          "type": "basic"
        }
      ]
    }
  ]
}
```