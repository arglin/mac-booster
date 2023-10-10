```json
{
	"title": "[TrackPad top_right_left touch + 123456789] == Quick cursor down_up [1-9] lines",
  "rules": [
    {
      "description": "[TrackPad top_right_left touch + 123456789] == Quick cursor down_up [1-9] lines",
      "manipulators": [
         {
          "from": {
            "key_code": "1",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
{"key_code": "up_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_left_half_area",
              "value": 1
            }

          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "1",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
{"key_code": "down_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_right_half_area",
              "value": 1
            }
          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "2",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
{"key_code": "up_arrow"},{"key_code": "up_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_left_half_area",
              "value": 1
            }

          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "2",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
{"key_code": "down_arrow"},{"key_code": "down_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_right_half_area",
              "value": 1
            }
          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "3",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
{"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_left_half_area",
              "value": 1
            }

          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "3",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_right_half_area",
              "value": 1
            }
          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "4",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_left_half_area",
              "value": 1
            }

          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "4",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_right_half_area",
              "value": 1
            }
          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "5",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"},            {"key_code": "up_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_left_half_area",
              "value": 1
            }

          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "5",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_right_half_area",
              "value": 1
            }
          ],
          "type": "basic"
        },
{
          "from": {
            "key_code": "6",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"}, {"key_code": "up_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_left_half_area",
              "value": 1
            }

          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "6",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_right_half_area",
              "value": 1
            }
          ],
          "type": "basic"
        },
{
          "from": {
            "key_code": "7",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"}, {"key_code": "up_arrow"}, {"key_code": "up_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_left_half_area",
              "value": 1
            }

          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "7",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_right_half_area",
              "value": 1
            }
          ],
          "type": "basic"
        },
{
          "from": {
            "key_code": "8",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"}, {"key_code": "up_arrow"}, {"key_code": "up_arrow"}, {"key_code": "up_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_left_half_area",
              "value": 1
            }

          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "8",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_right_half_area",
              "value": 1
            }
          ],
          "type": "basic"
        },
{
          "from": {
            "key_code": "9",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"},{"key_code": "up_arrow"}, {"key_code": "up_arrow"}, {"key_code": "up_arrow"}, {"key_code": "up_arrow"}, {"key_code": "up_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_left_half_area",
              "value": 1
            }

          ],
          "type": "basic"
        },{
          "from": {
            "key_code": "9",
				"modifiers": {
              "optional": [
                "any"
              ]
            }
          },
          "to": [
            {"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"},{"key_code": "down_arrow"}
          ],
			"conditions": [
			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_upper_half_area",
              "value": 1
            },			  {
              "type": "variable_if",
              "name": "multitouch_extension_finger_count_right_half_area",
              "value": 1
            }
          ],
          "type": "basic"
        }      ]
    }
  ]
}
```