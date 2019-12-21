Scheme of the hubot brain
=========================

.. code-block:: json

    {
        "users" {
            "<USERID>": {
                "id" : "<USERID>"
                // ...
            }
        },
        "_private" : {}, // empty
        "deleteBrain": {
            "last_time" : <TIMESTAMP>, // 前回の削除時間？
            "messages" : {
                "<TIMESTAMP>": [
                    {
                        "ts": <TIMESTAMP>,
                        "ch": "<CHANNEL ID>",
                        "iv": <int value> // interval time?
                ]

        }
        "plusPlus": {
            "scores" {
                "<NAME>": <SCORE>
                // ...
            },
            "log": { // reason用の履歴？
                "<USER NAME>": {
                    "<NAME>": <TIMESTAMP STR>",
                    // ...
                },
                // ...
            },
            "reasons": {
                "<NAME>": {
                    "<REASON>": <SCORE>,
                    // ...
                },
                // ...

            },
            "last": {
                "<USER NAME>: {
                    "user": "<USER NAME>"
                },
                // ...
            },
            "groupBrain": {
                "<GROUP NAME>": [
                    "<MEMBER>",
                    // ...
                ],
                // ...
            },
            "stampBrain": {
                "<NAME>": "<URL>",
                // ...
            },
            "zoiBrain": {
                "<NAME>": "<URL>",
                // ...
            },
            "cronjob": {}, // empty
            "scores": { // should be delete
                "<NAME>": <SCORE>,
                // ...
            },
            "scoreLog", // should be delete -> deleted
            "scoreReasons", // should be delete -> deleted
            "mostRecentlyUpdated", // should be delete -> deleted
            "currentDetectNumberDigit": <int value>, // ?
            "currentDetectNumber": "<int value>" // ?
    }
