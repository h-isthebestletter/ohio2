class_name Utils

static func load_mp3(file_path: String) -> AudioStream:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var audio_stream = AudioStreamMP3.new()
	audio_stream.data = file.get_buffer(file.get_length())
	return audio_stream
	
