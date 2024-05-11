extends Node

func playSound(stream: AudioStream, pitch: float = 1):
	var instance = AudioStreamPlayer.new();
	instance.stream = stream;
	instance.finished.connect(removeNode.bind(instance));
	
	add_child(instance);
	instance.pitch_scale = pitch;
	instance.play();

func removeNode(instance: AudioStreamPlayer):
	instance.queue_free();
