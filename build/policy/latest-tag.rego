package main

denytags = [":latest"]

deny[msg] {
	input[i].Cmd == "from"
	val := input[i].Value
	contains(val[i], denytags[_])

	msg = sprintf("Unallowed tag found %s", [val])
}