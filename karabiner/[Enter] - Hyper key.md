```json
{
    "description": "[Enter] == left(ctl+opt+shift) | Enter if alone",
    "manipulators": [
        {
            "from": {
                "key_code": "return_or_enter",
                "modifiers": {
                    "optional": [
                        "any"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "left_control",
                    "lazy": true,
                    "modifiers": [
                        "left_control",
                        "left_option",
                        "left_shift"
                    ]
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "return_or_enter"
                }
            ],
            "type": "basic"
        }
    ]
}