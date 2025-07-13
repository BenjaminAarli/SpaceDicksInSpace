extends Node

func write(t: String):
	var nodes = get_tree().get_nodes_in_group("Chatlog")
	for node in nodes: node.write(t)
