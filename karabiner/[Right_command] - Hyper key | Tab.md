```json
{
  "title": "[Right_command] == left(cmd+ctl+opt+shift) |tab if alone",
  "rules": [
    {
      "description": "[Right_command] == left(cmd+ctl+opt+shift) | tab if alone",
      "manipulators": [
		{
          "from": {
            "key_code": "right_command",
			  "modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {
              "key_code": "left_command",
              "modifiers": [
                "left_command",
                "left_control",
                "left_option",
			 "left_shift"
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
