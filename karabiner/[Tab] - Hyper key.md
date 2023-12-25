```json
{
    "description": "[Tab] == right(cmd+opt+shift) | shift_tab if alone",
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
                    "lazy": true,
                    "modifiers": [
                        "right_command",
                        "right_option",
                        "right_shift"
                    ]
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "tab",
                    "modifiers": [
                        "right_shift"
                    ]
                }
            ],
            "type": "basic"
        }
    ]
}
```
