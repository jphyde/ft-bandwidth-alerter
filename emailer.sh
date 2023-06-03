source .env

SUBJ=$1
TEXT=$2
HTML=$3

# This call sends a message to one recipient.
curl -s \
        -X POST \
        --user "$MJ_APIKEY_PUBLIC:$MJ_APIKEY_PRIVATE" \
        https://api.mailjet.com/v3.1/send \
        -H 'Content-Type: application/json' \
        -d '{
                "Messages":[
                                {
                                                "From": {
                                                                "Email": "'$FROM'",
                                                                "Name": "'$FROMNAME'"
                                                },
                                                "To": [
                                                                {
                                                                                "Email": "'$TO'"
                                                                }
                                                ],
                                                "Subject": "'"$SUBJ"'",
                                                "TextPart": "'"$TEXT"'",
                                                "HTMLPart": "'"$HTML"'"
                                }
                ]
        }'
