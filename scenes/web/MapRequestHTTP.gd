extends AwaitableHTTPRequest

var time_start = 0
var time_end = 0

func map_request_send(mapRequest: FieldRequestForGen) -> MapInfo:
	var requestBody = JSON.stringify(mapRequest.toJSON());
	print(requestBody)
	var headers = ["Content-Type: application/json"]
	
	time_start = Time.get_ticks_msec()
	var resp := await async_request("https://localhost:7080/generate", headers, HTTPClient.METHOD_POST, requestBody)
	
	time_end = Time.get_ticks_msec()
	print(time_end - time_start)
	if resp.success():
		return MapInfo.toObject(resp.body_as_json())
	return
