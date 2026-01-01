class_name Utils

static func load_mp3(file_path: String) -> AudioStreamMP3:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var audio_stream = AudioStreamMP3.new()
	audio_stream.data = file.get_buffer(file.get_length())
	return audio_stream

static func load_looping_mp3(file_path: String) -> AudioStreamMP3:
	var stream = load_mp3(file_path)
	stream.loop = true
	return stream
