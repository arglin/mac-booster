```json
{
    "title": "[TrackPad 2 finger touch + 1|2|3|4|5|q|w|e|r|t|a|s|d|f|g|z|x|c|v|b|, 1 finger touch + | |[|]|\\| ] == place mouse cursor, with click",
    "rules": [
        {
            "description": "[TrackPad 2 finger touch + 1|2|3|4|5|q|w|e|r|t|a|s|d|f|g|z|x|c|v|b|, 1 finger touch + | |[|]|\\| ] == place mouse cursor, with click",
            "manipulators": [
                {
					"type": "basic",
                 "from": {"key_code": "spacebar"},
                 "to": [		{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "50%", "screen": 0}}},{"set_variable": {"name": "current_screen","value": 0}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2},{"type": "variable_if","name": "current_screen","value": 1}]},
{
					"type": "basic",
                 "from": {"key_code": "spacebar"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "50%", "screen": 1}}},{"set_variable": {"name": "current_screen","value": 1}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2},{"type": "variable_if","name": "current_screen","value": 0}]},
{
					"type": "basic",
                 "from": {"key_code": "spacebar"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "50%", "screen": 0}}},{"set_variable": {"name": "current_screen","value": 0}}],
					"conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2},{"type": "variable_unless","name": "current_screen","value": 1},{"type": "variable_unless","name": "current_screen","value": 0}]},


{
					"type": "basic",
                 "from": {"key_code": "spacebar"},
                 "to": [		{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "50%", "screen": 0}}},{"set_variable": {"name": "current_screen","value": 0}}],
					"to_delayed_action": {"to_if_invoked": [{"pointing_button": "button1"}], "to_if_canceled": []},
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_if","name": "current_screen","value": 1}]},
{
					"type": "basic",
                 "from": {"key_code": "spacebar"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "50%", "screen": 1}}},{"set_variable": {"name": "current_screen","value": 1}}],
					"to_delayed_action": {"to_if_invoked": [{"pointing_button": "button1"}], "to_if_canceled": []},
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_if","name": "current_screen","value": 0}]},
{
					"type": "basic",
                 "from": {"key_code": "spacebar"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "50%", "screen": 0}}},{"set_variable": {"name": "current_screen","value": 0}}],
					"to_delayed_action": {"to_if_invoked": [{"pointing_button": "button1"}], "to_if_canceled": []},
					"conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_unless","name": "current_screen","value": 1},{"type": "variable_unless","name": "current_screen","value": 0}]},


{
					"type": "basic",
                 "from": {"key_code": "open_bracket"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "50%", "screen": 0}}},{"set_variable": {"name": "current_screen","value": 0}}],
					"to_delayed_action": {"to_if_invoked": [{"pointing_button": "button1"}], "to_if_canceled": []},
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_unless","name": "current_screen","value": 0}]},
{
					"type": "basic",
                 "from": {"key_code": "open_bracket"},
                 "to": [],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_if","name": "current_screen","value": 0}]},



{
					"type": "basic",
                 "from": {"key_code": "close_bracket"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "50%", "screen": 1}}},{"set_variable": {"name": "current_screen","value": 1}}],
					 "to_delayed_action": {"to_if_invoked": [{"pointing_button": "button1"}], "to_if_canceled": []},
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_unless","name": "current_screen","value": 1}]},
{
					"type": "basic",
                 "from": {"key_code": "close_bracket"},
                 "to": [],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_if","name": "current_screen","value": 1}]},


{
					"type": "basic",
                 "from": {"key_code": "backslash"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "50%", "screen": 2}}},{"set_variable": {"name": "current_screen","value": 2}}],
					"to_delayed_action": {"to_if_invoked": [{"pointing_button": "button1"}], "to_if_canceled": []},
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_unless","name": "current_screen","value": 2}]},
{
					"type": "basic",
                 "from": {"key_code": "backslash"},
                 "to": [],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 1},{"type": "variable_if","name": "current_screen","value": 2}]},



{
					"type": "basic",
                 "from": {"key_code": "1"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "10%","y": "12%"}}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "2"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "30%","y": "12%"}}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "3"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "12%"}}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "4"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "70%","y": "12%"}}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "5"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "90%","y": "12%"}}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},



{
					"type": "basic",
                 "from": {"key_code": "q"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "10%","y": "38%"}}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},					{
					"type": "basic",
                 "from": {"key_code": "w"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "30%","y": "38%"}}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "e"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "38%"}}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "r"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "70%","y": "38%"}}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "t"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "90%","y": "38%"}}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},




        			{
					"type": "basic",
                 "from": {"key_code": "a"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "10%","y": "62%"}}}],
                 "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "s"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "30%","y": "62%"}}}],
                "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "d"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "62%"}}}],
"conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "f"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "70%","y": "62%"}}}],
                "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "g"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "90%","y": "62%"}}}],
                "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},





        			{
					"type": "basic",
                 "from": {"key_code": "z"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "10%","y": "88%"}}}],
                "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "x"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "30%","y": "88%"}}}],
                "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "c"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "50%","y": "88%"}}}],
                "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "v"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "70%","y": "88%"}}}],
                "conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]},
					{
					"type": "basic",
                 "from": {"key_code": "b"},
                 "to": [{"software_function": {"set_mouse_cursor_position": {"x": "90%","y": "88%"}}}],
					"conditions": [{"type": "variable_if","name":"multitouch_extension_finger_count_total","value": 2}]}
            ]
        }
    ]
}
```
