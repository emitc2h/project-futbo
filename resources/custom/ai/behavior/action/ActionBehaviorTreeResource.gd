class_name ActionBehaviorTreeResource
extends Resource

## A grouping of two behavior trees:
## 1. The `pre_action_tree` prepares the state of the agent to execute action. Failure to prepare
##    means the action will fail.
## 2. The actual action to be executed.

@export var pre_action_tree: BehaviorTree
@export var action_tree: BehaviorTree
