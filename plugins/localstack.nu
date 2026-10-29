# description: LocalStack helpers: lsk sqs-send QUEUE FILE (Oh My Zsh's localstack)
# requires:

# Send the contents of FILE to a LocalStack SQS queue
export def sqs-send [queue: string, payload: path, --endpoint: string = "http://localhost:4566"] {
    http post --content-type application/x-www-form-urlencoded $"($endpoint)/000000000000/($queue)" {Action: SendMessage, MessageBody: (open --raw $payload | decode)}
}

# LocalStack commands: lsk sqs-send QUEUE FILE
export def lsk [command: string, queue?: string, payload?: path] {
    match $command {
        "sqs-send" => {
            if $queue == null or $payload == null { error make --unspanned {msg: "Use: lsk sqs-send <queue> <payload file>"} }
            sqs-send $queue $payload
        }
        _ => { error make --unspanned {msg: $"Command not found: ($command)"} }
    }
}
