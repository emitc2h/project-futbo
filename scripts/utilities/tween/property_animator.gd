class_name PropertyAnimator
extends Object

var _source_node: Node
var _object: Object
var _property_path: String

var _tw: Tween
var _dependent_animators: Array[PropertyAnimator]

var default_ease: Tween.EaseType = Tween.EASE_IN
var default_trans: Tween.TransitionType = Tween.TRANS_LINEAR
enum InterruptedBehavior {CURRENT_VALUE = 0, INITIAL_VALUE = 1, FINAL_VALUE}
var interrupted_behavior: InterruptedBehavior = InterruptedBehavior.CURRENT_VALUE

var _current_initial_value: Variant
var _current_final_value: Variant

signal interrupted(name: String)
signal finished(name: String)


func _init(source_node: Node, object: Object, property_path: String) -> void:
	_source_node = source_node
	_object = object
	_property_path = property_path
	interrupted.connect(_on_interrupted)


func set_to(value: Variant) -> void:
	_object.set(_property_path, value)


func animate_from_to(name: String,
	initial: Variant, final: Variant,
	duration: float,
	tw_ease: Tween.EaseType = default_ease,
	tw_trans: Tween.TransitionType = default_trans) -> void:
	_current_initial_value = initial
	_current_final_value = final
	if _tw:
		_tw.kill()
		interrupted.emit(name)
	_tw = _source_node.create_tween()
	_tw.tween_property(_object, _property_path, final, duration)\
		.set_ease(tw_ease)\
		.set_trans(tw_trans)\
		.from(initial)
	await _tw.finished
	finished.emit(name)
	_current_initial_value = null
	_current_final_value = null


func animate_to(name: String,
	final: Variant,
	duration: float,
	tw_ease: Tween.EaseType = default_ease,
	tw_trans: Tween.TransitionType = default_trans) -> void:
	_current_final_value = final
	if _tw:
		_tw.kill()
		interrupted.emit(name)
	_tw = _source_node.create_tween()
	_tw.tween_property(_object, _property_path, final, duration)\
		.set_ease(tw_ease)\
		.set_trans(tw_trans)
	await _tw.finished
	finished.emit(name)
	_current_final_value = null


func register_dependent(anim: PropertyAnimator) -> void:
	_dependent_animators.append(anim)
	anim.interrupted.connect(_on_dependent_interrupted)


func interrupt_silently() -> void:
	_tw.kill()
	_on_interrupted("")
	for anim in _dependent_animators:
		anim.interrupt_silently()


func _on_interrupted(_name: String) -> void:
	match(interrupted_behavior):
		InterruptedBehavior.FINAL_VALUE:
			if _current_final_value:
				set_to(_current_final_value)
		InterruptedBehavior.INITIAL_VALUE:
			if _current_initial_value:
				set_to(_current_initial_value)
		_:
			pass
			

func _on_dependent_interrupted(name: String) -> void:
	interrupt_silently()
	interrupted.emit(name)
