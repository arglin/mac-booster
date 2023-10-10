```json
{
  "title": "[Right_Shift] == left(cmd+ctl+shift) | Switch window if alone",
  "rules": [
    {
      "description": "[Right_Shift] == left(cmd+ctl+shift) | Switch window if alone",
      "manipulators": [
        {
          "from": {
            "key_code": "right_shift",
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
                "left_shift"
              ],
              "lazy": true
            }
          ],
          "to_if_alone":[
                  {
            	        "key_code":"y",
                     "modifiers":[
                        "right_shift","right_option", "right_command"
                     ]
                  }
               ],
          "type": "basic"
        }
      ]
    }
  ]
}
```