extends Node

"""
Після цього методу всі дочірні класи можуть брати глобальні зміни
(Спочатку ініціалізуються _ready дочірніх, а потім вже цей)
"""
func _ready() -> void:
	Global.services["WebService"] = $WebService									#Задаємо глобальному скрипту веб сервіс
	Global.webService = $WebService
	Global.services["FieldService"] = $FieldController
	print("Print of services from main class:")
	print(Global.services)														#Після цього всі інші класи можуть почати брати сервіси
	Global.allServicesLoaded = true


